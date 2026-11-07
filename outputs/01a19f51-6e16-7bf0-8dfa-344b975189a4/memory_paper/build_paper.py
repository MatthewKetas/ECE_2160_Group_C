from pathlib import Path
from copy import deepcopy
import hashlib
import json
import re
import zipfile
from lxml import etree as E
import subprocess
import sys
from reportlab.graphics.shapes import Drawing, String, Rect
from reportlab.graphics.charts.barcharts import VerticalBarChart
from reportlab.graphics import renderSVG
from reportlab.lib.colors import HexColor

OUT=Path(__file__).resolve().parent
REF=OUT/'reference.docx'
TARGET=OUT/'Memory_HW_Ketas_V1.docx'
D=json.loads((OUT.parent/'source_data.json').read_text())
INV=json.loads((OUT/'reference_inventory.json').read_text())
assert hashlib.sha256(REF.read_bytes()).hexdigest()==INV['sha256']
main=D['main']
stats={(x['variant'],x['unit']):x for x in D['statistics']}
builds={(x['variant'],x['unit']):x for x in D['builds'] if x['session']==main and not x['diagnostic']}
diag={x['variant']:x for x in D['diagnostics']}
phases={(x['variant'],x['phase']):x for x in D['phases'] if x['session']==main}
blue='#245A85';gray='#6F7984';orange='#B7722F'

def label(d,x,y,text,size=8,angle=0):d.add(String(x,y,text,fontName='Times-Roman',fontSize=size,angle=angle))
def barplot(d,values,labels,x,y,w,h,maxval,step,ytitle,show=False):
    c=VerticalBarChart();c.x=x;c.y=y;c.width=w;c.height=h;c.data=values
    c.categoryAxis.categoryNames=labels;c.categoryAxis.labels.fontName='Times-Roman';c.categoryAxis.labels.fontSize=7
    c.valueAxis.valueMin=0;c.valueAxis.valueMax=maxval;c.valueAxis.valueStep=step
    c.valueAxis.labels.fontName='Times-Roman';c.valueAxis.labels.fontSize=7
    c.valueAxis.labelTextFormat='%d';c.valueAxis.strokeColor=HexColor('#777777');c.categoryAxis.strokeColor=HexColor('#777777')
    c.bars.strokeColor=None
    for i,color in enumerate([blue,gray,orange]):c.bars[i].fillColor=HexColor(color)
    if show:c.barLabelFormat='%d';c.barLabels.fontName='Times-Roman';c.barLabels.fontSize=6.5;c.barLabels.nudge=3
    d.add(c);label(d,x,y+h+4,ytitle,6.5)
def legend(d,x,y,items):
    for color,text in items:
        d.add(Rect(x,y-1,6,6,fillColor=HexColor(color),strokeColor=None));label(d,x+9,y,text,7);x+=80

vs=['O0','O1','O2','O3','Os','Oz'];fig=Drawing(522,111.6)
barplot(fig,[[stats[v,'pipeline']['r'+str(i)] for v in vs] for i in [1,2,3]],['-'+v for v in vs],42,17,470,78,1850,500,'GNU RSS (KiB)')
legend(fig,235,102,[(blue,'Trial 1'),(gray,'Trial 2'),(orange,'Trial 3')]);renderSVG.drawToFile(fig,str(OUT/'memory_fig1.svg'))

vs=['O2','shared','dlopen','fully_static'];labels=['Baseline','Shared','Load later','Static'];fig=Drawing(252,216)
label(fig,3,207,'(a) Primary pipeline reported peak',9)
barplot(fig,[[stats[v,'pipeline']['median'] for v in vs]],labels,39,126,205,64,1400,500,'GNU RSS (KiB)',True)
label(fig,3,104,'(b) Separate diagnostic at finished work',9)
barplot(fig,[[phases[v,'finished_work'][key] for v in vs] for key in ['rss_kib','pss_kib']],labels,39,26,205,64,2100,1000,'KiB')
legend(fig,65,4,[(blue,'Snapshot RSS'),(gray,'Snapshot PSS')]);renderSVG.drawToFile(fig,str(OUT/'memory_fig2.svg'))

vs=['O2','workspace','arena','static_storage','packed_record','window50','window25'];labels=['Base','Reuse','Arena','Static','Pack','50','25'];fig=Drawing(252,201.6)
label(fig,3,192,'(a) Explicit memory-unit heap peak',9)
barplot(fig,[[diag[v]['requested_peak_bytes'] for v in vs]],labels,41,117,203,58,6000,2000,'Requested bytes',True)
label(fig,3,94,'(b) Recurring allocation work',9)
barplot(fig,[[diag[v]['allocation_calls'] for v in vs[:4]]],labels[:4],41,20,203,58,29000,10000,'Calls',True)
renderSVG.drawToFile(fig,str(OUT/'memory_fig3.svg'))
node=Path('/Users/matthewketas/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node')
code="import sharp from 'sharp'; import fs from 'node:fs/promises'; for(let i=1;i<=3;i++)await sharp('memory_fig'+i+'.svg',{density:350}).png().toFile('memory_fig'+i+'.png');"
subprocess.run([str(node),'--input-type=module','-e',code],cwd=OUT,check=True)

with zipfile.ZipFile(REF) as z: parts={n:z.read(n) for n in z.namelist()}
root=E.fromstring(parts['word/document.xml']);W=root.nsmap['w'];ns={'w':W};tag=lambda n:'{'+W+'}'+n
body=root.find('w:body',ns)
original_children=list(body)
prototypes={}
for p in body.findall('w:p',ns):
    ps=p.find('w:pPr/w:pStyle',ns)
    if ps is not None:prototypes.setdefault(ps.get(tag('val')),deepcopy(p))
picture=next(deepcopy(p) for p in body.findall('w:p',ns) if p.xpath('.//*[local-name()="drawing"]'))
sectbase=deepcopy(body.findall('.//w:sectPr',ns)[0])
for x in list(body):body.remove(x)

def el(name,**attrs):
    t=E.Element(tag(name))
    for k,v in attrs.items():t.set(tag(k),str(v))
    return t

def paragraph(text='',style='BodyText',size=None,bold=None,italic=None,keep=False):
    source=prototypes.get(style,prototypes['BodyText'])
    p=E.Element(tag('p'));pr=source.find('w:pPr',ns)
    pr=deepcopy(pr) if pr is not None else el('pPr')
    for x in pr.findall('w:sectPr',ns):pr.remove(x)
    p.append(pr)
    sty=pr.find('w:pStyle',ns)
    if sty is None:sty=el('pStyle',val=style);pr.insert(0,sty)
    else:sty.set(tag('val'),style)
    if style in ('Heading1','Heading2','tablehead'):
        for x in pr.findall('w:numPr',ns):pr.remove(x)
        num=el('numPr');num.append(el('numId',val='0'));pr.append(num)
    if keep:pr.append(el('keepNext'))
    r=el('r');rp=source.find('w:r/w:rPr',ns)
    rp=deepcopy(rp) if rp is not None else el('rPr')
    for name in ['sz','szCs','color','rFonts']:
        for node in rp.findall('w:'+name,ns):rp.remove(node)
    rp.append(el('rFonts',ascii='Times New Roman',hAnsi='Times New Roman',cs='Times New Roman'))
    rp.append(el('color',val='000000'))
    if size is None:size=9 if style in ['Abstract','Keywords'] else 8.5 if style=='references' else 10
    rp.append(el('sz',val=int(size*2)));rp.append(el('szCs',val=int(size*2)))
    for name,value in [('b',bold),('i',italic)]:
        if value is not None:
            for node in rp.findall('w:'+name,ns):rp.remove(node)
            rp.append(el(name,val='1' if value else '0'))
    r.append(rp)
    t=el('t');t.set('{http://www.w3.org/XML/1998/namespace}space','preserve');t.text=text;r.append(t);p.append(r)
    return p

def end_section(cols,kind):
    p=paragraph('',size=1);pr=p.find('w:pPr',ns)
    for n in ['spacing','ind']: 
        for x in pr.findall('w:'+n,ns):pr.remove(x)
    pr.append(el('spacing',before=0,after=0,line=20,lineRule='exact'));pr.append(el('ind',firstLine=0))
    sp=deepcopy(sectbase)
    for n in ['type','cols']:
        for x in sp.findall('w:'+n,ns):sp.remove(x)
    sp.append(el('type',val=kind));sp.append(el('cols',num=cols,space=360))
    pr.append(sp);body.append(p)

def caption(text):
    p=paragraph(text,size=9);pr=p.find('w:pPr',ns)
    pr.append(el('ind',firstLine=0));pr.append(el('keepLines'));pr.append(el('spacing',before=3,after=6));body.append(p)

def figure(number,width,height,text):
    p=deepcopy(picture)
    for node in p.findall('w:pPr',ns):p.remove(node)
    pr=el('pPr');pr.extend([el('jc',val='center'),el('ind',firstLine=0),el('spacing',before=4,after=0),el('keepNext')]);p.insert(0,pr)
    # Keep only the drawing run, removing any reference-paper text or floating leftovers.
    for node in list(p):
        if node is not pr and not node.xpath('.//*[local-name()="drawing"]'):p.remove(node)
    cx,cy=str(round(width*914400)),str(round(height*914400))
    for node in p.xpath('.//*[local-name()="extent"]'):
        if 'cx' in node.attrib:node.set('cx',cx);node.set('cy',cy)
    for node in p.xpath('.//*[local-name()="xfrm"]/*[local-name()="ext"]'):
        node.set('cx',cx);node.set('cy',cy)
    for node in p.xpath('.//*[local-name()="srcRect"]'):node.getparent().remove(node)
    for node in p.xpath('.//*[local-name()="docPr"]'):
        node.set('id',str(200+number));node.set('name',f'Memory figure {number}');node.set('descr',text)
    for node in p.xpath('.//*[local-name()="blip"]'):
        attr=next(k for k in node.attrib if E.QName(k).localname=='embed');node.set(attr,f'rIdMemoryFigure{number}')
    body.append(p);caption(text)

def table1():
    p=paragraph('TABLE I  ALL CONFIGURATIONS AND MEDIAN GNU REPORTED PEAK RSS',style='tablehead',size=8,keep=True);body.append(p)
    tbl=el('tbl');prop=el('tblPr');prop.append(el('tblW',w=10440,type='dxa'));prop.append(el('jc',val='center'));prop.append(el('tblLayout',type='fixed'))
    borders=el('tblBorders')
    for side in ['top','left','bottom','right','insideH','insideV']:borders.append(el(side,val='single',sz=4,color='D9D9D9'))
    prop.append(borders)
    margins=el('tblCellMar')
    for side,width in [('top',12),('bottom',12),('left',48),('right',48)]:margins.append(el(side,w=width,type='dxa'))
    prop.append(margins);tbl.append(prop)
    widths=[170,48,48,60,52,86,58]
    grid=el('tblGrid')
    for width in widths:grid.append(el('gridCol',w=int(width*20)))
    tbl.append(grid)
    rows=[['Configuration','I/O','Memory','Compute','Pipeline','Pipeline range','Heap peak\n(bytes)']]
    names={'O2':'-O2 baseline','no_loop_vector':'Disable loop vectorization','no_slp_vector':'Disable SLP vectorization',
           'no_inline':'Disable inlining','gc_sections':'Remove unused sections','no_stack_reuse':'Disable stack reuse',
           'io_context':'Caller-owned I/O state','combined':'Combined candidate (later)'}
    for v in D['order']:
        label=names.get(v,D['labels'][v]);values=[]
        for unit in ['io','memory','compute','pipeline']:
            n=stats[v,unit]['median'];values.append('—' if n is None else f'{n:,}')
        s=stats[v,'pipeline'];rng='—' if s['median'] is None else f'{s["min"]:,}–{s["max"]:,}'
        heap=diag.get(v,{}).get('requested_peak_bytes');heap='n.m.' if heap is None else f'{heap:,}'
        rows.append([label,*values,rng,heap])
    for i,values in enumerate(rows):
        tr=el('tr');trpr=el('trPr');trpr.append(el('cantSplit'))
        if i==0:trpr.append(el('tblHeader'))
        tr.append(trpr)
        for j,text in enumerate(values):
            cell=el('tc');cp=el('tcPr');cp.extend([el('tcW',w=int(widths[j]*20),type='dxa'),el('vAlign',val='center')])
            if i==0:cp.append(el('shd',fill='EFEFEF',val='clear'))
            cell.append(cp)
            p=paragraph(text.replace('\n',' '),size=8,bold=i==0)
            pr=p.find('w:pPr',ns)
            for n in ['spacing','ind','jc']:
                for x in pr.findall('w:'+n,ns):pr.remove(x)
            pr.extend([el('spacing',before=0,after=0,line=190,lineRule='exact'),el('ind',firstLine=0),el('jc',val='left' if j==0 else 'center')])
            cell.append(p);tr.append(cell)
        tbl.append(tr)
    body.append(tbl)
    caption('All RSS values are KiB; n = 3 per measured cell. Heap peaks are requested bytes from separate allocation diagnostics. Ofast failed validation; n.m. means not measured. Smaller-history cases retain their own capacity-specific behavior. Source: [2].')

manuscript=(OUT/'manuscript.md').read_text().splitlines()
author=deepcopy(prototypes['Author'])
for n in author.findall('w:pPr/w:sectPr',ns):n.getparent().remove(n)
for line in manuscript:
    line=line.strip()
    if not line:continue
    if line.startswith('@title '):
        p=paragraph(line[7:],'Title2',size=24)
        p.find('w:pPr/w:pStyle',ns).set(tag('val'),'Title');body.append(p);body.append(author)
        end_section(1,'continuous')
    elif line.startswith('@abstract '):body.append(paragraph(line[10:],'Abstract',bold=True))
    elif line.startswith('@keywords '):body.append(paragraph(line[10:],'Keywords',bold=True,italic=True))
    elif line=='# IV. Data':
        end_section(2,'continuous');body.append(paragraph('IV. Data','Heading1',keep=True))
    elif line=='# V. Results':
        end_section(1,'nextPage');body.append(paragraph('V. Results','Heading1',keep=True))
    elif line.startswith('## '):body.append(paragraph(line[3:],'Heading2',keep=True))
    elif line.startswith('# '):body.append(paragraph(line[2:],'Heading1',keep=True))
    elif line.startswith('@ref '):
        text=line[5:]
        # Match the reference's breakable URLs without changing visible content.
        text=re.sub(r'https://\S+',lambda m:m[0].replace('/','/\u200b').replace('_','_\u200b').replace('-','-\u200b'),text)
        body.append(paragraph(text,'references'))
    elif line=='{{TABLE1}}':table1()
    elif line=='{{FIG1}}':figure(1,7.25,1.55,'Fig. 1. Compiler groups in the integrated pipeline. Grouped bars retain all three repetitions. The axis starts at zero. Ofast is omitted because it failed validation; unit-specific medians appear in Table I.')
    elif line=='{{FIG2}}':figure(2,3.5,3.0,'Fig. 2. Linking comparisons. Panel (a) uses primary screening medians (n = 3). Panel (b) uses one separately instrumented finished-work snapshot per configuration. RSS and PSS answer different questions; the diagnostic GNU peak counters also disagree with the sampled RSS.')
    elif line=='{{FIG3}}':figure(3,3.5,2.8,'Fig. 3. Separate allocation diagnostics for the pipeline. Reuse and partitioning reduce calls without lowering requested peak bytes. Static storage shifts the arrays outside the explicit heap count. Packed records and shorter histories reduce requested storage; history changes the available evidence.')
    else:body.append(paragraph(line))

terminal=deepcopy(sectbase)
for n in ['type','cols']:
    for x in terminal.findall('w:'+n,ns):terminal.remove(x)
terminal.append(el('type',val='nextPage'));terminal.append(el('cols',num=2,space=360));body.append(terminal)
parts['word/document.xml']=E.tostring(root,xml_declaration=True,encoding='UTF-8',standalone=True)
styles=E.fromstring(parts['word/styles.xml'])
existing=styles.find('w:style[@w:styleId="Title"]',ns)
if existing is not None:styles.remove(existing)
st=deepcopy(styles.find('w:style[@w:styleId="Title2"]',ns));st.set(tag('styleId'),'Title');st.find('w:name',ns).set(tag('val'),'Title');styles.append(st)
parts['word/styles.xml']=E.tostring(styles,xml_declaration=True,encoding='UTF-8',standalone=True)
settings=E.fromstring(parts['word/settings.xml'])
update=settings.find('w:updateFields',ns)
if update is None:update=el('updateFields',val='true');settings.append(update)
else:update.set(tag('val'),'true')
parts['word/settings.xml']=E.tostring(settings,xml_declaration=True,encoding='UTF-8',standalone=True)
rels=E.fromstring(parts['word/_rels/document.xml.rels']);R=E.QName(rels).namespace
imtype=next(x.get('Type') for x in rels if x.get('Type','').endswith('/image'))
for i in range(1,4):
    E.SubElement(rels,'{'+R+'}Relationship',Id=f'rIdMemoryFigure{i}',Type=imtype,Target=f'media/memory_fig{i}.png')
    parts[f'word/media/memory_fig{i}.png']=(OUT/f'memory_fig{i}.png').read_bytes()
parts['word/_rels/document.xml.rels']=E.tostring(rels,xml_declaration=True,encoding='UTF-8',standalone=True)
types=E.fromstring(parts['[Content_Types].xml']);T=E.QName(types).namespace
if not any(x.get('Extension')=='png' for x in types):E.SubElement(types,'{'+T+'}Default',Extension='png',ContentType='image/png')
parts['[Content_Types].xml']=E.tostring(types,xml_declaration=True,encoding='UTF-8',standalone=True)
core=E.fromstring(parts['docProps/core.xml'])
dc='{http://purl.org/dc/elements/1.1/}'
core.find(dc+'title').text='Evaluating Memory Reduction for the Critter Embedded System'
parts['docProps/core.xml']=E.tostring(core,xml_declaration=True,encoding='UTF-8',standalone=True)
with zipfile.ZipFile(TARGET,'w',zipfile.ZIP_DEFLATED) as z:
    for n,b in parts.items():z.writestr(n,b)
mutable={'word/document.xml','word/styles.xml','word/settings.xml','word/_rels/document.xml.rels','[Content_Types].xml','docProps/core.xml'}
changed=[n for n,sha in INV['parts'].items() if hashlib.sha256(parts[n]).hexdigest()!=sha]
assert set(changed)<=mutable,changed
headings=[]
for p in body.findall('w:p',ns):
    st=p.find('w:pPr/w:pStyle',ns)
    if st is not None and st.get(tag('val'))=='Heading1':headings.append(''.join(p.xpath('.//w:t/text()',namespaces=ns)))
assert headings==INV['headings'],headings
assert hashlib.sha256(REF.read_bytes()).hexdigest()==INV['sha256']
alltext='\n'.join(root.xpath('//w:t/text()',namespaces=ns))
(OUT/'paper_text.txt').write_text(alltext)
report={'reference_sha256':INV['sha256'],'changed_original_parts':changed,'headings':headings,
        'new_media':3,'sections':len(root.findall('.//w:sectPr',ns)),'word_count':len(alltext.split()),
        'output':str(TARGET),'table_configurations':len(rows) if False else 30}
(OUT/'package_verification.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
