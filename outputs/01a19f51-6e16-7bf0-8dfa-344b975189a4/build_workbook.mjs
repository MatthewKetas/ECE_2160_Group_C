import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {Workbook, SpreadsheetFile} from '@oai/artifact-tool';
process.on('uncaughtException',e=>{console.error(e.message);console.error(e.stack?.split('\n').slice(-5).join('\n'));process.exit(1);});

const out=path.dirname(fileURLToPath(import.meta.url));
const D=JSON.parse(await fs.readFile(path.join(out,'source_data.json'),'utf8'));
const families=D.families;
const wb=Workbook.create();
const names=['Review','Interpretations','Compiler','Storage','Linking','Limits','Statistics','Runs','Builds','Phases','Stack frames','Evidence'];
const S=Object.fromEntries(names.map(n=>[n,wb.worksheets.add(n)]));
const C={ink:'#233449',blue:'#365F91',orange:'#C78238',teal:'#3B877A',gray:'#748294',pale:'#EDF2F7',amber:'#FFF2CC',red:'#FCE3DE',white:'#FFFFFF'};
const colors=[C.blue,C.teal,C.orange,C.gray];
const charts=[];
const letters=n=>{let s='';for(n++;n;n=Math.floor((n-1)/26))s=String.fromCharCode(65+(n-1)%26)+s;return s;};
const addr=(row,col)=>`${letters(col)}${row}`;
function value(sheet,cell,v){sheet.getRange(cell).values=[[v??null]];}
function formula(sheet,cell,f){sheet.getRange(cell).formulas=[[f]];}
function row(sheet,r,vals,start=0){sheet.getRange(`${addr(r,start)}:${addr(r,start+vals.length-1)}`).values=[vals.map(v=>v??null)];}
function fmt(sheet,range,config){sheet.getRange(range).format=config;}
function title(sheet,text,note){
  sheet.showGridLines=false;
  fmt(sheet,'A1:U180',{font:{name:'Arial',size:10,color:C.ink},rowHeight:22,verticalAlignment:'center'});
  fmt(sheet,'A1:L180',{columnWidth:11});fmt(sheet,'M1:M180',{columnWidth:3});
  fmt(sheet,'N1:U180',{columnWidth:11});
  value(sheet,'A2',text);fmt(sheet,'A2:L2',{font:{name:'Arial',size:16,bold:true},rowHeight:29});
  fmt(sheet,'A3:U3',{borders:{bottom:{style:'thin',color:C.blue}}});
  if(note){value(sheet,'A4',note);fmt(sheet,'A4:U4',{font:{italic:true,size:10},rowHeight:23});}
}
function header(sheet,r,labels,start=0){
  row(sheet,r,labels,start);
  fmt(sheet,`${addr(r,start)}:${addr(r,start+labels.length-1)}`,{fill:C.blue,font:{name:'Arial',size:10,bold:true,color:C.white},wrapText:true,rowHeight:52,horizontalAlignment:'center'});
}
function table(sheet,r,headers,rows,tableName,widths=[]){
  header(sheet,r,headers);
  if(rows.length)sheet.getRange(`A${r+1}:${letters(headers.length-1)}${r+rows.length}`).values=rows.map(x=>x.map(v=>v??null));
  fmt(sheet,`A${r+1}:${letters(headers.length-1)}${r+rows.length}`,{font:{name:'Arial',size:10,color:C.ink},rowHeight:22,verticalAlignment:'center'});
  widths.forEach((w,i)=>fmt(sheet,`${letters(i)}${r}:${letters(i)}${r+rows.length}`,{columnWidth:w}));
  if(tableName&&rows.length)sheet.tables.add(`A${r}:${letters(headers.length-1)}${r+rows.length}`,true,tableName);
  sheet.freezePanes.freezeRows(r);
}
function notes(sheet,r,id,prompt){
  value(sheet,`N${r}`,id+' — your interpretation');fmt(sheet,`N${r}:U${r}`,{fill:C.pale,font:{bold:true}});
  value(sheet,`N${r+1}`,prompt);
  // Wide, individually editable cells give room for prose without merging analysis columns.
  for(const [offset,label] of [[3,'What do you observe?'],[7,'Why do you think it happened?'],[11,'What would you choose for Critter, and why?']]){
    value(sheet,`N${r+offset}`,label);fmt(sheet,`N${r+offset}:U${r+offset}`,{font:{bold:true}});
    sheet.mergeCells(`N${r+offset+1}:U${r+offset+3}`);
    fmt(sheet,`N${r+offset+1}:U${r+offset+3}`,{fill:C.amber,wrapText:true,verticalAlignment:'top',font:{color:'#1F4E79'}});
  }
}
function chart(sheet,titleText,categories,series,from,to,unit='KiB',type='bar'){
  const ch=sheet.charts.add(type,[sheet.getRange(categories),...series.map(r=>sheet.getRange(r))]);
  ch.title=titleText;ch.titleTextStyle.fontSize=14;ch.titleTextStyle.typeface='Arial';
  ch.setPosition(from,to);ch.hasLegend=series.length>1;
  ch.legend={position:'bottom',textStyle:{typeface:'Arial',fontSize:11}};
  ch.xAxis={axisType:'textAxis',textStyle:{typeface:'Arial',fontSize:11}};
  ch.yAxis={numberFormatCode:'#,##0',numberFormatSourceLinked:false,textStyle:{typeface:'Arial',fontSize:11}};
  ch.yAxis.title.text=unit;
  if(unit.startsWith('Passing variants'))ch.yAxis={numberFormatCode:'0.0',numberFormatSourceLinked:false};
  ch.series.items.forEach((s,i)=>{s.fill=colors[i%colors.length];if(type==='line')s.line={fill:colors[i%colors.length],style:'solid',width:2};});
  charts.push({sheet:sheet.name,title:titleText,series:ch.series.items.map(s=>({values:s.formula,categories:s.categoryFormula}))});
  return ch;
}
function linkValue(sheet,target,sourceSheet,sourceCell){formula(sheet,target,`='${sourceSheet}'!${sourceCell}`);}

// Raw measurement inputs: both Pi sessions, with all stages explicitly identified.
const runCols=[['Session','session'],['Dataset','role'],['Stage','stage'],['Trial ID','id'],['Variant','variant'],['Unit','unit'],['Repetition','repetition'],['Status','status'],['Capacity (samples)','capacity'],['Rounds','rounds'],['GNU peak RSS (KiB)','peak_rss_kib'],['Elapsed (s)','duration_s'],['User CPU (s)','user_s'],['System CPU (s)','system_s'],['Major faults','major_faults'],['Minor faults','minor_faults'],['Exit code','exit_code'],['Timed out','timeout'],['Saved sample rows','rows'],['Limit kind','limit_kind'],['Limit (bytes)','limit_bytes'],['Public sample (bytes)','sample_bytes'],['Retained record (bytes)','record_bytes'],['Memory state (bytes)','memory_state_bytes'],['Checksum','checksum'],['Retained count','count'],['Rejected','rejected'],['Outliers','outliers'],['Mean (C)','mean'],['Median (C)','median'],['Std dev (C)','stddev'],['First timestamp (s)','first'],['Last timestamp (s)','last'],['Prediction (C)','prediction'],['Trend (C/s)','trend'],['Stable','stable'],['HVAC flag','hvac'],['Retained span (s)','retained_span_s'],['Allocation calls','allocation_calls'],['Free calls','free_calls'],['Peak requested heap (bytes)','requested_peak_bytes'],['Remaining requested heap (bytes)','requested_remaining_bytes'],['Source record','source']];
title(S.Runs,'Pi run records','All stages retained; only Full campaign / Screening enters the primary comparison.');
table(S.Runs,6,runCols.map(x=>x[0]),D.runs.map(r=>runCols.map(([,k])=>r[k])),'RunRecords',runCols.map((_,i)=>[20,20,24,47,21,14,12,18][i]??18));
fmt(S.Runs,`L7:N${D.runs.length+6}`,{numberFormat:'0.000'});
fmt(S.Runs,`AC7:AI${D.runs.length+6}`,{numberFormat:'0.000000'});
fmt(S.Runs,`AQ6:AQ${D.runs.length+6}`,{columnWidth:65});
S.Runs.freezePanes.freezeColumns(6);
const runIndex=new Map(D.runs.map((r,i)=>[r.session+'|'+r.id,i+7]));

const buildCols=[['Session','session'],['Dataset','role'],['Build','build'],['Variant','variant'],['Unit','unit'],['Diagnostic build','diagnostic'],['Behavior valid','valid'],['Failed checks','verify_failures'],['Capacity','capacity'],['Flags','flags'],['Source variant','source_change'],['Executable file (bytes)','file_bytes'],['Own shared libraries (bytes)','library_bytes'],['Text (bytes)','text_bytes'],['Read-only data (bytes)','rodata_bytes'],['Initialized data (bytes)','data_bytes'],['BSS (bytes)','bss_bytes'],['Largest reported frame (bytes)','max_frame_bytes'],['Source folder','source']];
title(S.Builds,'Build records','File bytes include debug symbols unless stripped. Own libraries exclude system-library distribution files.');
table(S.Builds,6,buildCols.map(x=>x[0]),D.builds.map(b=>buildCols.map(([,k])=>b[k])),'BuildRecords',[20,20,26,22,14,16,16,14,12,60,22,22,25,19,22,22,19,26,65]);
const buildIndex=new Map(D.builds.filter(b=>b.session===D.main&&!b.diagnostic).map(b=>[b.variant+'|'+b.unit,D.builds.indexOf(b)+7]));

const phaseCols=[['Session','session'],['Dataset','role'],['Trial ID','id'],['Variant','variant'],['Phase','phase'],['GNU peak RSS (KiB)','time_rss_kib'],['smaps RSS (KiB)','rss_kib'],['smaps PSS (KiB)','pss_kib'],['Private clean (KiB)','private_clean_kib'],['Private dirty (KiB)','private_dirty_kib'],['Shared clean (KiB)','shared_clean_kib'],['Shared dirty (KiB)','shared_dirty_kib'],['Private total (KiB)','private_kib'],['Shared total (KiB)','shared_kib'],['Status RSS (KiB)','status_rss_kib'],['Status HWM (KiB)','status_hwm_kib'],['Stack mapping (KiB)','stack_mapping_kib'],['Data mapping (KiB)','data_mapping_kib'],['Virtual size (KiB)','virtual_kib'],['Source record','source']];
title(S.Phases,'Diagnostic memory snapshots','Single instrumented pipeline run per variant; current RSS/PSS are distinct from primary GNU peak RSS.');
table(S.Phases,6,phaseCols.map(x=>x[0]),D.phases.map(p=>phaseCols.map(([,k])=>p[k])),'PhaseRecords',[20,20,40,22,24,...Array(14).fill(21),65]);
const phaseIndex=new Map(D.phases.filter(p=>p.session===D.main).map(p=>[p.variant+'|'+p.phase,D.phases.indexOf(p)+7]));

title(S['Stack frames'],'Compiler stack-frame records','Per-function and build reports; these are not total stack bounds, and LTO can emit multiple versions.');
table(S['Stack frames'],6,['Session','Build','Variant','Diagnostic','Function','Frame (bytes)','Kind','Source report'],D.frames.map(f=>[f.session,f.build,f.variant,f.diagnostic,f.function,f.bytes,f.kind,f.source]),'StackRecords',[20,28,22,15,58,20,20,80]);

// Statistics link to the exact three source trials; descriptive comparisons remain transparent.
title(S.Statistics,'Screening statistics','Three matched trials per variant/unit; combined trials are shown separately by their source IDs.');
const statHeader=['Variant','Experiment','Family','Unit','Trial 1 RSS (KiB)','Trial 2 RSS (KiB)','Trial 3 RSS (KiB)','Valid n','Median RSS (KiB)','Minimum RSS (KiB)','Maximum RSS (KiB)','O2 median (KiB)','Change vs O2','Observed range comparison','Trial 1 elapsed (s)','Trial 2 elapsed (s)','Trial 3 elapsed (s)','Median elapsed (s)'];
header(S.Statistics,6,statHeader);
fmt(S.Statistics,'A6:R126',{font:{name:'Arial',size:10},rowHeight:23});
header(S.Statistics,6,statHeader);
const statsIndex=new Map();
D.statistics.forEach((st,i)=>{const r=i+7;statsIndex.set(st.variant+'|'+st.unit,r);row(S.Statistics,r,[st.variant,st.label,st.family,st.unit]);});
D.statistics.forEach((st,i)=>{
  const r=i+7;
  for(let rep=1;rep<=3;rep++){
    const id=(st.variant==='combined'?'combined_':'screen_')+(rep-1)+'_'+(st.variant==='combined'?'':st.variant+'_')+st.unit;
    const source=runIndex.get(D.main+'|'+id);
    if(source){linkValue(S.Statistics,`${letters(rep+3)}${r}`,'Runs',`K${source}`);linkValue(S.Statistics,`${letters(rep+13)}${r}`,'Runs',`L${source}`);}
  }
  formula(S.Statistics,`H${r}`,`=COUNT(E${r}:G${r})`);
  for(const [col,func] of [['I','MEDIAN'],['J','MIN'],['K','MAX']])formula(S.Statistics,`${col}${r}`,`=IF(H${r}=0,"n.a.",${func}(E${r}:G${r}))`);
  const base=statsIndex.get('O2|'+st.unit);
  formula(S.Statistics,`L${r}`,`=I${base}`);
  formula(S.Statistics,`M${r}`,`=IF(H${r}=0,"n.a.",I${r}/L${r}-1)`);
  formula(S.Statistics,`N${r}`,st.variant==='Ofast'?'="Behavior invalid; excluded"':st.variant==='O2'?'="Reference"':`=IF(H${r}<3,"Incomplete",IF(K${r}<J${base},"Lower reported RSS",IF(J${r}>K${base},"Higher reported RSS","No resolved RSS change")))`);
  formula(S.Statistics,`R${r}`,`=IF(H${r}=0,"n.a.",MEDIAN(O${r}:Q${r}))`);
});
fmt(S.Statistics,'A6:D126',{columnWidth:24});fmt(S.Statistics,'E6:L126',{columnWidth:20,numberFormat:'#,##0'});
fmt(S.Statistics,'M6:M126',{columnWidth:18,numberFormat:'0.0%'});fmt(S.Statistics,'N6:N126',{columnWidth:31});fmt(S.Statistics,'O6:R126',{columnWidth:22,numberFormat:'0.000'});
S.Statistics.freezePanes.freezeRows(6);S.Statistics.freezePanes.freezeColumns(4);
const stat=(v,u='pipeline',col='I')=>`'Statistics'!${col}${statsIndex.get(v+'|'+u)}`;
const run=(v,col='AO')=>`'Runs'!${col}${runIndex.get(D.main+'|diagnostic_'+v)}`;
const build=(v,col='N',u='pipeline')=>`'Builds'!${col}${buildIndex.get(v+'|'+u)}`;
const ph=(v,p,col)=>`'Phases'!${col}${phaseIndex.get(v+'|'+p)}`;
function listTable(sheet,r,vs,columns){
  header(sheet,r,['Experiment',...columns.map(x=>x[0])]);
  vs.forEach((v,i)=>{const rr=r+i+1;value(sheet,`A${rr}`,D.labels[v]);columns.forEach((x,j)=>formula(sheet,`${letters(j+1)}${rr}`,x[1](v)));});
  fmt(sheet,`A${r}:A${r+vs.length}`,{columnWidth:29});fmt(sheet,`B${r+1}:${letters(columns.length)}${r+vs.length}`,{numberFormat:'#,##0.0'});
}

// Compiler views: group policies, individual passes, and unit dependence.
title(S.Compiler,'Compiler experiments','Bars start at zero. Read trial spread in Statistics; missing Ofast measurements are never plotted as zero.');
const groups=['O0','O1','O2','O3','Os','Oz'];
listTable(S.Compiler,7,groups,[['Trial 1',v=>'='+stat(v,'pipeline','E')],['Trial 2',v=>'='+stat(v,'pipeline','F')],['Trial 3',v=>'='+stat(v,'pipeline','G')]]);
chart(S.Compiler,'C1  Integrated pipeline: reported peak RSS','A7:A13',['B7:B13','C7:C13','D7:D13'],'A16','L33');
value(S.Compiler,'A35','-Ofast failed 5 behavior checks; no screening memory result is available.');
notes(S.Compiler,7,'C1','Do all optimization groups reduce resident RAM?');
listTable(S.Compiler,39,groups,[['Text (bytes)',v=>'='+build(v)],['File (bytes)',v=>'='+build(v,'L')]]);
chart(S.Compiler,'C2  Integrated executable code size','A39:A45',['B39:B45'],'A48','L65','Bytes');
notes(S.Compiler,39,'C2','Does smaller code correspond to lower reported RSS?');
const fine=['O2','unroll','no_loop_vector','no_slp_vector','no_inline','lto','gc_sections','no_stack_reuse','stripped'];
listTable(S.Compiler,70,fine,[['RSS median (KiB)',v=>'='+stat(v)],['Text (bytes)',v=>'='+build(v)],['File (bytes)',v=>'='+build(v,'L')]]);
chart(S.Compiler,'C3  Individual passes: integrated pipeline RSS','A70:A79',['B70:B79'],'A82','L101');
notes(S.Compiler,70,'C3','Which specific changes appear useful, neutral, or costly?');
listTable(S.Compiler,107,groups,[['I/O',v=>'='+stat(v,'io')],['Memory',v=>'='+stat(v,'memory')],['Computation',v=>'='+stat(v,'compute')],['Pipeline',v=>'='+stat(v)]]);
chart(S.Compiler,'C4  Compiler groups across all three units','A107:A113',['B107:B113','C107:C113','D107:D113','E107:E113'],'A116','L135');
notes(S.Compiler,107,'C4','Why might the integrated pipeline behave differently from a standalone unit?');

title(S.Storage,'Storage, data layout, and history','Requested heap bytes exclude allocator overhead and library allocations. Static bytes remain part of the program.');
const stores=['O2','workspace','arena','static_storage','packed_record','short_enums','window50','window25'];
listTable(S.Storage,7,stores,[['Heap peak (bytes)',v=>'='+run(v,'AO')],['Allocation calls',v=>'='+run(v,'AM')],['Record (bytes)',v=>'='+run(v,'W')],['RSS median (KiB)',v=>'='+stat(v)]]);
chart(S.Storage,'S1  Explicit memory-unit heap peak','A7:A15',['B7:B15'],'A18','L36','Requested bytes');
notes(S.Storage,7,'S1','How do storage strategies change memory demand versus where storage lives?');
const churn=['O2','workspace','arena','static_storage'];
listTable(S.Storage,41,churn,[['Allocation calls',v=>'='+run(v,'AM')],['State (bytes)',v=>'='+run(v,'X')],['BSS (bytes)',v=>'='+build(v,'Q')]]);
chart(S.Storage,'S2  Explicit allocation calls','A41:A45',['B41:B45'],'A48','L65','Calls');
notes(S.Storage,41,'S2','Would fewer allocations matter even when peak RAM is similar?');
const pathVs=['O2','path_buffers','io_context','no_stack_reuse'];
header(S.Storage,70,['Experiment','Save-sample frame (bytes)','Build max frame (bytes)','RSS median (KiB)']);
pathVs.forEach((v,i)=>{
  const r=71+i;value(S.Storage,`A${r}`,D.labels[v]);
  const f=D.frames.find(f=>f.session===D.main&&f.build===v&&f.function==='critter_io_save_sample');
  const source=f?D.frames.indexOf(f)+7:null;
  if(source)linkValue(S.Storage,`B${r}`,'Stack frames',`F${source}`);
  formula(S.Storage,`C${r}`,'='+build(v,'R'));formula(S.Storage,`D${r}`,'='+stat(v));
});
chart(S.Storage,'S3  A recurring I/O function’s stack frame','A70:A74',['B70:B74'],'A77','L94','Bytes');
value(S.Storage,'A96','Frame reports are not total stack usage; inlining changes which function owns local storage.');
notes(S.Storage,70,'S3','What does reducing stack requirements achieve if resident RAM does not change?');
const windows=['O2','window50','window25'];
listTable(S.Storage,101,windows,[['Heap peak (bytes)',v=>'='+run(v,'AO')],['Retained span (s)',v=>'='+run(v,'AL')],['Prediction (C)',v=>'='+run(v,'AH')],['Outliers',v=>'='+run(v,'AB')]]);
fmt(S.Storage,'C102:D104',{numberFormat:'0.0000'});
chart(S.Storage,'S4  History capacity and requested heap','A101:A104',['B101:B104'],'A108','L125','Bytes');
notes(S.Storage,101,'S4','How much useful history would you preserve, and why?');

title(S.Linking,'Linking, loading, and processor targeting','The measurement chosen matters: shared pages count fully in RSS but proportionally in PSS.');
const links=['O2','shared','dlopen','fully_static'];
listTable(S.Linking,7,links,[['I/O RSS',v=>'='+stat(v,'io')],['Memory RSS',v=>'='+stat(v,'memory')],['Compute RSS',v=>'='+stat(v,'compute')],['Pipeline RSS',v=>'='+stat(v)]]);
chart(S.Linking,'L1  Linking choices: reported peak RSS','A7:A11',['B7:B11','C7:C11','D7:D11','E7:E11'],'A15','L33');
notes(S.Linking,7,'L1','What memory benefit do these linking choices appear to provide?');
listTable(S.Linking,39,links,[['Executable (KiB)',v=>'='+build(v,'L')+'/1024'],['Own library (KiB)',v=>'='+build(v,'M')+'/1024']]);
chart(S.Linking,'L2  Executable and own-library file sizes','A39:A43',['B39:B43','C39:C43'],'A47','L64');
value(S.Linking,'A66','File sizes include debug information unless stripped; installed system libraries are excluded.');
notes(S.Linking,39,'L2','How do storage size and deployment dependencies affect your choice?');
listTable(S.Linking,71,links,[['Snapshot RSS (KiB)',v=>'='+ph(v,'finished_work','G')],['Snapshot PSS (KiB)',v=>'='+ph(v,'finished_work','H')],['GNU peak, same diagnostic (KiB)',v=>'='+ph(v,'finished_work','F')]]);
chart(S.Linking,'L3  Same diagnostic run: RSS, PSS, and GNU time','A71:A75',['B71:B75','C71:C75','D71:D75'],'A79','L97');
value(S.Linking,'A99','GNU peak RSS is below sampled RSS in these diagnostic runs. The cause is unresolved; do not reconcile the counters by subtraction.');
notes(S.Linking,71,'L3','Does accounting for shared memory change your interpretation?');
header(S.Linking,104,['Prediction phase','RSS (KiB)','PSS (KiB)']);
['summarized','prediction_loaded','finished_work','prediction_closed','released'].forEach((p,i)=>{row(S.Linking,105+i,[p]);formula(S.Linking,`B${105+i}`,'='+ph('dlopen',p,'G'));formula(S.Linking,`C${105+i}`,'='+ph('dlopen',p,'H'));});
chart(S.Linking,'L4  Loading and closing prediction','A104:A109',['B104:B109','C104:C109'],'A112','L128','KiB','line');
notes(S.Linking,104,'L4','What changes when prediction is loaded and then closed?');
const hardware=['O2','tune_a76','cpu_a76'];
listTable(S.Linking,134,hardware,[['Pipeline RSS (KiB)',v=>'='+stat(v)],['Median elapsed (s)',v=>'='+stat(v,'pipeline','R')],['Text (bytes)',v=>'='+build(v)]]);
fmt(S.Linking,'C135:C137',{numberFormat:'0.000'});
chart(S.Linking,'L5  Targeting the Pi’s processor','A134:A137',['B134:B137'],'A140','L156');
notes(S.Linking,134,'L5','Would processor targeting be worthwhile for this workload?');

title(S.Limits,'Resource limits and longer confirmations','Limits are applied after startup. A passing limit is an observed test result, not a safe worst-case bound.');
header(S.Limits,7,['Data cap (KiB)','-O2 result','Path buffers result','Arena result','Passing variants']);
const dataLevels=[64,128,256,512,1024,4096];
dataLevels.forEach((level,i)=>{
  const r=i+8;value(S.Limits,`A${r}`,level);
  ['O2','path_buffers','arena'].forEach((v,j)=>{
    const src=runIndex.get(D.main+`|limit_${v}_ASSESS_DATA_BYTES_${level*1024}`);
    linkValue(S.Limits,`${letters(j+1)}${r}`,'Runs',`H${src}`);
  });formula(S.Limits,`E${r}`,`=COUNTIFS(B${r}:D${r},"ok")`);
});
chart(S.Limits,'T1  Data-limit trials: passing variants','A7:A13',['E7:E13'],'A17','L33','Passing variants (out of 3)');
notes(S.Limits,7,'T1','What range brackets success and failure, and what margin would you require?');
header(S.Limits,39,['Stack cap (KiB)','-O2 result','Path buffers result','Arena result','Passing variants']);
[64,128,256,512,1024].forEach((level,i)=>{
  const r=i+40;value(S.Limits,`A${r}`,level);
  ['O2','path_buffers','arena'].forEach((v,j)=>linkValue(S.Limits,`${letters(j+1)}${r}`,'Runs',`H${runIndex.get(D.main+`|limit_${v}_ASSESS_STACK_BYTES_${level*1024}`)}`));
  formula(S.Limits,`E${r}`,`=COUNTIFS(B${r}:D${r},"ok")`);
});
chart(S.Limits,'T2  Stack-limit trials: passing variants','A39:A44',['E39:E44'],'A48','L64','Passing variants (out of 3)');
value(S.Limits,'A66','All tested 64–1,024 KiB caps passed. Existing mapped stack pages were not removed when the cap was lowered.');
notes(S.Limits,39,'T2','What does this test establish—and what does it leave unproven?');
header(S.Limits,71,['Arena budget (bytes)','Result','Exit code']);
[0,4799,4800].forEach((budget,i)=>{const r=i+72;value(S.Limits,`A${r}`,budget);const src=runIndex.get(D.main+'|arena_capacity_'+budget);linkValue(S.Limits,`B${r}`,'Runs',`H${src}`);linkValue(S.Limits,`C${r}`,'Runs',`Q${src}`);});
value(S.Limits,'A77','The arena requests 4,800 bytes; the 4,799-byte and zero budgets were rejected before collection.');
notes(S.Limits,71,'T3','What value does an explicit application-owned memory budget provide?');
header(S.Limits,91,['Configuration','Paced trial 1 RSS','Paced trial 2 RSS','Median RSS','Screening median RSS']);
['O2','O1','fully_static','combined'].forEach((v,i)=>{
  const r=i+92;value(S.Limits,`A${r}`,D.labels[v]);
  for(let j=0;j<2;j++)linkValue(S.Limits,`${letters(j+1)}${r}`,'Runs',`K${runIndex.get(D.main+`|confirm_${j}_${v}`)}`);
  formula(S.Limits,`D${r}`,`=MEDIAN(B${r}:C${r})`);formula(S.Limits,`E${r}`,'='+stat(v));
});
chart(S.Limits,'T4  Pipeline: screening and 60-second confirmations','A91:A95',['D91:D95','E91:E95'],'A99','L117');
notes(S.Limits,91,'T4','Do the longer runs support your candidate choice?');
value(S.Limits,'A120','Combined candidate: -O1, LTO, unused-section removal, and the partitioned arena. Benefits were not assumed additive.');

// Review captures the user's own reasoning without pre-filling an interpretation.
title(S.Review,'Critter memory experiment review','Write in the amber cells. Keep observations, mechanisms, and your product decision distinct.');
row(S.Review,6,['Full Pi campaign',D.main,null,'Screening trials',336,null,'Valid variants',28]);
row(S.Review,8,['Run records',441,null,'Duration (min)',D.sessions.find(s=>s.id===D.main).completion.elapsed_s/60,null,'Page size (KiB)',16]);
fmt(S.Review,'E8:E8',{numberFormat:'0.0'});
value(S.Review,'A10','Review the topic sheets, then write in Interpretations and the amber areas beside the charts.');
value(S.Review,'A12','Evidence notes: -Ofast failed 5 checks; smaller histories change retained evidence; diagnostic GNU peak and /proc RSS disagree.');
const headline=['O2','O0','Os','lto','shared','fully_static','arena','combined'];
listTable(S.Review,15,headline,[['Pipeline RSS (KiB)',v=>'='+stat(v)],['Change vs -O2',v=>'='+stat(v,'pipeline','M')]]);
fmt(S.Review,'C16:C23',{numberFormat:'0.0%'});
chart(S.Review,'R1  Selected pipeline comparisons: reported peak RSS','A15:A23',['B15:B23'],'E15','L32');
notes(S.Review,15,'R1','What are the largest effects you see, and which evidence needs explanation?');
value(S.Review,'A35','Your overall reasoning');
for(const [r,label] of [[37,'My main finding'],[43,'Why I believe this mechanism explains the evidence'],[49,'What I would choose for Critter and why'],[55,'What remains uncertain / what I would test next']]){
  value(S.Review,`A${r}`,label);S.Review.mergeCells(`A${r+1}:L${r+4}`);fmt(S.Review,`A${r+1}:L${r+4}`,{fill:C.amber,wrapText:true,verticalAlignment:'top',font:{color:'#1F4E79'}});
}
title(S.Interpretations,'Your observations and decisions','Amber cells are yours to complete. Refer to the chart IDs in the Evidence to review column.');
header(S.Interpretations,6,['Experiment','Evidence to review','What I observe','Why I think it happened','My Critter decision','Reason / tradeoff']);
const evidenceFor=v=>families[v]==='Compiler groups'?'Compiler C1–C4':families[v]==='Individual flags'?'Compiler C3; Statistics':families[v]==='Hardware'?'Linking L5':families[v]==='Linking and loading'?'Linking L1–L4':v==='combined'?'Limits T4':families[v]==='Retained history'?'Storage S4':'Storage S1–S3';
D.order.forEach((v,i)=>{const r=i+7;row(S.Interpretations,r,[D.labels[v],evidenceFor(v),null,null,null,null]);fmt(S.Interpretations,`C${r}:F${r}`,{fill:C.amber,wrapText:true,verticalAlignment:'top',font:{color:'#1F4E79'}});});
fmt(S.Interpretations,'A6:A36',{columnWidth:29});fmt(S.Interpretations,'B6:B36',{columnWidth:28});
fmt(S.Interpretations,'C6:F36',{columnWidth:43});fmt(S.Interpretations,'A7:F36',{rowHeight:85,wrapText:true,verticalAlignment:'top'});
S.Interpretations.getRange('E7:E36').dataValidation={rule:{type:'list',values:['Keep','Reject','Investigate further','Depends on deployment']}};
S.Interpretations.freezePanes.freezeRows(6);S.Interpretations.freezePanes.freezeColumns(2);
fmt(S.Review,'A1:A60',{columnWidth:29});fmt(S.Review,'B1:B60',{columnWidth:22});
fmt(S.Review,'C1:C60',{columnWidth:18});fmt(S.Review,'D1:D60',{columnWidth:20});
fmt(S.Review,'G6:H8',{columnWidth:16});
S.Review.freezePanes.freezeRows(4);

// Evidence and definitions: source choices and known measurement limitations.
title(S.Evidence,'Evidence, definitions, and validation','Sources are the supplied Pi archive and its extracted records. No Mac trials enter this workbook.');
header(S.Evidence,7,['Session','Purpose','Status','Duration (min)','Run records','Successful','Failed','Maximum allowed (min)']);
D.sessions.forEach((s,i)=>row(S.Evidence,i+8,[s.id,s.role,s.completion.status,s.completion.elapsed_s/60,s.runs,s.statuses.ok||0,s.statuses.failed||0,s.completion.maximum_minutes]));
fmt(S.Evidence,'A7:C9',{columnWidth:26});fmt(S.Evidence,'D8:D9',{numberFormat:'0.00'});
value(S.Evidence,'A12','Source archive');value(S.Evidence,'B12','critter-memory-results.tar.gz');
value(S.Evidence,'A13','Archive SHA-256');value(S.Evidence,'B13',D.archive_sha256);
value(S.Evidence,'A14','Source folder');value(S.Evidence,'B14',D.source);
value(S.Evidence,'A16','GNU compiler');value(S.Evidence,'B16','GCC 14.2.0, Debian 14.2.0-19');
value(S.Evidence,'A17','Platform');value(S.Evidence,'B17',D.sessions.find(s=>s.id===D.main).environment.platform);
value(S.Evidence,'A18','Page size');value(S.Evidence,'B18',16384);value(S.Evidence,'C18','bytes');
header(S.Evidence,21,['Unit','Fixed rounds','Calls / samples per round','Total work items']);
Object.entries(D.sessions.find(s=>s.id===D.main).workload).forEach(([unit,n],i)=>{const r=22+i;row(S.Evidence,r,[unit,n,unit==='compute'?10000:600]);formula(S.Evidence,`D${r}`,`=B${r}*C${r}`);});
header(S.Evidence,28,['Measure / rule','Meaning']);
const definitions=[
 ['Primary population','Full campaign, Screening; 28 valid variants × 4 units × 3 repetitions = 336 trials. Combined candidate has 12 additional screening trials.'],
 ['Earlier short check','156 records retained in Runs; it has different work counts and one repetition, so it is not pooled into the main charts.'],
 ['RSS comparison','Median of three run peaks. Lower/higher labels require nonoverlapping observed min–max ranges against the matched -O2 unit. This is descriptive, not a significance test.'],
 ['Shared memory','RSS counts all resident shared pages. PSS divides shared pages proportionally. Snapshots describe instrumented diagnostic runs, not repeated screening trials.'],
 ['Counter disagreement','For example, diagnostic -O2 reports GNU peak 1,088 KiB while its finished-work smaps RSS is 1,712 KiB. Preserve both; the cause is unresolved.'],
 ['Requested heap','Only explicit memory-unit allocation requests are instrumented. Allocator metadata, libraries, stack and static data are excluded. Static storage moves rather than erases storage demand.'],
 ['Code and file bytes','Text section measures code. Executable file includes debug information unless stripped. Own-library bytes exclude installed system libraries; inspect dependencies before inferring total deployment size.'],
 ['Stack frames','The compiler reports individual frames, sometimes after inlining. These are not a whole-call-stack bound. Static-library builds may report frames for unlinked functions.'],
 ['Stack/data caps','Applied after process startup. Existing mapped stack can exceed a later limit; the lowest passing cap does not prove that many bytes suffice from startup. Data caps also cover non-heap data.'],
 ['Invalid -Ofast','Five of nine invalid-input checks failed. The runner retained the build and excluded all four screening workloads. Missing measurements stay unavailable.'],
 ['Workload','Immutable 22.5 C CSV fixture supplies a base value; a deterministic ramp and outliers are added. Accelerated replay uses synthetic timestamps. No physical sensor or intensive future predictor is represented.'],
 ['History tradeoff','50- and 25-sample versions use their own O0 references. Passing those checks does not preserve the original history length or prediction evidence.'],
 ['Confirmation','Two paced 600-sample pipeline trials per selected configuration, about 60 s each. They are shown separately because workload count differs from screening.'],
 ['Your annotations','Amber cells are intentionally blank. They capture your observations, proposed explanations, and decisions before drafting the paper.'],
 ['Raw workload CSVs','Sample rows were independently counted; full synthetic temperature outputs remain in the supplied archive. All 597 measurement records, builds, phase snapshots and stack-frame records are included here.']
];
definitions.forEach((x,i)=>{row(S.Evidence,i+29,x);fmt(S.Evidence,`A${i+29}:B${i+29}`,{wrapText:true,rowHeight:57,verticalAlignment:'top'});});
fmt(S.Evidence,'A28:A43',{columnWidth:26});fmt(S.Evidence,'B28:B43',{columnWidth:110});
header(S.Evidence,47,['Build','Behavior valid','Failed checks','Diagnostic','Session']);
const uniqueBuilds=D.builds.filter(b=>b.unit==='pipeline');
uniqueBuilds.forEach((b,i)=>row(S.Evidence,48+i,[b.build,b.valid,b.verify_failures,b.diagnostic,b.session]));
const checkRow=48+uniqueBuilds.length+3;
header(S.Evidence,checkRow,['Consistency check','Compared records','Mismatches']);
const types=[...new Set(D.checks.map(c=>c.check))];
types.forEach((t,i)=>row(S.Evidence,checkRow+1+i,[t,D.checks.filter(c=>c.check===t).length,D.checks.filter(c=>c.check===t&&!c.passed).length]));
value(S.Evidence,`A${checkRow+6}`,'Independent checks compare each result JSON with raw GNU time, program stdout, and counted output rows.');
S.Evidence.freezePanes.unfreeze();

// Restrained formatting and linked chart sources.
for(const name of ['Review','Interpretations','Compiler','Storage','Linking','Limits'])S[name].tabColor=C.blue;
for(const name of ['Compiler','Storage','Linking','Limits']){
  fmt(S[name],'A1:A160',{columnWidth:30});
  // Keep analytical data columns compact and notes beyond the chart gutter.
  fmt(S[name],'B1:L160',{columnWidth:11});
}
fmt(S.Limits,'B8:D13',{horizontalAlignment:'center'});fmt(S.Limits,'B40:D44',{horizontalAlignment:'center'});
// These status cues complement text rather than replacing it.
S.Runs.getRange(`H7:H${D.runs.length+6}`).conditionalFormats.add('containsText',{text:'failed',format:{fill:C.red,font:{color:'#9C2D20'}}});
S.Statistics.getRange('M7:M126').conditionalFormats.add('cellIs',{operator:'greaterThan',formula:0,format:{font:{color:'#A24A22'}}});
S.Statistics.getRange('M7:M126').conditionalFormats.add('cellIs',{operator:'lessThan',formula:0,format:{font:{color:'#2B6D60'}}});

wb.recalculate();
const independent=[];
for(const st of D.statistics){
  if(st.median===null)continue;
  const r=statsIndex.get(st.variant+'|'+st.unit);
  const actual=S.Statistics.getRange(`I${r}:M${r}`).values[0];
  if(actual[0]!==st.median||actual[1]!==st.min||actual[2]!==st.max||Math.abs(actual[4]-st.delta)>1e-10)throw Error('Statistic mismatch '+st.variant+'/'+st.unit+': '+JSON.stringify(actual));
  independent.push(st.variant+'/'+st.unit);
}
console.log('Independently reconciled statistics:',independent.length);
const errors=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:30},summary:'Formula error scan'});
await fs.writeFile(path.join(out,'formula_scan.ndjson'),errors.ndjson);
console.log(errors.ndjson.slice(0,2000));
await fs.writeFile(path.join(out,'chart_inventory.json'),JSON.stringify(charts,null,2));
const check=await wb.inspect({kind:'table',range:'Statistics!A7:N18',include:'values,formulas',tableMaxRows:12,tableMaxCols:14,maxChars:3000});
await fs.writeFile(path.join(out,'inspection.ndjson'),check.ndjson);
for(const [name,range] of [['Review','A1:U33'],['Interpretations','A1:F11'],['Compiler','A1:U35'],['Storage','A1:U36'],['Linking','A65:U99'],['Limits','A1:U34'],['Statistics','A1:N18'],['Runs','A1:L15'],['Builds','A1:M15'],['Phases','A1:H15'],['Stack frames','A1:G15'],['Evidence','A1:H25']]){
  const preview=await wb.render({sheetName:name,range,scale:1.25,format:'png'});
  await fs.writeFile(path.join(out,'preview_'+name.replaceAll(' ','_')+'.png'),new Uint8Array(await preview.arrayBuffer()));
  console.log('Rendered',name);
}
const xlsx=await SpreadsheetFile.exportXlsx(wb);
await xlsx.save(path.join(out,'Critter_Memory_Experiment_Review.xlsx'));
await fs.writeFile(path.join(out,'verification.json'),JSON.stringify({statistics:independent.length,charts:charts.length,sourceChecks:D.validation_summary,sheets:names},null,2));
console.log('Saved workbook',charts.length,'charts');
