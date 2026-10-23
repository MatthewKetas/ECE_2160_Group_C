"""Create the IEEE Word manuscript from the retained official template package."""
from copy import deepcopy
import csv
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile

from lxml import etree as E
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import FixedLocator, FuncFormatter, NullLocator

HERE=Path(__file__).resolve().parent
OUT=HERE.parent/'Reliability_HW_Ketas_VF.docx'
SOURCE=HERE/'ieee_letter_template.docx'
ASSESSMENT=HERE.parents[2]/'Development/CritterProduct/TimingAssessment'
DATA=ASSESSMENT/'results/review_2026-10-22'
rows=list(csv.DictReader((DATA/'primary_runs.csv').open()))
summary=list(csv.DictReader((DATA/'condition_metrics.csv').open()))
blocks=json.loads((HERE/'manuscript.json').read_text())
assert len(rows)==48 and len(summary)==16
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()=='4589779a1a74782dc5a7a657a9907f243c9dd54510cb6c154acaf24cc9079852'

plt.rcParams.update({'font.family':'serif','font.serif':['Times New Roman','DejaVu Serif'],
    'font.size':8,'axes.labelsize':8,'xtick.labelsize':7.5,'ytick.labelsize':7.5,
    'axes.unicode_minus':False,'savefig.facecolor':'white'})

def tail_figure():
    labels=['Baseline','3 cores','2 cores','1 core','Powersave','Ondemand','RAM 4 GiB',
        'RAM 2 GiB','RAM 1.5 GiB','Network 10M','Network 50M','Pinned quiet',
        'Matrix nice -10','Matrix nice 0','Matrix nice +10','Matrix nice +19']
    fig,ax=plt.subplots(figsize=(3.49,3.55))
    fig.subplots_adjust(left=.34,right=.98,top=.98,bottom=.15)
    colors=['#333333']+['#2b627c']*3+['#5f5675']*2+['#9b6428']*3+['#357769']*2+['#9b4248']*5
    for i,c in enumerate(summary):
        values=[float(r['response_p99_ms']) for r in sorted(rows,key=lambda r:int(r['repetition'])) if r['condition']==c['condition']]
        ax.hlines(i,min(values),max(values),color=colors[i],lw=1,zorder=2)
        ax.plot(np.mean(values),i,marker='D',ms=3.8,color=colors[i],zorder=3)
        for j,(value,marker) in enumerate(zip(values,['o','s','^'])):
            ax.plot(value,i+(j-1)*.16,marker=marker,ms=3.2,mfc='white',mec=colors[i],mew=.65,zorder=4)
    ax.set_xscale('log');ax.set_xlim(.13,5.5);ax.set_ylim(15.7,-.7)
    ax.set_yticks(range(16),labels);ax.tick_params(axis='y',length=0,pad=3)
    ax.xaxis.set_major_locator(FixedLocator([.2,.5,1,2,5]));ax.xaxis.set_major_formatter(FuncFormatter(lambda x,_:f'{x:g}'))
    ax.xaxis.set_minor_locator(NullLocator());ax.set_xlabel('p99 response (ms, logarithmic scale)',labelpad=3)
    baseline=float(summary[0]['response_p99_ms_mean']);quiet=float(summary[11]['response_p99_ms_mean'])
    ax.vlines(baseline,-.5,10.5,colors='#666666',linestyles='--',lw=.6)
    ax.vlines(quiet,10.6,15.5,colors='#9b4248',linestyles='--',lw=.6)
    for sep in [.5,3.5,5.5,8.5,10.5]:ax.axhline(sep,color='#d9d9d9',lw=.45)
    ax.grid(axis='x',color='#dddddd',lw=.45)
    for side in ['top','right','left']:ax.spines[side].set_visible(False)
    ax.spines['bottom'].set_color('#999999')
    fig.savefig(HERE/'paper_tail.png',dpi=450);plt.close(fig)

def stall_figure():
    folder=DATA/'raw/results/main/20261020T041606_669096Z/001_ram_1.5_r1'
    trace=[{k:int(v) for k,v in r.items()} for r in csv.DictReader((folder/'timing.csv').open())]
    window=[r for r in trace if 12.9<=r['release_ns']/1e9<=14.0]
    x=[r['release_ns']/1e9 for r in window]
    y=[(r['finish_ns']-r['release_ns'])/1e6 if r['start_ns']>=0 else np.nan for r in window]
    fig,axes=plt.subplots(2,1,sharex=True,figsize=(3.49,2.55),gridspec_kw={'height_ratios':[1.7,1]})
    fig.subplots_adjust(left=.17,right=.96,top=.96,bottom=.18,hspace=.30)
    axes[0].plot(x,y,'o-',color='#885719',ms=2.7,lw=.85)
    axes[0].axhline(100,color='#9b4248',ls='--',lw=.75)
    axes[0].set_ylim(-28,400);axes[0].set_yticks([0,100,200,300]);axes[0].set_ylabel('Response (ms)',labelpad=3)
    skipped=[r['release_ns']/1e9 for r in trace if r['start_ns']<0]
    axes[0].plot(skipped,[-13]*len(skipped),'x',color='#9b4248',ms=4,mew=1)
    for tick in skipped:
        for ax in axes:ax.axvspan(tick-.008,tick+.008,color='#bc7c7c',alpha=.20)
    axes[0].annotate('345.159',(13.4,345.159),xytext=(3,4),textcoords='offset points',fontsize=7)
    axes[0].annotate('106.222',(13.1,106.222),xytext=(-30,5),textcoords='offset points',fontsize=7)
    acquisitions=[r['acquired_ns']/1e9 for r in trace if r['read_ok']]
    edges=list(zip(acquisitions,acquisitions[1:]));left,right=max(edges,key=lambda e:e[1]-e[0])
    axes[1].eventplot([t for t in acquisitions if 12.9<=t<=14.0],lineoffsets=.35,linelengths=.25,colors='#357769',lw=1)
    axes[1].annotate('',xy=(right,.78),xytext=(left,.78),arrowprops={'arrowstyle':'<->','lw':.65,'color':'#885719'})
    axes[1].text((left+right)/2,.94,'444.746 ms',ha='center',fontsize=7.5,color='#885719')
    axes[1].set_yticks([.35],['Acquired']);axes[1].set_ylim(0,1.2);axes[1].set_xlim(12.9,14.0)
    axes[1].xaxis.set_major_locator(FixedLocator([13.0,13.2,13.4,13.6,13.8,14.0]))
    axes[1].xaxis.set_major_formatter(FuncFormatter(lambda v,_:f'{v:.1f}'))
    axes[1].set_xlabel('Time from collection start (s)',labelpad=3)
    for ax in axes:
        ax.grid(axis='both',color='#dddddd',lw=.4)
        for side in ['top','right']:ax.spines[side].set_visible(False)
        ax.spines['bottom'].set_color('#999999');ax.spines['left'].set_color('#999999')
    fig.savefig(HERE/'paper_stall.png',dpi=450);plt.close(fig)

tail_figure();stall_figure()

with ZipFile(SOURCE) as z:
    parts={info.filename:z.read(info.filename) for info in z.infolist()}
W='http://purl.oclc.org/ooxml/wordprocessingml/main'
R='http://purl.oclc.org/ooxml/officeDocument/relationships'
A='http://purl.oclc.org/ooxml/drawingml/main'
WP='http://purl.oclc.org/ooxml/drawingml/wordprocessingDrawing'
PIC='http://purl.oclc.org/ooxml/drawingml/picture'
REL='http://schemas.openxmlformats.org/package/2006/relationships'
CT='http://schemas.openxmlformats.org/package/2006/content-types'
NS={'w':W}
def w(tag):return '{'+W+'}'+tag
def el(tag,**attrs):
    node=E.Element(w(tag))
    for key,val in attrs.items():node.set(w(key),str(val))
    return node

styles=E.fromstring(parts['word/styles.xml'])
def style(id,name,base='BodyText',size=20,bold=False,italic=False,align='both',first='14.40pt',before='0pt',after='6pt',keep=False,smallcaps=False,outline=None):
    node=el('style',type='paragraph',styleId=id)
    node.append(el('name',val=name));node.append(el('basedOn',val=base));node.append(el('next',val='PaperBody'))
    p=el('pPr');p.append(el('numPr'));p[-1].append(el('numId',val=0))
    p.append(el('spacing',before=before,after=after,line='240',lineRule='auto'))
    p.append(el('ind',start='0pt',end='0pt',firstLine=first));p.append(el('jc',val=align))
    p.append(el('widowControl'))
    if keep:p.append(el('keepNext'))
    if outline is not None:p.append(el('outlineLvl',val=outline))
    node.append(p)
    r=el('rPr');r.append(el('rFonts',ascii='Times New Roman',hAnsi='Times New Roman',cs='Times New Roman',eastAsia='Times New Roman'))
    r.append(el('color',val='000000'));r.append(el('sz',val=size));r.append(el('szCs',val=size))
    if bold:r.append(el('b'))
    if italic:r.append(el('i'))
    if smallcaps:r.append(el('smallCaps'))
    node.append(r);styles.append(node)
    return node

style('Title','Title',base='papertitle',size=48,align='center',first='0pt',after='8pt',keep=True)
style('PaperAuthor','Paper Author',base='Author',size=22,align='center',first='0pt',before='8pt',after='2pt',keep=True)
style('PaperAffiliation','Paper Affiliation',base='Affiliation',size=20,align='center',first='0pt',after='0pt',keep=True)
style('PaperBody','Paper Body',size=20)
style('PaperAbstract','Paper Abstract',base='Abstract',size=18,bold=True,after='8pt')
style('PaperKeywords','Paper Keywords',base='Keywords',size=18,bold=True,italic=True,after='6pt')
style('PaperHeading','Paper Heading',base='Heading1',size=20,align='center',first='0pt',before='8pt',after='4pt',keep=True,smallcaps=True,outline=0)
style('PaperSubheading','Paper Subheading',base='Heading2',size=20,italic=True,align='left',first='0pt',before='6pt',after='3pt',keep=True,outline=1)
style('PaperCaption','Paper Caption',base='figurecaption',size=16,first='0pt',before='4pt',after='8pt')
style('PaperTableHead','Paper Table Head',base='tablehead',size=16,align='center',first='0pt',before='7pt',after='4pt',keep=True,smallcaps=True)
style('PaperTable','Paper Table',base='tablecopy',size=17,align='left',first='0pt',after='0pt')
style('PaperTableNote','Paper Table Note',base='tablecopy',size=15,align='left',first='0pt',before='3pt',after='6pt')
style('PaperReference','Paper Reference',base='references',size=16,first='0pt',after='3pt')

root=E.fromstring(parts['word/document.xml'])
body=root.find('w:body',NS)
for child in list(body):body.remove(child)

def paragraph(text='',style_id='PaperBody',keep=False,indent=None):
    p=el('p');pr=el('pPr');pr.append(el('pStyle',val=style_id))
    if keep:pr.append(el('keepNext'))
    if indent is not None:pr.append(el('ind',firstLine=indent))
    p.append(pr)
    if text:
        for i,line in enumerate(text.split('\n')):
            r=el('r')
            if i:r.append(el('br'))
            t=el('t');t.set('{http://www.w3.org/XML/1998/namespace}space','preserve');t.text=line;r.append(t);p.append(r)
    body.append(p);return p

def section(columns,continuous=False):
    s=el('sectPr')
    if continuous:s.append(el('type',val='continuous'))
    s.append(el('pgSz',w='612pt',h='792pt',code=1))
    margin='44.65pt' if columns==1 else '45.35pt'
    s.append(el('pgMar',top='54pt',bottom='72pt',left=margin,right=margin,header='36pt',footer='36pt',gutter='0pt'))
    s.append(el('cols',num=columns,space='18pt'))
    return s

rels=E.fromstring(parts['word/_rels/document.xml.rels'])
content_types=E.fromstring(parts['[Content_Types].xml'])
if not any(x.get('Extension')=='png' for x in content_types):
    E.SubElement(content_types,'{'+CT+'}Default',Extension='png',ContentType='image/png')

def figure(name,caption,number):
    file=HERE/name
    from PIL import Image
    im=Image.open(file);width=int(3.49*914400);height=round(width*im.height/im.width)
    rid='rIdCritterFigure'+str(number)
    E.SubElement(rels,'{'+REL+'}Relationship',Id=rid,Type=R+'/image',Target='media/'+name)
    parts['word/media/'+name]=file.read_bytes()
    p=paragraph('',keep=True,indent='0pt');p[0].append(el('jc',val='center'))
    p[0].append(el('spacing',before='5pt',after='0pt',line='240',lineRule='auto'))
    run=el('r');drawing=el('drawing');run.append(drawing);p.append(run)
    inline=E.SubElement(drawing,'{'+WP+'}inline',distT='0',distB='0',distL='0',distR='0',nsmap={'wp':WP,'a':A,'pic':PIC})
    E.SubElement(inline,'{'+WP+'}extent',cx=str(width),cy=str(height))
    E.SubElement(inline,'{'+WP+'}effectExtent',l='0',t='0',r='0',b='0')
    E.SubElement(inline,'{'+WP+'}docPr',id=str(100+number),name='Figure '+str(number),descr=caption)
    locks=E.SubElement(inline,'{'+WP+'}cNvGraphicFramePr');E.SubElement(locks,'{'+A+'}graphicFrameLocks',noChangeAspect='1')
    graphic=E.SubElement(inline,'{'+A+'}graphic');gd=E.SubElement(graphic,'{'+A+'}graphicData',uri=PIC)
    pic=E.SubElement(gd,'{'+PIC+'}pic');nv=E.SubElement(pic,'{'+PIC+'}nvPicPr')
    E.SubElement(nv,'{'+PIC+'}cNvPr',id='0',name=name);E.SubElement(nv,'{'+PIC+'}cNvPicPr')
    fill=E.SubElement(pic,'{'+PIC+'}blipFill');blip=E.SubElement(fill,'{'+A+'}blip');blip.set('{'+R+'}embed',rid)
    stretch=E.SubElement(fill,'{'+A+'}stretch');E.SubElement(stretch,'{'+A+'}fillRect')
    sp=E.SubElement(pic,'{'+PIC+'}spPr');xf=E.SubElement(sp,'{'+A+'}xfrm')
    E.SubElement(xf,'{'+A+'}off',x='0',y='0');E.SubElement(xf,'{'+A+'}ext',cx=str(width),cy=str(height))
    geom=E.SubElement(sp,'{'+A+'}prstGeom',prst='rect');E.SubElement(geom,'{'+A+'}avLst')
    paragraph(caption,'PaperCaption')

def table(title,headers,values,widths,note):
    paragraph(title,'PaperTableHead')
    t=el('tbl');pr=el('tblPr');pr.append(el('tblW',w=str(round(sum(widths)*1440)),type='dxa'))
    pr.append(el('jc',val='center'));pr.append(el('tblLayout',type='fixed'))
    margins=el('tblCellMar')
    for side,value in [('top',45),('bottom',45),('start',50),('end',50)]:margins.append(el(side,w=value,type='dxa'))
    pr.append(margins);borders=el('tblBorders')
    for side in ['top','bottom','start','end','insideH','insideV']:borders.append(el(side,val='single',sz=4,color='D9D9D9'))
    pr.append(borders);t.append(pr);grid=el('tblGrid')
    for width in widths:grid.append(el('gridCol',w=round(width*1440)))
    t.append(grid)
    for i,values_row in enumerate([headers]+values):
        row=el('tr');rp=el('trPr');rp.append(el('cantSplit'))
        if i==0:rp.append(el('tblHeader'))
        row.append(rp)
        for j,text in enumerate(values_row):
            cell=el('tc');cp=el('tcPr');cp.append(el('tcW',w=round(widths[j]*1440),type='dxa'));cp.append(el('vAlign',val='center'))
            if i==0:cp.append(el('shd',val='clear',fill='EEEEEE'))
            cell.append(cp)
            p=el('p');pp=el('pPr');pp.append(el('pStyle',val='PaperTable'));pp.append(el('jc',val='left' if j==0 and i else 'center'));p.append(pp)
            for k,line in enumerate(str(text).split('\n')):
                r=el('r')
                if i==0:rr=el('rPr');rr.append(el('b'));r.append(rr)
                if k:r.append(el('br'))
                x=el('t');x.text=line;r.append(x);p.append(r)
            cell.append(p);row.append(cell)
        t.append(row)
    body.append(t);paragraph(note,'PaperTableNote')

label_map={'baseline':'Baseline','cores_3':'3 cores','cores_2':'2 cores','cores_1':'1 core',
 'governor_powersave':'Powersave','governor_ondemand':'Ondemand','ram_4':'RAM 4 GiB',
 'ram_2':'RAM 2 GiB','ram_1.5':'RAM 1.5 GiB','network_rx_10M':'Network 10M',
 'network_rx_50M':'Network 50M','priority_quiet':'Pinned quiet','priority_nice_-10':'Matrix nice -10',
 'priority_nice_0':'Matrix nice 0','priority_nice_10':'Matrix nice +10','priority_nice_19':'Matrix nice +19'}
for kind,text in blocks:
    if kind=='figure_tail':figure('paper_tail.png',text,1)
    elif kind=='figure_stall':figure('paper_stall.png',text,2)
    elif kind=='table_results':
        table('TABLE I\nRESPONSE AND OBSERVATION CONTINUITY',
            ['Condition','Mean\nmedian\n(ms)','Mean\np99\n(ms)','Misses/\n1800','Worst\ngap\n(ms)'],
            [[label_map[r['condition']],f"{float(r['response_median_ms_mean']):.3f}",f"{float(r['response_p99_ms_mean']):.3f}",r['deadline_misses'],f"{float(r['max_acquisition_gap_ms_max']):.3f}"] for r in summary],
            [1.10,.56,.52,.48,.83],
            'Three runs per condition. Responses average run statistics; gap is the worst observed run. Native RAM and performance are supplied by baseline. Matrix stays nice 0. Source: [2].')
    elif kind=='table_ram':
        ram=sorted([r for r in rows if r['condition']=='ram_1.5'],key=lambda r:int(r['repetition']))
        table('TABLE II\nSEVERITY IN THE THREE LOW RAM REPETITIONS',
            ['Run','Misses/\n600','p99\n(ms)','Maximum\nlateness\n(ms)','Maximum\ngap\n(ms)','Longest\nstreak\n(slots)'],
            [[r['repetition'],r['deadline_misses'],f"{float(r['response_p99_ms']):.3f}",f"{float(r['max_observed_lateness_ms']):.3f}",f"{float(r['max_acquisition_gap_ms']):.3f}",r['longest_miss_streak']] for r in ram],
            [.30,.46,.53,.79,.75,.66],
            'All other primary runs had zero maximum lateness and zero missed-slot streaks. Slot period is 100 ms. Source: [2].')
    else:
        sid={'title':'Title','author':'PaperAuthor','affiliation':'PaperAffiliation','abstract':'PaperAbstract',
             'keywords':'PaperKeywords','h1':'PaperHeading','h1plain':'PaperHeading',
             'h2':'PaperSubheading','p':'PaperBody','ref':'PaperReference'}[kind]
        p=paragraph(text,sid)
        if kind=='affiliation' and text=='mtk67@pitt.edu':
            p[0].append(el('spacing',after='6pt'))
            p[0].append(section(1))
        if kind=='h1plain' and text=='References':
            r=el('r');r.append(el('br',type='column'));p.insert(1,r)
        if kind=='h1' and text=='VII. Conclusion':
            p[0].append(el('pageBreakBefore'))
        if kind=='ref':
            p[0].append(el('ind',start='14pt',hanging='14pt'))
body.append(section(2,True))

parts['word/document.xml']=E.tostring(root,xml_declaration=True,encoding='UTF-8',standalone=True)
parts['word/styles.xml']=E.tostring(styles,xml_declaration=True,encoding='UTF-8',standalone=True)
parts['word/_rels/document.xml.rels']=E.tostring(rels,xml_declaration=True,encoding='UTF-8',standalone=True)
parts['[Content_Types].xml']=E.tostring(content_types,xml_declaration=True,encoding='UTF-8',standalone=True)
core=E.fromstring(parts['docProps/core.xml'])
for tag,value in [('{http://purl.org/dc/elements/1.1/}title',blocks[0][1]),
                  ('{http://purl.org/dc/elements/1.1/}creator','Matthew Ketas'),
                  ('{http://schemas.openxmlformats.org/package/2006/metadata/core-properties}lastModifiedBy','Matthew Ketas')]:
    n=core.find(tag)
    if n is None:n=E.SubElement(core,tag)
    n.text=value
parts['docProps/core.xml']=E.tostring(core,xml_declaration=True,encoding='UTF-8',standalone=True)
with ZipFile(OUT,'w') as z:
    from zipfile import ZIP_DEFLATED
    for name,content in parts.items():z.writestr(name,content,compress_type=ZIP_DEFLATED)
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()=='4589779a1a74782dc5a7a657a9907f243c9dd54510cb6c154acaf24cc9079852'
print(OUT)
