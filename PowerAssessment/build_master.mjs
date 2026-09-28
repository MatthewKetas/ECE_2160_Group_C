// Run combine_runs.py first. Requires the bundled @oai/artifact-tool package.
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const out = path.resolve(process.argv[2] || path.join(root, 'outputs/power_master'));
const require = createRequire(path.join(out, 'builder.cjs'));
const { Workbook, SpreadsheetFile } = await import(require.resolve('@oai/artifact-tool'));
const data = JSON.parse(await fs.readFile(path.join(out, 'combined.json'), 'utf8'));
const wb = Workbook.create();
const master = wb.worksheets.add('Run results');
const wide = wb.worksheets.add('T-test columns');
const raw = wb.worksheets.add('Raw samples');
const notes = wb.worksheets.add('Methods');
function col(n) { let s = ''; for (n++; n; n = Math.floor((n-1)/26)) s = String.fromCharCode(65+(n-1)%26)+s; return s; }
function table(sheet, headers, rows, name) {
  const end = col(headers.length - 1), last = rows.length + 1;
  sheet.getRange(`A1:${end}${last}`).values = [headers, ...rows];
  sheet.getRange(`A1:${end}${last}`).format.font = {name:'Arial',size:11,color:'#202B38'};
  sheet.getRange(`A1:${end}${last}`).format.columnWidth = 18;
  sheet.getRange(`A1:${end}${last}`).format.rowHeight = 22;
  sheet.tables.add(`A1:${end}${last}`, true, name);
  sheet.getRange(`A1:${end}1`).format = {fill:'#29445F',font:{bold:true,color:'#FFFFFF'},wrapText:true,rowHeight:44};
  sheet.freezePanes.freezeRows(1);
  sheet.showGridLines = false;
}
table(raw, ['Dataset','Iteration','Source CSV',...data.headers], data.samples, 'RawSamples');
raw.getRange(`D2:${col(data.headers.length+2)}${data.samples.length+1}`).setNumberFormat('0.000000');
raw.getRange('A:A').format.columnWidth = 43;
raw.getRange('C:C').format.columnWidth = 53;
raw.getRange('E:E').format.columnWidth = 25;
const rows = data.runs.map(r => [r.dataset,r.iteration,null,null,60,r.n,null,null,r.source,
  r.dataset.startsWith('comp_') ? 'One run; short prediction unresolved' : r.dataset.startsWith('mem_') ? '60 s window may omit replay ending' : '60 s monitoring window']);
table(master, ['Dataset','Iteration','Mean power (W)','Estimated energy (J)','Nominal window (s)','Sample count','First sample (s)','Last sample (s)','Source CSV under results/','Measurement scope'], rows, 'RunResults');
for (const [i,r] of data.runs.entries()) {
  const n = i+2;
  master.getRange(`C${n}:D${n}`).formulas = [[`=AVERAGE('Raw samples'!F${r.first}:F${r.last})`,`=C${n}*E${n}`]];
  master.getRange(`G${n}:H${n}`).formulas = [[`='Raw samples'!D${r.first}`,`='Raw samples'!D${r.last}`]];
}
master.getRange(`C2:D${rows.length+1}`).setNumberFormat('0.000000');
master.getRange(`G2:H${rows.length+1}`).setNumberFormat('0.000000');
master.getRange('A:A').format.columnWidth = 45;
master.getRange('B:B').format.columnWidth = 11;
master.getRange('I:I').format.columnWidth = 96;
master.getRange('J:J').format.columnWidth = 44;
const groups = [...new Set(data.runs.map(r=>r.dataset))];
const maxRuns = Math.max(...groups.map(g=>data.runs.filter(r=>r.dataset===g).length));
table(wide, ['Iteration',...groups.flatMap(g=>[`${g.replaceAll('_',' ')}\npower (W)`,`${g.replaceAll('_',' ')}\nenergy (J)`])],
  Array.from({length:maxRuns},(_,i)=>[i+1,...Array(groups.length*2).fill(null)]), 'ComparisonColumns');
wide.getRange(`B1:${col(groups.length*2)}1`).format.columnWidth = 29;
wide.getRange(`A1:${col(groups.length*2)}1`).format.rowHeight = 80;
wide.getRange(`B2:${col(groups.length*2)}${maxRuns+1}`).setNumberFormat('0.000000');
for (const [g,dataset] of groups.entries()) {
  const matching = data.runs.map((r,i)=>({r,i})).filter(({r})=>r.dataset===dataset);
  for (const [j,{i}] of matching.entries()) {
    wide.getRange(`${col(1+2*g)}${j+2}:${col(2+2*g)}${j+2}`).formulas = [[`='Run results'!C${i+2}`,`='Run results'!D${i+2}`]];
  }
}
const methodRows = [
 ['Observation unit','One CSV is one run/iteration. Within-run power samples are not independent experimental repetitions.'],
 ['Source','PowerAssessment/results/**/*.csv; dataset names are preserved from source folders. Source filenames are included for every run and sample.'],
 ['Coverage',`${data.runs.length} runs in ${groups.length} datasets; ${data.samples.length} samples. No runs removed and no outlier filtering applied.`],
 ['Power','Arithmetic mean of the 60 recorded pmic_power_watts values. Source power equals the sum of 12 paired current × voltage rail measurements.'],
 ['Energy','Estimated energy (J) = mean power (W) × nominal window (60 s). 1 J = 1 W·s. The 60 s assumption follows baseline_power.py DURATION_SECONDS.'],
 ['Duration limitation','The logger does not save its final elapsed duration. Last sample is near 59 s because it sleeps after that sample. Do not use the last timestamp as full run duration.'],
 ['Measurement scope','PMIC rail power with monitoring overhead; excludes some board loads and conversion losses. No idle subtraction or total USB-C input-power claim.'],
 ['Program timing','Program start/finish markers are absent. Energy describes the monitoring window, not isolated or necessarily complete program execution. Memory replay may extend beyond the window.'],
 ['Compute datasets','Each compute dataset has n=1. A between-run t-test is not supported. One-second sampling cannot resolve the brief prediction call.'],
 ['Using T-test columns','Each dataset has adjacent power and energy columns. Select populated run cells for comparisons; blank cells are missing repetitions, not zeros.'],
 ['Unpaired comparisons','For independent runs, Excel T.TEST(range1,range2,2,3) gives a two-sided Welch test. Iteration numbers indicate chronological order within a dataset, not matched pairs.'],
 ['Equal-duration relationship','All energies equal power × 60, so power and energy comparisons yield the same t-test p-values. They are not independent evidence.'],
 ['Interpretation','Check experimental independence and comparability. Runs on different dates may be confounded by operating conditions. Account for multiple comparisons if testing many pairs.'],
 ['Refresh','Run combine_runs.py, then build_master.mjs. The workbook recalculates from its embedded samples; it does not auto-import new CSV files.'],
 ['Validation','All source rows checked for finite values, 60 samples, increasing timestamps, expected time coverage, and consistency of recorded power with the 12 rail products.'],
 ['Protocol sources','PowerAssessment/baseline_power.py and PowerAssessment/README.md.']
];
table(notes,['Topic','Method and limitations'],methodRows,'MethodsTable');
notes.getRange('A:A').format.columnWidth = 30;
notes.getRange('B:B').format.columnWidth = 115;
notes.getRange(`A2:B${methodRows.length+1}`).format.wrapText = true;
notes.getRange(`A2:B${methodRows.length+1}`).format.rowHeight = 48;
// Independent calculation checks against Python statistics.mean.
for (const [i,r] of data.runs.entries()) {
  const values = master.getRange(`C${i+2}:D${i+2}`).values[0];
  if (Math.abs(values[0]-r.power)>1e-10 || Math.abs(values[1]-r.energy)>1e-8) throw Error(`Calculation mismatch: ${r.source}`);
}
console.log((await wb.inspect({kind:'table',range:"'Run results'!A1:H5",include:'values,formulas',tableMaxRows:5,tableMaxCols:8})).ndjson);
console.log((await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:20},summary:'Formula error scan'})).ndjson);
for (const [sheet,range,file] of [['Run results','A1:H9','runs'],['T-test columns','A1:E9','comparison'],['T-test columns','AB1:AG6','comparison_end'],['Raw samples','A1:F8','raw'],['Methods','A1:B17','methods']]) {
  const preview=await wb.render({sheetName:sheet,range,scale:1,format:'png'});
  await fs.writeFile(path.join(out,`${file}.png`),new Uint8Array(await preview.arrayBuffer()));
}
await (await SpreadsheetFile.exportXlsx(wb)).save(path.join(out,'master_power_energy.xlsx'));
console.log(`Saved ${path.join(out,'master_power_energy.xlsx')}`);
