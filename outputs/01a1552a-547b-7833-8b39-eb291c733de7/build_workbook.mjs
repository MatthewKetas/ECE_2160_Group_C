import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
import {Workbook, SpreadsheetFile} from '@oai/artifact-tool';

const outputDir = path.dirname(fileURLToPath(import.meta.url));
const data = JSON.parse(await fs.readFile(path.join(outputDir, 'source_data.json'), 'utf8'));
const wb = Workbook.create();
const charts = wb.worksheets.add('Charts');
const conditions = wb.worksheets.add('Conditions');
const runs = wb.worksheets.add('Runs');
const stall = wb.worksheets.add('Stall detail');
const ink = '#22384F', blue = '#287DB5', teal = '#419C85', amber = '#D59A45';
const palette = [blue, teal, amber, ink];
const firstRow = 7, lastRow = firstRow + data.runs.length - 1;
const cols = [
  ['cohort','Cohort'], ['condition','Condition'], ['repetition','Run'], ['status','Status'],
  ['duration_s','Duration (s)'], ['deadline_miss_pct','Deadline miss rate'],
  ['response_median_ms','Median response (ms)'], ['response_p99_ms','p99 response (ms)'],
  ['max_observed_lateness_ms','Max lateness (ms)'], ['max_acquisition_gap_ms','Max acquisition gap (ms)'],
  ['longest_miss_streak','Longest miss streak (slots)'], ['scheduled_cycles','Scheduled slots'],
  ['deadline_misses','Missed slots'], ['skipped_cycles','Skipped slots'], ['operation_failures','Operation failures'],
  ['source','Input source'], ['schedule','Schedule'], ['period_ms','Period (ms)'], ['deadline_ms','Deadline (ms)'],
  ['ram_gib','RAM label'], ['cores','Online cores'], ['governor','Governor'], ['nice','Critter nice'],
  ['pinned','Pinned to CPU0'], ['matrix','Matrix competitor'], ['network_mbit','Network target (Mbit/s)'],
  ['core_method','Core method'], ['started_utc','Started (UTC)'], ['source_run','Source run'],
  ['binary_sha256','Binary SHA256'], ['input_sha256','Input SHA256'], ['error','Run error'],
  ['restoration_error','Restoration error'], ['start_delay_p99_ms','p99 start delay (ms)'],
  ['work_p99_ms','p99 work time (ms)'], ['process_major_faults','Process major faults'],
  ['process_involuntary_switches','Involuntary switches'], ['process_max_rss_kib','Peak RSS (KiB)'],
  ['process_minor_faults','Process minor faults'], ['finished_utc','Finished (UTC)']
];
const colName = n => {let s=''; for(n++;n;n=Math.floor((n-1)/26))s=String.fromCharCode(65+(n-1)%26)+s;return s;};
const rawCol = key => colName(cols.findIndex(c=>c[0]===key));
const sourceRange = key => `'Runs'!$${rawCol(key)}$${firstRow}:$${rawCol(key)}$${lastRow}`;

for (const sheet of [charts, conditions, runs, stall]) sheet.showGridLines = false;
charts.tabColor=ink;
conditions.tabColor='#7189A0';
stall.tabColor='#B06A26';

function title(sheet, cell, text) {
  const r=sheet.getRange(cell); r.values=[[text]];
  r.format.font={name:'Arial',size:16,bold:true,color:ink};
}
function header(sheet, address) {
  const r=sheet.getRange(address);
  r.format.fill=ink;
  r.format.font={name:'Arial',size:10,bold:true,color:'#FFFFFF'};
  r.format.wrapText=true;
  r.format.horizontalAlignment='center';
  r.format.verticalAlignment='center';
  r.format.rowHeight=35;
}
function noteArea(sheet, row, end='R') {
  sheet.getRange(`B${row}`).values=[['Your interpretation (type in the shaded rows below)']];
  sheet.getRange(`B${row}`).format.font={name:'Arial',size:10,bold:true,color:ink};
  const area=sheet.getRange(`B${row+1}:${end}${row+3}`);
  area.format.fill='#FFF5D8';
  area.format.font={name:'Arial',size:10,color:'#244B70'};
  area.format.wrapText=false;
  area.format.borders={preset:'outside',style:'thin',color:'#DDC995'};
}

// Original per-run records. Percentages become numeric Excel fractions once here.
runs.getRange(`A1:AN${lastRow}`).format.font={name:'Arial',size:10,color:ink};
runs.getRange(`A1:AN${lastRow}`).format.rowHeight=21;
runs.getRange(`A1:AN${lastRow}`).format.verticalAlignment='center';
runs.getRange('A:AN').format.columnWidth=17;
runs.getRange('A:A').format.columnWidth=18;
runs.getRange('B:B').format.columnWidth=25;
runs.getRange('C:D').format.columnWidth=10;
runs.getRange('F:K').format.columnWidth=20;
runs.getRange('AB:AB').format.columnWidth=22;
runs.getRange('AC:AC').format.columnWidth=67;
runs.getRange('AD:AE').format.columnWidth=70;
runs.getRange('AF:AG').format.columnWidth=60;
runs.getRange('AN:AN').format.columnWidth=22;
title(runs,'A2','Critter experiment run data');
runs.getRange('A3').values=[['Source: critter-timing-results.tar.gz, recorded on the Raspberry Pi 5. Cohort identifies what is plotted.']];
runs.getRange('A4').values=[[`Archive SHA256: ${data.manifest.archive_sha256}`]];
runs.getRange(`A6:AN6`).values=[cols.map(c=>c[1])];
const rawValues=data.runs.map(row=>cols.map(([key])=>{
  const value=row[key]??null;
  if(value!==null && key==='deadline_miss_pct')return value/100;
  if(value!==null && (key==='started_utc'||key==='finished_utc'))return new Date(value);
  return value;
}));
runs.getRange(`A${firstRow}:AN${lastRow}`).values=rawValues;
const table=runs.tables.add(`A6:AN${lastRow}`,true,'ExperimentRuns');
header(runs,'A6:AN6');
runs.getRange(`F${firstRow}:F${lastRow}`).setNumberFormat('0.00%');
runs.getRange(`G${firstRow}:J${lastRow}`).setNumberFormat('0.000');
runs.getRange(`K${firstRow}:O${lastRow}`).setNumberFormat('0');
runs.getRange(`AH${firstRow}:AI${lastRow}`).setNumberFormat('0.000');
runs.getRange(`AB${firstRow}:AB${lastRow}`).setNumberFormat('yyyy-mm-dd hh:mm:ss');
runs.getRange(`AN${firstRow}:AN${lastRow}`).setNumberFormat('yyyy-mm-dd hh:mm:ss');
runs.getRange(`F${firstRow}:F${lastRow}`).conditionalFormats.add('cellIs',{
  operator:'greaterThan',formula:0,format:{fill:'#FFF0DB',font:{color:'#9B5612',bold:true}}
});
runs.getRange(`D${firstRow}:D${lastRow}`).conditionalFormats.add('containsText',{
  text:'failed',format:{fill:'#FBE7E7',font:{color:'#A52F38',bold:true}}
});
runs.freezePanes.freezeRows(6);
runs.freezePanes.freezeColumns(4);

const metricSpecs=[
 ['deadline_miss_pct','Deadline-miss percentage','0.00%','Scheduled jobs missed (%)',
  'Misses include late, unsuccessful and skipped jobs. Mean averages the three whole-run miss rates.'],
 ['response_median_ms','Median response time','0.000','Median response (ms)',
  'Response includes dispatch delay and acquisition, saving and filtering. Lower is better.'],
 ['response_p99_ms','p99 response time','0.000','p99 response (ms)',
  'p99 covers attempted jobs; skipped releases have no response value. The mean averages the three run p99s.'],
 ['max_observed_lateness_ms','Maximum deadline overrun','0.00','Lateness beyond deadline (ms)',
  'Each run maximum is the largest max(0, response - 100 ms) among attempted jobs.'],
 ['max_acquisition_gap_ms','Maximum acquisition gap','0.000','Maximum acquisition gap (ms)',
  'Gap includes collection boundaries. The nominal acquisition period is 100 ms.'],
 ['longest_miss_streak','Longest consecutive miss sequence','0.00','Longest sequence (scheduled slots)',
  'Each run has an integer streak. A fractional mean is the average of the three run maxima.']
];
const shortLabels=['Base','Cores\n3','Cores\n2','Cores\n1','Gov\npower','Gov\non-demand',
 'RAM\n4 GiB','RAM\n2 GiB','RAM\n1.5 GiB','Net\n10M','Net\n50M','Pinned\nquiet',
 'Nice\n-10','Nice\n0','Nice\n+10','Nice\n+19'];
const conditionOrder=data.conditions.map(c=>c.condition);
const completeNames=data.conditions.map(c=>c.label);
const expectedChecks=[];
const chartBindings=[];

conditions.getRange('A1:I149').format.font={name:'Arial',size:10,color:ink};
conditions.getRange('A1:I149').format.rowHeight=23;
conditions.getRange('A1:I149').format.verticalAlignment='center';
conditions.getRange('A:A').format.columnWidth=25;
conditions.getRange('B:B').format.columnWidth=15;
conditions.getRange('C:C').format.columnWidth=10;
conditions.getRange('D:I').format.columnWidth=16;
title(conditions,'A2','Values behind the charts');
conditions.getRange('A4').values=[['Only primary cohort rows enter these calculations. Each condition has three 60-second runs.']];
conditions.getRange('A5').values=[['Source: Runs worksheet. The mean is not a pooled percentile; min/max describe observed runs, not confidence bounds.']];
conditions.getRange('A4:I5').format.font={name:'Arial',size:10,color:'#566B80'};

charts.getRange('A1:S237').format.font={name:'Arial',size:10,color:ink};
charts.getRange('A1:S237').format.rowHeight=22;
charts.getRange('A:S').format.columnWidthPx=63;
charts.getRange('A:A').format.columnWidthPx=24;
title(charts,'B2','Critter timing experiment review');
charts.getRange('B4').values=[['Primary runs']];
charts.getRange('D4').formulas=[[`=COUNTIF(${sourceRange('cohort')},"primary")`]];
charts.getRange('F4').values=[['Conditions']];
charts.getRange('H4').formulas=[[`=COUNTA('Conditions'!A12:A27)`]];
charts.getRange('J4').values=[['Duration (s)']];
charts.getRange('L4').formulas=[[`=AVERAGEIF(${sourceRange('cohort')},"primary",${sourceRange('duration_s')})`]];
charts.getRange('N4').values=[['Deadline (ms)']];
charts.getRange('P4').formulas=[[`=AVERAGEIF(${sourceRange('cohort')},"primary",${sourceRange('deadline_ms')})`]];
charts.getRange('B5').values=[['Bars show runs 1, 2, 3 and their mean. All axes are linear; lower is better for every metric.']];
charts.getRange('B6').values=[['Use Conditions for exact values; Runs retains earlier valid runs, failures and smoke checks. Shaded rows are for your analysis.']];
charts.getRange('B7').values=[['Base: 4 cores, native RAM, performance, quiet network. Nice rows: Critter and matrix share CPU0; matrix stays nice 0.']];
charts.getRange('B5:R6').format.font={name:'Arial',size:10,color:'#566B80'};
charts.getRange('B7:R7').format.font={name:'Arial',size:10,color:'#566B80'};

for(let i=0;i<metricSpecs.length;i++){
  const [key,label,numberFormat,axisTitle,definition]=metricSpecs[i];
  const top=8+i*23, heading=top+3, first=heading+1, last=first+15;
  conditions.getRange(`A${top}`).values=[[label]];
  conditions.getRange(`A${top}:I${top}`).format.fill='#E8EFF6';
  conditions.getRange(`A${top}:I${top}`).format.font={name:'Arial',size:12,bold:true,color:ink};
  conditions.getRange(`A${top+1}`).values=[[key==='deadline_miss_pct'?'Numeric Excel percentages; 1.00% means six misses among 600 scheduled slots.':`Unit: ${axisTitle}.`]];
  conditions.getRange(`A${heading}:I${heading}`).values=[['Condition','Chart label','Runs','Run 1','Run 2','Run 3','Mean','Minimum','Maximum']];
  header(conditions,`A${heading}:I${heading}`);
  conditions.getRange(`A${first}:B${last}`).values=conditionOrder.map((c,k)=>[c,shortLabels[k]]);
  conditions.getRange(`B${first}:B${last}`).format.wrapText=true;
  conditions.getRange(`A${first}:I${last}`).format.rowHeight=30;
  const metricRange=sourceRange(key), cohortRange=sourceRange('cohort'), condRange=sourceRange('condition');
  const repRange=sourceRange('repetition');
  const formulas=[];
  for(let j=0;j<16;j++){
    const row=first+j;
    const runValue=rep=>`=IF(COUNTIFS(${cohortRange},"primary",${condRange},$A${row},${repRange},${rep})=1,SUMIFS(${metricRange},${cohortRange},"primary",${condRange},$A${row},${repRange},${rep}),NA())`;
    formulas.push([`=COUNTIFS(${cohortRange},"primary",${condRange},$A${row})`,runValue(1),runValue(2),runValue(3),
      `=AVERAGE(D${row}:F${row})`,`=MIN(D${row}:F${row})`,`=MAX(D${row}:F${row})`]);
    const divisor=key==='deadline_miss_pct'?100:1;
    expectedChecks.push({address:`G${row}`,expected:Number(data.conditions[j][key+'_mean'])/divisor,metric:key,condition:conditionOrder[j]});
  }
  conditions.getRange(`C${first}:I${last}`).formulas=formulas;
  conditions.getRange(`C${first}:C${last}`).setNumberFormat('0');
  conditions.getRange(`D${first}:I${last}`).setNumberFormat(numberFormat);
  conditions.getRange(`D${first}:I${last}`).format.horizontalAlignment='right';
  conditions.getRange(`A${first}:I${last}`).conditionalFormats.add('expression',{
    formula:`=MOD(ROW(),2)=0`,format:{fill:'#F3F6FA'}
  });
  const chart=charts.charts.add('bar',[
    conditions.getRange(`B${heading}:B${last}`),
    conditions.getRange(`D${heading}:D${last}`),conditions.getRange(`E${heading}:E${last}`),
    conditions.getRange(`F${heading}:F${last}`),conditions.getRange(`G${heading}:G${last}`)
  ]);
  chart.barOptions.direction='column';
  chart.barOptions.grouping='clustered';
  chart.barOptions.gapWidth=70;
  chart.title=label;
  chart.titleTextStyle.typeface='Arial';
  chart.titleTextStyle.fontSize=17;
  chart.legend={position:'top',textStyle:{typeface:'Arial',fontSize:12}};
  chart.xAxis={axisType:'textAxis',tickLabelInterval:1,textStyle:{typeface:'Arial',fontSize:12}};
  chart.yAxis={numberFormatCode:numberFormat,numberFormatSourceLinked:false,
    textStyle:{typeface:'Arial',fontSize:12},majorGridlines:{fill:'#D8E1EB',width:.7}};
  chart.yAxis.title.text=axisTitle;
  chart.series.items.forEach((s,k)=>s.fill=palette[k]);
  const r=8+i*38;
  chart.setPosition(`B${r}`,`S${r+28}`);
  charts.getRange(`B${r+29}`).values=[[definition]];
  charts.getRange(`B${r+29}`).format.font={name:'Arial',size:10,color:'#566B80'};
  noteArea(charts,r+31);
  chartBindings.push({title:label,series:chart.series.items.map(s=>({formula:s.formula,categories:s.categoryFormula}))});
}

// Recorded job timestamps for the affected run, plus a native zoomed line chart.
stall.getRange('A1:R655').format.font={name:'Arial',size:10,color:ink};
stall.getRange('A1:R655').format.rowHeight=22;
stall.getRange('A:M').format.columnWidth=15;
stall.getRange('N:N').format.columnWidth=4;
stall.getRange('O:R').format.columnWidth=17;
title(stall,'B2','The 1.5 GiB stall');
stall.getRange('B4').values=[['First run: six misses, including two late attempts and four skipped releases. Longest sequence: four slots.']];
stall.getRange('B5').values=[['Maximum response 345.159 ms; maximum lateness 245.159 ms; acquisition gap 444.746 ms.']];
stall.getRange('B6').values=[['A 0.497 ms p99 did not describe the rare stall. The chart leaves skipped slots as gaps.']];
const traceHeader=45, traceFirst=46, traceLast=645;
const traceKeys=['slot','release_ns','start_ns','acquired_ns','saved_ns','finish_ns','read_ok','save_ok','filter_ok'];
stall.getRange(`A${traceHeader}:M${traceHeader}`).values=[['Slot','Release (ns)','Start (ns)','Acquired (ns)','Saved (ns)','Finish (ns)','Read OK','Save OK','Filter OK','Release (s)','Response (ms)','Miss (0/1)','Skip (0/1)']];
stall.getRange(`A${traceFirst}:I${traceLast}`).values=data.trace.map(r=>traceKeys.map(k=>r[k]));
const traceFormulas=data.trace.map((_,i)=>{
  const r=traceFirst+i;
  return [`=B${r}/1000000000`,`=IF(C${r}<0,NA(),(F${r}-B${r})/1000000)`,
    `=IF(C${r}<0,1,IF(OR(G${r}=0,H${r}=0,I${r}=0,F${r}-B${r}>100000000),1,0))`,`=IF(C${r}<0,1,0)`];
});
stall.getRange(`J${traceFirst}:M${traceLast}`).formulas=traceFormulas;
header(stall,`A${traceHeader}:M${traceHeader}`);
stall.getRange(`A${traceFirst}:I${traceLast}`).setNumberFormat('0');
stall.getRange(`J${traceFirst}:J${traceLast}`).setNumberFormat('0.0');
stall.getRange(`K${traceFirst}:K${traceLast}`).setNumberFormat('0.000');
stall.getRange(`L${traceFirst}:M${traceLast}`).setNumberFormat('0');
stall.getRange(`L${traceFirst}:L${traceLast}`).conditionalFormats.add('cellIs',{
  operator:'greaterThan',formula:0,format:{fill:'#FBE7E7',font:{bold:true,color:'#A52F38'}}
});
stall.getRange('O8:Q8').values=[['Release (s)','Response (ms)','Deadline (ms)']];
header(stall,'O8:Q8');
const windowFormulas=[];
for(let slot=126;slot<=144;slot++){
  const r=traceFirst+slot;
  windowFormulas.push([`=J${r}`,`=K${r}`,100]);
}
stall.getRange('O9:P27').formulas=windowFormulas.map(r=>r.slice(0,2));
stall.getRange('Q9:Q27').values=windowFormulas.map(r=>[r[2]]);
stall.getRange('O9:O27').setNumberFormat('0.0');
stall.getRange('P9:Q27').setNumberFormat('0.000');
const detail=stall.charts.add('line',stall.getRange('O8:Q27'));
detail.title='Response near the missed deadlines';
detail.titleTextStyle.typeface='Arial';detail.titleTextStyle.fontSize=17;
detail.legend={position:'top',textStyle:{typeface:'Arial',fontSize:12}};
detail.xAxis={axisType:'textAxis',tickLabelInterval:2,numberFormatCode:'0.0',numberFormatSourceLinked:false,textStyle:{typeface:'Arial',fontSize:12}};
detail.yAxis={numberFormatCode:'0',numberFormatSourceLinked:false,textStyle:{typeface:'Arial',fontSize:12}};
detail.xAxis.title.text='Time from collection start (s)';detail.yAxis.title.text='Response (ms)';
detail.series.items[0].line={fill:'#B06820',style:'solid',width:2};
detail.series.items[1].line={fill:'#B34E59',style:'dashed',width:1.5};
detail.setPosition('B8','M32');
stall.getRange('B33').values=[['#N/A is intentional for the four skipped slots: there is no response-time measurement to plot.']];
stall.getRange('B34').values=[['The full 600-slot trace starts at row 45. Memory capacity alone is not a proven cause of this event.']];
noteArea(stall,36,'M');
stall.getRange('B42').values=[['Source: main/20261020T041606_669096Z/001_ram_1.5_r1/timing.csv from the archive named in Runs.']];

// Brief method notes stay with the condition calculations rather than a separate tab.
conditions.getRange('A146').values=[['Primary set: completed 30-run native-RAM campaign plus six 3-run core/RAM blocks. Earlier interrupted-session runs stay separate.']];
conditions.getRange('A148').values=[['Primary: 48 completed runs, 16 conditions, three runs each. Earlier valid: 18. Failed attempts: 2. Smoke: 13.']];
conditions.getRange('A150').values=[['Core/RAM blocks used separate boots. Three minutes per condition do not establish a hard timing bound.']];
conditions.getRange('A152').values=[['Compare cores/governors/RAM/network with baseline; compare priority against pinned quiet and matrix nice 0.']];
conditions.getRange('A154').values=[['Input was a fixed 22.5 C CSV. Timing does not establish physical sensor freshness or prediction accuracy.']];
conditions.getRange('A156').values=[['The low-RAM event occurred in one run. The workbook preserves it without asserting a single cause.']];

wb.recalculate();
const checks=[];
for(const check of expectedChecks){
  const actual=conditions.getRange(check.address).values[0][0];
  if(typeof actual!=='number'||Math.abs(actual-check.expected)>1e-9){
    throw new Error(`Value mismatch ${check.metric} ${check.condition}: ${actual} vs ${check.expected}`);
  }
  checks.push({address:check.address,value:actual});
}
const counts=charts.getRange('D4:P4').values[0];
if(counts[0]!==48||counts[4]!==16||counts[8]!==60||counts[12]!==100)throw new Error(`Header counts: ${JSON.stringify(counts)}`);
const primaryRowIndex=data.runs.findIndex(r=>r.cohort==='primary'&&r.condition==='priority_nice_19'&&r.repetition===1);
const rawMedianCell=`G${firstRow+primaryRowIndex}`;
const rawMedian=runs.getRange(rawMedianCell).values[0][0];
const medianMeanCell=expectedChecks.find(c=>c.metric==='response_median_ms'&&c.condition==='priority_nice_19').address;
const before=conditions.getRange(medianMeanCell).values[0][0];
runs.getRange(rawMedianCell).values=[[rawMedian+3]];
wb.recalculate();
const changed=conditions.getRange(medianMeanCell).values[0][0];
if(Math.abs(changed-before-1)>1e-9)throw new Error('Formula update did not reach chart data');
runs.getRange(rawMedianCell).values=[[rawMedian]];
wb.recalculate();
if(Math.abs(conditions.getRange(medianMeanCell).values[0][0]-before)>1e-9)throw new Error('Temporary change not restored');

const errorScan=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#NUM!|#NULL!|#SPILL!|#CALC!',
  options:{useRegex:true,maxResults:100},summary:'Unexpected formula errors'});
console.log(errorScan.ndjson);
const previewSpecs=[['Charts','A1:S44','charts_preview.png'],['Conditions','A1:I29','conditions_preview.png'],
 ['Runs','A1:P15','runs_preview.png'],['Stall detail','A1:Q42','stall_preview.png']];
for(const [sheetName,range,file] of previewSpecs){
  const preview=await wb.render({sheetName,range,scale:1.25,format:'png'});
  await fs.writeFile(path.join(outputDir,file),new Uint8Array(await preview.arrayBuffer()));
}
const exported=await SpreadsheetFile.exportXlsx(wb);
await exported.save(path.join(outputDir,'critter_timing_review.xlsx'));
execFileSync('/Users/matthewketas/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3',
  [path.join(outputDir,'finalize_workbook.py'),path.join(outputDir,'critter_timing_review.xlsx')],{stdio:'inherit'});
await fs.writeFile(path.join(outputDir,'verification.json'),JSON.stringify({
  verifiedMeans:checks.length,headerCounts:{primary:48,conditions:16,duration_s:60,deadline_ms:100},
  inputChangeRecalculation:'passed; original values restored',nativeCharts:7,chartBindings,
  deliberateMissingResponses:{raw:4,chartWindow:4},errorScan:errorScan.ndjson
},null,2));
console.log(JSON.stringify({file:path.join(outputDir,'critter_timing_review.xlsx'),verifiedMeans:checks.length,nativeCharts:7}));
