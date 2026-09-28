// Extend the user's saved workbook; original workbook remains unchanged.
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const out=path.join(root,'outputs/power_master');
const require=createRequire(path.join(out,'builder.cjs'));
const {Workbook,SpreadsheetFile,FileBlob}=await import(require.resolve('@oai/artifact-tool'));
const wb=await SpreadsheetFile.importXlsx(await FileBlob.load(path.join(out,'master_power_energy.xlsx')));
const runs=wb.worksheets.getItem('Run results');
const original=runs.getRange('A2:J85').values;
const groups=new Map();
original.forEach((r,i)=>{ if(!groups.has(r[0]))groups.set(r[0],[]);groups.get(r[0]).push({row:i+2,power:r[2],energy:r[3]}); });
const stats=wb.worksheets.add('Statistical tests');
function header(sheet,range){sheet.getRange(range).format={fill:'#29445F',font:{name:'Arial',size:11,bold:true,color:'#FFFFFF'},wrapText:true,rowHeight:42};}
stats.getRange('A1').values=[['Power and energy comparisons']];
stats.getRange('A1').format.font={name:'Arial',size:15,bold:true};
stats.getRange('A2:B2').values=[['Significance level',0.05]];
stats.getRange('A3').values=[['Two-sided Welch tests on independent run means. Bonferroni adjustment within each numbered question; power and energy are redundant endpoints.']];
stats.getRange('A4').values=[['Negative change means the comparison uses less power/energy than the reference. “No significant difference” does not establish equivalence.']];
stats.getRange('A5').values=[['Three-core data omitted as requested. Compute n=1 is descriptive only. Governor labels follow the README protocol, not recorded telemetry.']];
stats.getRange('A6').values=[['Energy is estimated over 60 seconds, not isolated full-program energy. Differences across dates/settings do not by themselves establish causation.']];
stats.getRange('A8:H8').values=[['Dataset','Runs (n)','Mean power (W)','Power SD (W)','Mean energy (J)','Energy SD (J)','Source rows','Scope']];
header(stats,'A8:H8');
const refs={};
let sr=9;
for(const [name,items] of groups){
 const first=items[0].row,last=items.at(-1).row;
 const p=`'Run results'!C${first}:C${last}`,e=`'Run results'!D${first}:D${last}`;
 refs[name]={r:sr,p,e,n:items.length};
 stats.getRange(`A${sr}:H${sr}`).values=[[name,null,null,null,null,null,`Run results ${first}–${last}`,name.startsWith('comp_')?'n=1; no inferential test':'60 s PMIC window']];
 stats.getRange(`B${sr}:F${sr}`).formulas=[[`=COUNT(${p})`,`=AVERAGE(${p})`,items.length>1?`=STDEV(${p})`:'="Not estimable"',`=AVERAGE(${e})`,items.length>1?`=STDEV(${e})`:'="Not estimable"']];
 sr++;
}
const base='program_baseline',one='program_one_core',two='program_two_cores';
const all='program_optimized_all_power_save_applie';
const pairs=[];
function pair(f,a,b,note=''){pairs.push({f,a,b,note});}
function allPairs(f,gs){for(let i=0;i<gs.length;i++)for(let j=i+1;j<gs.length;j++)pair(f,gs[i],gs[j]);}
allPairs('1 Cores',[base,one,two]);
allPairs('2 Clock speed',[base,'program_1500','program_1800','program_2100']);
pair('3 Governor','program_1500','program_1500_powersave_gov','Performance vs powersave at nominal 1500 MHz; protocol labels. No other governors measured.');
for(const prefix of ['IO_','mem_','comp_',''])pair('4 Compiler',`${prefix}program_baseline`,`${prefix}program_optimized`,prefix==='comp_'?'n=1 per group; short compute call unresolved':'Baseline vs optimized variant; individual edits within each variant cannot be isolated.');
for(const name of [base,one,two,'program_1500','program_1800','program_2100','program_1500_powersave_gov','program_optimized','no_program_baseline'])pair('5 Combined',name,all,name==='no_program_baseline'?'Idle reference only; not an alternative running-program configuration.':'Combined configuration vs tested full-program setting.');
const counts={};for(const q of pairs)if(refs[q.a].n>1&&refs[q.b].n>1)counts[q.f]=(counts[q.f]||0)+1;
stats.getRange('A28').values=[['Pairwise comparisons']];
stats.getRange('A29:O29').values=[['Question','Reference','Comparison','n reference','n comparison','Power change (W)','Power change (%)','Energy change (J)','Power p','Power adjusted p','Energy p','Energy adjusted p','Tests in family','Adjusted result','Context']];
header(stats,'A29:O29');
const checks=[];
for(const [i,q] of pairs.entries()){
 const row=30+i,a=refs[q.a],b=refs[q.b],valid=a.n>1&&b.n>1;
 stats.getRange(`A${row}:O${row}`).values=[[q.f,q.a,q.b,null,null,null,null,null,null,null,null,null,counts[q.f],null,q.note]];
 stats.getRange(`D${row}:H${row}`).formulas=[[`=B${a.r}`,`=B${b.r}`,`=C${b.r}-C${a.r}`,`=F${row}/C${a.r}`,`=E${b.r}-E${a.r}`]];
 if(valid){
  stats.getRange(`I${row}:L${row}`).formulas=[[`=TTEST(${a.p},${b.p},2,3)`,`=MIN(1,I${row}*M${row})`,`=TTEST(${a.e},${b.e},2,3)`,`=MIN(1,K${row}*M${row})`]];
  stats.getRange(`N${row}`).formulas=[[`=IF(J${row}<$B$2,IF(F${row}<0,"Comparison lower","Comparison higher"),"No significant difference")`]];
  checks.push({...q,row,p:stats.getRange(`I${row}`).values[0][0],adjusted:stats.getRange(`J${row}`).values[0][0],energyP:stats.getRange(`K${row}`).values[0][0],m:counts[q.f]});
 }else{stats.getRange(`I${row}:L${row}`).values=[['Not estimable','Not estimable','Not estimable','Not estimable']];stats.getRange(`N${row}`).values=[['Insufficient runs']];}
}
const last=29+pairs.length;
stats.tables.add(`A29:O${last}`,true,'PairwiseTests');
header(stats,'A29:O29');
stats.getRange(`A8:O${last}`).format.font.name='Arial';
stats.getRange(`A8:O${last}`).format.font.size=11;
stats.getRange(`A30:O${last}`).format.rowHeight=58;
stats.getRange(`A30:C${last}`).format.wrapText=true;
stats.getRange(`N30:O${last}`).format.wrapText=true;
stats.getRange('A:A').format.columnWidth=45;
stats.getRange('B:C').format.columnWidth=42;
stats.getRange('D:M').format.columnWidth=18;
stats.getRange('N:N').format.columnWidth=27;
stats.getRange('O:O').format.columnWidth=65;
stats.getRange('C9:F24').setNumberFormat('0.000000');
stats.getRange(`F30:F${last}`).setNumberFormat('0.000000');
stats.getRange(`G30:G${last}`).setNumberFormat('0.00%');
stats.getRange(`H30:H${last}`).setNumberFormat('0.000000');
stats.getRange(`I30:L${last}`).setNumberFormat('0.000E+00');
stats.getRange('B2').setNumberFormat('0.00');
stats.showGridLines=false;
stats.freezePanes.freezeRows(8);
stats.getRange(`A${last+3}`).values=[['Interpretation and experiment limits']];
const conclusions=[
 'Cores: compare 1 and 2 cores with the 4-core baseline labeled in your Graphs sheet. No three-core result is inferred.',
 'Clock speed: “best” means lowest observed PMIC power / 60 s energy among measured settings, not best throughput or energy per completed task. Baseline clock is not recorded.',
 'Governor: only the 1500 MHz reference and powersave condition are available. The performance label is inferred from the README commands; actual frequency was not logged.',
 'Compiler: compare each unit to its own baseline and the whole program to its own baseline. These runs cannot isolate the effects of individual assembly edits.',
 'Combined: includes every measured full-program setting plus idle as context. The folder label identifies the combined treatment; the data do not independently verify which peripherals were disabled.',
 'Adjustment: Bonferroni p = MIN(1, raw p × number of estimable tests in that question). Five question families are exploratory; there is no overall correction across all five.',
 'Power and energy: energy = power × 60, so p-values and rankings coincide. Do not count the two endpoints as independent confirmation.',
 'Design: runs were collected sequentially across different dates. Temperature, workload, background activity and other conditions may confound treatment differences.',
 'Sources: embedded Run results and Raw samples; PowerAssessment/README.md for protocol labels. Existing Graphs A1:C22 is retained unchanged.'
];
for(const [i,t] of conclusions.entries())stats.getRange(`A${last+4+i}`).values=[[t]];
const graphs=wb.worksheets.getItem('Graphs');
const specs=[
 {title:'Core count',list:[[one,'1 core'],[two,'2 cores'],[base,'Baseline (4 cores)']],note:'Three cores not measured. Means of independent runs.'},
 {title:'Core clock speed',list:[['program_1500','1500 MHz'],['program_1800','1800 MHz'],['program_2100','2100 MHz'],[base,'Baseline clock unlogged']],note:'Baseline clock is unknown; measured settings are nominal caps.'},
 {title:'Governor at nominal 1500 MHz',list:[['program_1500','Performance (protocol)'],['program_1500_powersave_gov','Powersave']],note:'Two measured conditions; actual clock/governor not in CSV.'},
 {title:'I/O compiler optimization',list:[['IO_program_baseline','Baseline'],['IO_program_optimized','Optimized']],note:'Compare I/O with its own baseline.'},
 {title:'Memory compiler optimization',list:[['mem_program_baseline','Baseline'],['mem_program_optimized','Optimized']],note:'60-second monitoring window may omit replay ending.'},
 {title:'Compute compiler optimization (n=1)',list:[['comp_program_baseline','Baseline'],['comp_program_optimized','Optimized']],note:'Descriptive only. Insufficient runs for a t-test.'},
 {title:'Whole-program compiler optimization',list:[[base,'Baseline'],['program_optimized','Optimized']],note:'Compare whole-program variants with each other.'},
 {title:'Combined optimizations vs measured settings',list:[[base,'Baseline'],[one,'1 core'],[two,'2 cores'],['program_1500','1500'],['program_1800','1800'],['program_2100','2100'],['program_1500_powersave_gov','Powersave'],['program_optimized','Compiler'],[all,'Combined'],['no_program_baseline','Idle']],note:'Idle is context only. Combined folder defines the treatment.'}
];
graphs.getRange('E:E').format.columnWidth=31;
graphs.getRange('F:G').format.columnWidth=19;
graphs.getRange('H:H').format.columnWidth=10;
graphs.getRange('I:I').format.columnWidth=24;
for(const [i,spec] of specs.entries()){
 const top=1+i*24,start=top+3,end=start+spec.list.length-1;
 graphs.getRange(`E${top}`).values=[[spec.title]];
 graphs.getRange(`E${top}`).format.font={name:'Arial',size:13,bold:true};
 graphs.getRange(`E${top+2}:I${top+2}`).values=[['Condition','Mean power (W)','Mean energy (J)','Runs (n)','Source summary row']];header(graphs,`E${top+2}:I${top+2}`);
 for(const [j,[name,label]] of spec.list.entries()){
  const r=start+j,s=refs[name].r;
  graphs.getRange(`E${r}:I${r}`).values=[[label,null,null,null,`Statistical tests ${s}`]];
  graphs.getRange(`F${r}:H${r}`).formulas=[[`='Statistical tests'!C${s}`,`='Statistical tests'!E${s}`,`='Statistical tests'!B${s}`]];
 }
 graphs.getRange(`E${start}:I${end}`).format.rowHeight=34;
 graphs.getRange(`E${start}:E${end}`).format.wrapText=true;
 graphs.getRange(`F${start}:G${end}`).setNumberFormat('0.000000');
 graphs.getRange(`E${end+2}`).values=[[spec.note]];
 graphs.getRange(`E${end+3}`).values=[['Energy = power × 60 s; both traces express the same result.']];
 const chart=graphs.charts.add('line',graphs.getRange(`E${top+2}:G${end}`));
 chart.title=spec.title;chart.titleTextStyle.typeface='Arial';chart.titleTextStyle.fontSize=16;
 chart.legend={position:'top',textStyle:{typeface:'Arial',fontSize:11}};
 chart.xAxis={axisType:'textAxis',textStyle:{typeface:'Arial',fontSize:10}};
 chart.yAxis={title:'Mean power (W)',numberFormatCode:'0.00',numberFormatSourceLinked:false,textStyle:{typeface:'Arial',fontSize:11}};
 chart.series.items[0].fill='#2563EB';chart.series.items[1].fill='#EA580C';
 chart.setPosition(`K${top}`,`W${top+21}`);
}
await fs.writeFile(path.join(out,'statistics_checks.json'),JSON.stringify({groups:Object.fromEntries(groups),checks,specs}));
console.log((await wb.inspect({kind:'table',range:"'Statistical tests'!D30:N32",include:'values,formulas',tableMaxRows:3,tableMaxCols:11})).ndjson);
console.log((await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:20}})).ndjson);
for(const [range,file] of [['A8:H15','stats_summary'],['D29:N33','stats_tests']]){
 const blob=await wb.render({sheetName:'Statistical tests',range,scale:1,format:'png'});
 await fs.writeFile(path.join(out,`${file}.png`),new Uint8Array(await blob.arrayBuffer()));
}
await (await SpreadsheetFile.exportXlsx(wb)).save(path.join(out,'master_power_energy_analysis.xlsx'));
console.log('Exported updated workbook; secondary axes added by finalize_statistics.py.');
