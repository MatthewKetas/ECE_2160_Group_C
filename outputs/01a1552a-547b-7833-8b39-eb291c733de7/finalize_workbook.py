"""Fill chart export caches from saved cells, preserving their editable references."""
from io import BytesIO
from pathlib import Path
import posixpath
import re
import sys
from zipfile import ZipFile
from lxml import etree as E

path = Path(sys.argv[1])
S = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'
C = 'http://schemas.openxmlformats.org/drawingml/2006/chart'
R = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
ns = dict(s=S,c=C)
with ZipFile(path) as source:
    entries = {info.filename: source.read(info.filename) for info in source.infolist()}
    infos = source.infolist()

strings = []
if 'xl/sharedStrings.xml' in entries:
    strings = [''.join(item.itertext()) for item in E.fromstring(entries['xl/sharedStrings.xml']).findall(f'{{{S}}}si')]
relationships = {r.get('Id'):r.get('Target') for r in E.fromstring(entries['xl/_rels/workbook.xml.rels'])}
cells = {}
for sheet in E.fromstring(entries['xl/workbook.xml']).findall('s:sheets/s:sheet',ns):
    target = relationships[sheet.get(f'{{{R}}}id')]
    name = target.lstrip('/') if target.startswith('/') else posixpath.normpath('xl/'+target)
    values = {}
    for cell in E.fromstring(entries[name]).findall('.//s:sheetData/s:row/s:c',ns):
        value = cell.findtext('s:v',namespaces=ns)
        if cell.get('t') == 's' and value is not None:
            value = strings[int(value)]
        elif cell.get('t') == 'inlineStr':
            value = ''.join(cell.find('s:is',ns).itertext())
        if cell.get('t') == 'e':
            value = None
        values[cell.get('r')] = value
    cells[sheet.get('name')] = values

def referenced(formula):
    match = re.fullmatch(r"(?:'((?:[^']|'')+)'|([^!]+))!\$?([A-Z]+)\$?(\d+):\$?([A-Z]+)\$?(\d+)",formula)
    if not match:
        raise ValueError('Unsupported chart reference: '+formula)
    quoted,plain,start_col,start_row,end_col,end_row=match.groups()
    assert start_col == end_col
    sheet=(quoted.replace("''", "'") if quoted else plain)
    return [cells[sheet].get(start_col+str(row)) for row in range(int(start_row),int(end_row)+1)]

chart_files = [name for name in entries if '/charts/chart' in name and name.endswith('.xml')]
assert len(chart_files) == 7
for name in chart_files:
    root = E.fromstring(entries[name])
    for ref in root.findall('.//c:ser/c:cat/c:strRef',ns)+root.findall('.//c:ser/c:val/c:numRef',ns):
        numeric = E.QName(ref).localname == 'numRef'
        values = referenced(ref.findtext('c:f',namespaces=ns))
        cache = ref.find('c:numCache' if numeric else 'c:strCache',ns)
        format_code = cache.findtext('c:formatCode',namespaces=ns) if numeric else None
        for child in list(cache):
            cache.remove(child)
        if format_code:
            E.SubElement(cache,f'{{{C}}}formatCode').text=format_code
        E.SubElement(cache,f'{{{C}}}ptCount',val=str(len(values)))
        for index,value in enumerate(values):
            if value is None:
                continue
            if numeric:
                float(value)
            point=E.SubElement(cache,f'{{{C}}}pt',idx=str(index))
            E.SubElement(point,f'{{{C}}}v').text=value
    if root.find('.//c:lineChart',ns) is not None:
        chart = root.find('c:chart',ns)
        blanks = chart.find('c:dispBlanksAs',ns)
        if blanks is None:
            blanks = E.Element(f'{{{C}}}dispBlanksAs')
            index = next((i for i, child in enumerate(chart)
                          if E.QName(child).localname in ('showDLblsOverMax','extLst')), len(chart))
            chart.insert(index, blanks)
        blanks.set('val','gap')
    entries[name] = E.tostring(root,xml_declaration=True,encoding='UTF-8',standalone=True)

buffer = BytesIO()
with ZipFile(buffer,'w') as output:
    for info in infos:
        output.writestr(info,entries[info.filename])
path.write_bytes(buffer.getvalue())
print('Verified and populated caches for seven editable Excel charts.')
