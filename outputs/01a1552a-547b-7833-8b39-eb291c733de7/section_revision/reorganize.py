"""Reorganize the user's edited manuscript without rewriting its prose."""
from collections import Counter
from copy import deepcopy
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile

from lxml import etree as E

HERE = Path(__file__).resolve().parent
INVENTORY = json.loads((HERE / 'source_inventory.json').read_text())
SOURCE = Path(INVENTORY['edited_source']['path'])
OUT = HERE.parent / 'Reliability_HW_Ketas_V3.docx'
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest() == INVENTORY['edited_source']['sha256']
with ZipFile(SOURCE) as z:
    parts = {i.filename: z.read(i.filename) for i in z.infolist()}
root = E.fromstring(parts['word/document.xml'])
W = root.nsmap['w']
NS = {'w': W}
q = lambda name: '{' + W + '}' + name
body = root.find('w:body', NS)
original = list(body)
output = []

def text(n):
    return ''.join(n.xpath('.//w:t/text()', namespaces=NS))

def style(n):
    s = n.find('w:pPr/w:pStyle', NS)
    return s.get(q('val')) if s is not None else ''

def add(*indices):
    output.extend(deepcopy(original[i]) for i in indices)

def heading(index, label, subsection=False):
    n = deepcopy(original[index])
    ts = n.findall('.//w:t', NS)
    ts[0].text = label
    for t in ts[1:]:
        t.text = ''
    pr = n.find('w:pPr', NS)
    pr.find('w:pStyle', NS).set(q('val'), 'PaperSubheading' if subsection else 'PaperHeading')
    for br in n.findall('.//w:br', NS):
        if br.get(q('type')) in ('column', 'page'):
            br.getparent().remove(br)
    for br in pr.findall('w:pageBreakBefore', NS):
        pr.remove(br)
    output.append(n)

def new_body(content):
    n = deepcopy(original[81])
    ts = n.findall('.//w:t', NS)
    ts[0].text = content
    for t in ts[1:]:
        t.text = ''
    output.append(n)

def column_break():
    n = E.Element(q('p'))
    pr = E.SubElement(n, q('pPr'))
    spacing = E.SubElement(pr, q('spacing'))
    for k, v in [('before', '0'), ('after', '0'), ('line', '20'), ('lineRule', 'exact')]:
        spacing.set(q(k), v)
    run = E.SubElement(n, q('r'))
    E.SubElement(run, q('br')).set(q('type'), 'column')
    output.append(n)

add(*range(8))
heading(8, 'I. Introduction')
add(9, 11)

heading(12, 'II. Background')
heading(13, 'A. The Critter and the evaluation objective', True)
add(10, 14)
heading(18, 'B. Timing reliability and severity measures', True)
add(19, 20, 21)

heading(12, 'III. Approach')
heading(13, 'A. Prototype and scheduled workload', True)
add(15, 16, 17)
heading(22, 'B. Conditions and controls', True)
add(23, 24, 25, 26)
heading(27, 'C. Repetitions and evidence selection', True)
add(28, 29)

heading(30, 'IV. Data')
add(*range(31, 37), 39, 40, 37, 38, *range(41, 54))

heading(54, 'V. Results')
add(*range(55, 68))
heading(68, 'E. Broader Embedded Systems Implications', True)
add(*range(69, 73))
heading(73, 'F. Limitations and Further Validation', True)
add(74, 75, 76)

heading(77, 'VI. Conclusion')
add(78, 79)
heading(82, 'References')
add(*range(83, 88))
column_break()
add(*range(88, 93))
heading(80, 'Acknowledgements')
add(81)
heading(82, 'Source Outlines')
outlines = [
    'Course context and prior work [1], [3]. The assignment establishes the Critter product and the timing-predictability question. The prior power paper provides the resource-reduction context and the need to validate timing before deployment.',
    'Experimental evidence [2]. The annotated workbook, raw timing archive, collector, analysis tools, and prototype source support the measurements and interpretations. These records distinguish attempted jobs, skipped releases, dispatch delay, and delays within I/O.',
    'Timing and platform documentation [4]–[8]. The Linux and iperf3 documentation supports the descriptions of absolute waits, process-level resource measurements, CPU governors, receive traffic, and ordinary scheduling preference. The reported timing values come from the Critter experiments.',
    'Broader embedded-system reasoning [9], [10]. Holzmann provides the memory-allocation guideline discussed in the recurring path. The closed-loop pacemaker study supports considering temporal requirements in the device’s operating environment. Neither source turns the Critter measurements into a hard real-time guarantee.',
]
for outline in outlines:
    new_body(outline)
add(len(original) - 1)

for n in output:
    if style(n) == 'PaperCaption':
        pr = n.find('w:pPr', NS)
        if pr.find('w:keepLines', NS) is None:
            E.SubElement(pr, q('keepLines'))

def preserved_xml(n):
    node = deepcopy(n)
    if style(node) == 'PaperCaption':
        for keep in node.findall('w:pPr/w:keepLines', NS):
            keep.getparent().remove(keep)
    return E.tostring(node, method='c14n', exclusive=True)

def preserved_content(nodes):
    return Counter(preserved_xml(n) for n in nodes
                   if n.tag != q('sectPr') and style(n) not in ('PaperHeading', 'PaperSubheading'))

before = preserved_content(original)
after = preserved_content(output)
missing = before - after
assert not missing, 'A source content element was changed or lost'
assert sum((after - before).values()) == len(outlines) + 1, 'Unexpected added content'
headings = [text(n) for n in output if style(n) == 'PaperHeading']
expected = ['I. Introduction', 'II. Background', 'III. Approach', 'IV. Data', 'V. Results',
            'VI. Conclusion', 'References', 'Acknowledgements', 'Source Outlines']
assert headings == expected

for n in list(body):
    body.remove(n)
for n in output:
    body.append(n)
parts['word/document.xml'] = E.tostring(root, xml_declaration=True, encoding='UTF-8', standalone=True)
with ZipFile(OUT, 'w') as z:
    from zipfile import ZIP_DEFLATED
    for name, data in parts.items():
        z.writestr(name, data, compress_type=ZIP_DEFLATED)

with ZipFile(OUT) as z:
    assert z.testzip() is None
    for name, digest in INVENTORY['edited_source']['parts'].items():
        if name != 'word/document.xml':
            assert hashlib.sha256(z.read(name)).hexdigest() == digest, name
for role, info in INVENTORY.items():
    assert hashlib.sha256(Path(info['path']).read_bytes()).hexdigest() == info['sha256'], role

report = {
    'output': str(OUT), 'main_headings': headings,
    'all_original_non_heading_content_and_run_formatting_preserved': True,
    'layout_only_changes': ['Keep figure captions intact', 'Move Figure 1 after its discussion', 'Balance ending columns'],
    'unchanged_other_package_parts': len(parts) - 1,
    'added_source_outline_paragraphs': len(outlines),
    'tables': len(root.findall('.//w:tbl', NS)),
    'drawings': len(root.findall('.//w:drawing', NS)),
}
(HERE / 'preservation_report.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
