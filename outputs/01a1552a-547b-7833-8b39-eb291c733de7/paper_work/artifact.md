# IEEE manuscript execution contract

Reference: ieee_letter_template.docx in this directory, downloaded from IEEE's
official widen.net template asset. Retain unchanged. The reference has three
rendered pages and seven sections, including placeholder six-author columns.
Reference renders: template_render/page-1.png through page-3.png, all inspected.

Page system: US Letter portrait, 612 by 792 points. Top margin 54 pt, bottom
72 pt. Body margins 45.35 pt; full-width title margin 44.65 pt. Two equal body
columns separated by 18 pt. No running header, footer, page number, funding box,
or copyright placeholder belongs in this course submission. The full-width
single-author title block replaces all six placeholder author slots. The final
body stays in two columns. These section substitutions are required by the
single-author content, following the template's author-count guidance.

Typography: Times New Roman, black. Title 24 pt centered, using Word Title style
derived from template papertitle. Author 11 pt, affiliations 10 pt centered.
Body 10 pt justified, 14.4 pt first-line indent, single line spacing. Abstract
9 pt bold, keywords 9 pt bold italic. Major headings 10 pt centered small caps,
8 pt before and 4 pt after; Roman numeral prefixes are explicit manuscript text.
Subheadings 10 pt italic left, 6 pt before and 3 pt after. Figure captions and
references 8 pt; tables 8.5 pt. Figures use 8 pt axis labels at one-column width.

Slot map: replace every template body paragraph, sample table, drawing, author
placeholder, example citation and instruction with the new manuscript. Reuse the
title, author, body, heading, caption, table and reference roles above. Add two
original data figures and three compact numerical comparison tables. Figures and
captions must remain together; table headers repeat and rows do not split.

Package preservation: begin from a copy of the reference ZIP. Preserve its
styles, font table, theme, settings, numbering and other ancillary parts unless
a change is needed for the manuscript. Add named manuscript styles to the
existing style part; do not replace the original styles. Edit document.xml,
document relationships, content types and core metadata; add figure media.
Original template footer/footnote funding furniture is removed from the body and
section references so it does not appear. Retained unused parts are not content.

Fidelity gates: verify original reference SHA256 unchanged; verify Letter page
geometry and two body columns, black Times typography, no placeholder content,
no clipping, no broken tables or figures, readable captions, and no blank pages.
Render every final page with the packaged render_docx.py and inspect the PNGs.
