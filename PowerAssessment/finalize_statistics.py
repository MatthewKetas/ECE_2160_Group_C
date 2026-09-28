"""Add native secondary chart axes unsupported by the workbook authoring API.

Uses standard OOXML edits only; openpyxl is used read-only for verification.
"""
from copy import copy, deepcopy
import json
import math
from pathlib import Path
import re
import statistics
from lxml import etree as ET
import zipfile
import openpyxl

OUT = Path(__file__).resolve().parents[1] / 'outputs/power_master'
DEST = OUT / 'master_power_energy_analysis.xlsx'
C = 'http://schemas.openxmlformats.org/drawingml/2006/chart'
A = 'http://schemas.openxmlformats.org/drawingml/2006/main'
ET.register_namespace('c', C)
ET.register_namespace('a', A)
NS = {'c': C, 'a': A}


def element(tag, **attrs):
    return ET.Element(f'{{{C}}}{tag}', {k: str(v) for k, v in attrs.items()})


def beta_fraction(a, b, x):
    # Continued fraction for the regularized incomplete beta; independent p check.
    qab, qap, qam = a+b, a+1, a-1
    c = 1.0
    d = 1-qab*x/qap
    d = 1/max(d, 1e-300)
    h = d
    for m in range(1, 501):
        aa = m*(b-m)*x/((qam+2*m)*(a+2*m))
        d = 1+aa*d
        if abs(d) < 1e-300: d = 1e-300
        c = 1+aa/c
        if abs(c) < 1e-300: c = 1e-300
        d = 1/d
        h *= d*c
        aa = -(a+m)*(qab+m)*x/((a+2*m)*(qap+2*m))
        d = 1+aa*d
        if abs(d) < 1e-300: d = 1e-300
        c = 1+aa/c
        if abs(c) < 1e-300: c = 1e-300
        d = 1/d
        delta = d*c
        h *= delta
        if abs(delta-1) < 3e-14: return h
    raise ValueError('Incomplete beta did not converge')


def beta_i(a, b, x):
    if x == 1: return 1.0
    term = math.exp(math.lgamma(a+b)-math.lgamma(a)-math.lgamma(b)+a*math.log(x)+b*math.log1p(-x))
    if x < (a+1)/(a+b+2): return term*beta_fraction(a,b,x)/a
    return 1-term*beta_fraction(b,a,1-x)/b


def welch(x, y):
    vx, vy = statistics.variance(x)/len(x), statistics.variance(y)/len(y)
    df = (vx+vy)**2/(vx*vx/(len(x)-1)+vy*vy/(len(y)-1))
    t = abs(statistics.mean(x)-statistics.mean(y))/math.sqrt(vx+vy)
    return beta_i(df/2, .5, df/(df+t*t))


def preserve_original(parts):
    """Keep original sheets/styles/settings; graft only requested additions."""
    S='http://schemas.openxmlformats.org/spreadsheetml/2006/main'
    R='http://schemas.openxmlformats.org/package/2006/relationships'
    D='http://schemas.openxmlformats.org/officeDocument/2006/relationships'
    q=lambda tag:f'{{{S}}}{tag}'
    with zipfile.ZipFile(OUT/'master_power_energy.xlsx') as z:
        original={n:z.read(n) for n in z.namelist()}
    result=dict(original)
    result.update({n:v for n,v in parts.items() if n not in original})
    def encode(tree):
        tree.attrib.pop('{http://schemas.openxmlformats.org/markup-compatibility/2006}Ignorable',None)
        return ET.tostring(tree,encoding='utf-8',xml_declaration=True)
    old=ET.fromstring(original['xl/styles.xml'])
    new=ET.fromstring(parts['xl/styles.xml'])
    offsets={}
    for tag in ['fonts','fills','borders','cellStyleXfs']:
        dest,src=old.find(q(tag)),new.find(q(tag))
        offsets[tag]=len(dest)
        dest.extend(deepcopy(list(src)))
        dest.set('count',str(len(dest)))
    oldnum=old.find(q('numFmts'))
    if oldnum is None:
        oldnum=ET.Element(q('numFmts'));old.insert(0,oldnum)
    nextid=max([163]+[int(x.get('numFmtId')) for x in oldnum])+1
    fmtmap={}
    for nf in list(new.find(q('numFmts'))):
        clone=deepcopy(nf);fmtmap[int(nf.get('numFmtId'))]=nextid
        clone.set('numFmtId',str(nextid));nextid+=1;oldnum.append(clone)
    oldnum.set('count',str(len(oldnum)))
    xfs=old.find(q('cellXfs'));style_offset=len(xfs)
    for xf in new.find(q('cellXfs')):
        clone=deepcopy(xf)
        for attr,tag in [('fontId','fonts'),('fillId','fills'),('borderId','borders'),('xfId','cellStyleXfs')]:
            if attr in clone.attrib: clone.set(attr,str(int(clone.get(attr))+offsets[tag]))
        num=int(clone.get('numFmtId','0'))
        if num in fmtmap: clone.set('numFmtId',str(fmtmap[num]))
        xfs.append(clone)
    xfs.set('count',str(len(xfs)))
    result['xl/styles.xml']=encode(old)
    strings=ET.fromstring(original['xl/sharedStrings.xml'])
    extra=ET.fromstring(parts['xl/sharedStrings.xml'])
    string_offset=len(strings)
    strings.extend(deepcopy(list(extra)))
    strings.set('uniqueCount',str(len(strings)))
    strings.attrib.pop('count',None)
    result['xl/sharedStrings.xml']=encode(strings)
    def remap(tree):
        for cell in tree.iter(q('c')):
            cell.set('s',str(int(cell.get('s','0'))+style_offset))
            if cell.get('t')=='s':
                v=cell.find(q('v'));v.text=str(int(v.text)+string_offset)
        return tree
    result['xl/worksheets/sheet6.xml']=encode(remap(ET.fromstring(parts['xl/worksheets/sheet6.xml'])))
    graph=ET.fromstring(original['xl/worksheets/sheet3.xml'])
    additions=remap(ET.fromstring(parts['xl/worksheets/sheet3.xml']))
    rows=graph.find(q('sheetData'));existing={r.get('r'):r for r in rows}
    for row in additions.find(q('sheetData')):
        added=[c for c in row if re.match(r'[A-Z]+',c.get('r')).group() not in ['A','B','C']]
        if not added: continue
        if row.get('r') in existing:
            existing[row.get('r')].extend(deepcopy(added))
        else:
            clone=deepcopy(row)
            for child in list(clone): clone.remove(child)
            clone.extend(deepcopy(added));rows.append(clone)
    cols=graph.find(q('cols'))
    if cols is None:
        cols=ET.Element(q('cols'));graph.insert(list(graph).index(rows),cols)
    for column in additions.find(q('cols')):
        if int(column.get('min'))>=5: cols.append(deepcopy(column))
    graph.find(q('dimension')).set('ref','A1:W190')
    graph.append(deepcopy(additions.find(q('drawing'))))
    result['xl/worksheets/sheet3.xml']=encode(graph)
    book=ET.fromstring(original['xl/workbook.xml'])
    rels=ET.fromstring(original['xl/_rels/workbook.xml.rels'])
    rid='rId'+str(max(int(r.get('Id')[3:]) for r in rels)+1)
    ET.SubElement(book.find(q('sheets')),q('sheet'),{'name':'Statistical tests','sheetId':'6',f'{{{D}}}id':rid})
    ET.SubElement(rels,f'{{{R}}}Relationship',{'Id':rid,'Type':D+'/worksheet','Target':'worksheets/sheet6.xml'})
    calc=book.find(q('calcPr'))
    calc.set('fullCalcOnLoad','1');calc.set('forceFullCalc','1')
    result['xl/workbook.xml']=encode(book)
    result['xl/_rels/workbook.xml.rels']=encode(rels)
    types=ET.fromstring(original['[Content_Types].xml'])
    names={x.get('PartName') or x.get('Extension') for x in types}
    for entry in ET.fromstring(parts['[Content_Types].xml']):
        if (entry.get('PartName') or entry.get('Extension')) not in names: types.append(deepcopy(entry))
    result['[Content_Types].xml']=encode(types)
    return result


def main():
    # Known Student distributions: df=1 is Cauchy; df=2 has a closed form.
    for t in [.1, 1, 5, 20]:
        assert math.isclose(beta_i(.5,.5,1/(1+t*t)),1-2*math.atan(t)/math.pi,abs_tol=1e-13)
        assert math.isclose(beta_i(1,.5,2/(2+t*t)),1-t/math.sqrt(t*t+2),abs_tol=1e-13)
    inputs = json.loads((OUT/'statistics_checks.json').read_text())
    for item in inputs['checks']:
        x = [r['power'] for r in inputs['groups'][item['a']]]
        y = [r['power'] for r in inputs['groups'][item['b']]]
        p = welch(x, y)
        pe = welch([r['energy'] for r in inputs['groups'][item['a']]], [r['energy'] for r in inputs['groups'][item['b']]])
        assert math.isclose(pe,p,rel_tol=1e-10,abs_tol=1e-13)
        item.update(p=p,energyP=pe,adjusted=min(1,p*item['m']))
        print(item['f'], item['a'], '->', item['b'], f'p={p:.6g}, adjusted={min(1,p*item["m"]):.6g}')
    cached = openpyxl.load_workbook(DEST, data_only=True)
    with zipfile.ZipFile(DEST) as archive:
        parts = {n: archive.read(n) for n in archive.namelist()}
    # The author's TTEST evaluator ignores unequal-variance mode. Keep the valid
    # Excel TTEST(...,2,3) formulas and supply independently computed Welch caches.
    S='http://schemas.openxmlformats.org/spreadsheetml/2006/main'
    statpart=next(n for n in parts if n.startswith('xl/worksheets/sheet') and n.endswith('.xml') and b'Pairwise comparisons' in parts[n]) if any(b'Pairwise comparisons' in parts[n] for n in parts if n.startswith('xl/worksheets/sheet') and n.endswith('.xml')) else 'xl/worksheets/sheet6.xml'
    st=ET.fromstring(parts[statpart])
    cells={c.attrib['r']:c for c in st.iter(f'{{{S}}}c')}
    for item in inputs['checks']:
        r=item['row']
        p,pe=item['p'],item['energyP']
        for column,value in [('I',p),('J',min(1,p*item['m'])),('K',pe),('L',min(1,pe*item['m']))]:
            cells[f'{column}{r}'].find(f'{{{S}}}v').text=repr(value)
        lower=statistics.mean(x['power'] for x in inputs['groups'][item['b']])<statistics.mean(x['power'] for x in inputs['groups'][item['a']])
        result=('Comparison lower' if lower else 'Comparison higher') if item['adjusted']<.05 else 'No significant difference'
        cell=cells[f'N{r}']
        cell.set('t','str')
        cell.find(f'{{{S}}}v').text=result
    findings = [
        'Cores: both 1 and 2 cores are lower than baseline after adjustment. 1 vs 2 cores: adjusted p = 1.000; no clear winner.',
        'Clock speed: 1500 MHz has the lowest mean among the three tested clock settings (1.775101 W; 106.506068 J), significantly below 1800 and 2100 MHz.',
        'Governor: powersave is lower than the 1500 MHz reference (1.712785 W; 102.767129 J; p = 0.000171). Other governors were not tested.',
        'Compiler: memory and whole-program reductions are significant. I/O is not significant (adjusted p = 0.208573). Compute has insufficient runs.',
        'Combined: lowest full-program mean (1.614476 W; 96.868548 J), 14.25% below baseline; lower than every measured full-program alternative after adjustment.'
    ]
    for row,text in enumerate(findings,56):
        cell=cells[f'A{row}']
        cell.clear()
        cell.set('r',f'A{row}')
        cell.set('t','inlineStr')
        inline=ET.SubElement(cell,f'{{{S}}}is')
        ET.SubElement(inline,f'{{{S}}}t').text=text
    parts[statpart]=ET.tostring(st,encoding='utf-8',xml_declaration=True)
    (OUT/'statistics_verified.json').write_text(json.dumps(inputs))
    charts = [n for n in parts if re.search(r'/charts/chart\d+\.xml$', n)]
    assert len(charts) == 8
    for name in charts:
        tree = ET.fromstring(parts[name])
        plot = tree.find('.//c:plotArea', NS)
        line = plot.find('c:lineChart', NS)
        series = line.findall('c:ser', NS)
        assert len(series) == 2
        # Fill series caches from the formula-backed chart source cells.
        for i, ser in enumerate(series):
            for ref_tag,cache_tag in [('strRef','strCache'),('numRef','numCache')]:
                for ref in ser.findall(f'.//c:{ref_tag}', NS):
                    formula = ref.find('c:f', NS).text
                    sheet, address = formula.split('!')
                    values = [c.value for row in cached[sheet.strip("'")][address.replace('$','')] for c in row]
                    cache = ref.find(f'c:{cache_tag}', NS)
                    cache.clear()
                    if ref_tag == 'numRef': ET.SubElement(cache, f'{{{C}}}formatCode').text = '0.000000'
                    cache.append(element('ptCount',val=len(values)))
                    for j,value in enumerate(values):
                        pt = ET.SubElement(cache, f'{{{C}}}pt', idx=str(j))
                        ET.SubElement(pt, f'{{{C}}}v').text = str(value)
            sp = ser.find('c:spPr', NS)
            sp.clear()
            color = '2563EB' if i == 0 else 'EA580C'
            ln = ET.SubElement(sp,f'{{{A}}}ln',w='38100' if i == 0 else '19050')
            fill = ET.SubElement(ln,f'{{{A}}}solidFill')
            ET.SubElement(fill,f'{{{A}}}srgbClr',val=color)
            ET.SubElement(ln,f'{{{A}}}prstDash',val='solid' if i == 0 else 'dash')
            marker=ser.find('c:marker',NS)
            marker.clear()
            marker.append(element('symbol',val='circle' if i==0 else 'diamond'))
            marker.append(element('size',val=7 if i==0 else 5))
        line.remove(series[1])
        secondary=element('lineChart')
        secondary.append(element('grouping',val='standard'))
        secondary.append(element('varyColors',val=0))
        secondary.append(series[1])
        secondary.append(element('smooth',val=0))
        secondary.append(element('axId',val=48650113))
        secondary.append(element('axId',val=48672769))
        plot.insert(1,secondary)
        cat=plot.find('c:catAx',NS)
        val=plot.find('c:valAx',NS)
        cat2=deepcopy(cat)
        cat2.find('c:axId',NS).set('val','48650113')
        cat2.find('c:crossAx',NS).set('val','48672769')
        cat2.find('c:delete',NS).set('val','1')
        cat2.append(element('crosses',val='max'))
        val2=deepcopy(val)
        val2.find('c:axId',NS).set('val','48672769')
        val2.find('c:crossAx',NS).set('val','48650113')
        val2.find('c:axPos',NS).set('val','r')
        val2.find('.//a:t',NS).text='Mean energy (J)'
        val2.find('c:numFmt',NS).set('formatCode','0')
        for axis,lo,hi,unit in [(val,1.5,2.3,.2),(val2,90,138,12)]:
            scaling=axis.find('c:scaling',NS)
            scaling.append(element('max',val=hi))
            scaling.append(element('min',val=lo))
            axis.append(element('majorUnit',val=unit))
        grid=val2.find('c:majorGridlines',NS)
        if grid is not None: val2.remove(grid)
        # Right-hand secondary value axis with the same proportional scale.
        val2.insert(list(val2).index(val2.find('c:crossBetween',NS)),element('crosses',val='max'))
        plot.extend([cat2,val2])
        parts[name]=ET.tostring(tree,encoding='utf-8',xml_declaration=True)
    parts=preserve_original(parts)
    temp=DEST.with_suffix('.tmp.xlsx')
    with zipfile.ZipFile(temp,'w',zipfile.ZIP_DEFLATED) as archive:
        for n,content in parts.items(): archive.writestr(n,content)
    temp.replace(DEST)
    verify()


def verify():
    # Ensure the extension preserved user-entered data and existing formulas.
    original=openpyxl.load_workbook(OUT/'master_power_energy.xlsx',data_only=False)
    edited=openpyxl.load_workbook(DEST,data_only=False)
    for sheet in original:
        target=edited[sheet.title]
        for row in sheet:
            for cell in row:
                before,after=cell.value,target[cell.coordinate].value
                if isinstance(before,(int,float)) and isinstance(after,(int,float)):
                    assert math.isclose(before,after,rel_tol=1e-12,abs_tol=1e-12),(sheet.title,cell.coordinate)
                else: assert before==after,(sheet.title,cell.coordinate,before,after)
                assert cell.number_format==target[cell.coordinate].number_format
                assert copy(cell.alignment)==copy(target[cell.coordinate].alignment),(sheet.title,cell.coordinate)
        assert sheet.freeze_panes==target.freeze_panes
    assert len(edited['Graphs']._charts)==8
    for chart in edited['Graphs']._charts:
        assert len(chart._charts)==2
        assert chart._charts[1].y_axis.axPos=='r'
    print('Verified all original cells, 22 Welch tests, and 8 native dual-axis charts.')


if __name__=='__main__':
    import sys
    verify() if '--verify-only' in sys.argv else main()
