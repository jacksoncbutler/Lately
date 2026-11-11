/*LOGIC_START*/
var DAY=86400000;
var USER_TZ=(function(){try{return Intl.DateTimeFormat().resolvedOptions().timeZone||'UTC'}catch(e){return 'UTC'}})();
var GROUPS=[{id:'parents',name:'Parents'},{id:'siblings',name:'Siblings'},{id:'friends',name:'Friends'}];
var LEN_LABEL={quick:'Quick',catchup:'Catch-up',long:'Long'};
var DEPTH_LABEL={shallow:'Shallow',varied:'Varied',deep:'Deep'};
var TYPE_LABEL={person:'In person',call:'Call',text:'Text'};
var TUNE0={groupInterval:{parents:14,siblings:21,friends:30},lenMin:{quick:15,catchup:30,long:60},awakeStart:8,awakeEnd:22,snoozeDays:7,chip15Max:20,chip30Min:20,chipLongMin:50,lastN:5,dueFloor:0.6,chipPenalty:0.6,gapBoost:2,gapRatio:4,trustChats:5,historyDamp:0.6,expCap:90};
var CITIES=[['Lisbon','Europe/Lisbon'],['London','Europe/London'],['Berlin','Europe/Berlin'],['Madrid','Europe/Madrid'],['Paris','Europe/Paris'],['Athens','Europe/Athens'],['Istanbul','Europe/Istanbul'],['Cairo','Africa/Cairo'],['Nairobi','Africa/Nairobi'],['Lagos','Africa/Lagos'],['Johannesburg','Africa/Johannesburg'],['Dubai','Asia/Dubai'],['Mumbai','Asia/Kolkata'],['Bangkok','Asia/Bangkok'],['Manila','Asia/Manila'],['Singapore','Asia/Singapore'],['Tokyo','Asia/Tokyo'],['Seoul','Asia/Seoul'],['Perth','Australia/Perth'],['Sydney','Australia/Sydney'],['Auckland','Pacific/Auckland'],['Honolulu','Pacific/Honolulu'],['Anchorage','America/Anchorage'],['Los Angeles','America/Los_Angeles'],['Vancouver','America/Vancouver'],['Denver','America/Denver'],['Mexico City','America/Mexico_City'],['Chicago','America/Chicago'],['New York','America/New_York'],['Bogota','America/Bogota'],['Sao Paulo','America/Sao_Paulo']];
var STATUS_LABEL={ok:'',asleep:'Asleep',today:'Talked today',notdue:'Not due',skipped:'Skipped',snoozed:'Snoozed',archived:'Archived'};
var LAST_TALKED=[['A week',7],['Two weeks',14],['A month',30],['A few months',90],['Six months',180],['A year or more',360]];

function pad(n){return String(n).padStart(2,'0')}
function uid(){return Math.random().toString(36).slice(2,9)}
function hm(tz,ms){
  try{
    var parts=new Intl.DateTimeFormat('en-US',{timeZone:tz,hour:'numeric',minute:'numeric',hourCycle:'h23'}).formatToParts(ms);
    var H=0,M=0;
    parts.forEach(function(x){if(x.type==='hour')H=(+x.value)%24;if(x.type==='minute')M=+x.value});
    return {h:H,m:M};
  }catch(e){var d=new Date(ms);return {h:d.getHours(),m:d.getMinutes()}}
}
function clockStr(tz,ms){
  try{
    return new Intl.DateTimeFormat('en-US',{timeZone:tz,hour:'numeric',minute:'2-digit'}).format(ms).replace(/\s?(AM|PM)/i,function(m,a){return ' '+a.toLowerCase()});
  }catch(e){return ''}
}
function ymd(tz,ms){
  try{return new Intl.DateTimeFormat('en-CA',{timeZone:tz,year:'numeric',month:'2-digit',day:'2-digit'}).format(ms)}
  catch(e){var d=new Date(ms);return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate())}
}
function cityOf(tz){return String(tz).split('/').pop().replace(/_/g,' ')}
function intervalOf(p,tune){return p.intervalOverride||tune.groupInterval[p.group]||30}
function lastChatAt(p,type){var m=0;p.chats.forEach(function(c){if((!type||c.type===type)&&c.at>m)m=c.at});return m}
function lastContactMs(p,now){var m=lastChatAt(p);return m||now-(p.estimate==null?180:p.estimate)*DAY}
function chatMinutes(c,tune){return c.duration>0?c.duration:(tune.lenMin[c.length]||30)}
function expectedInfo(p,tune,ratio){
  var n=p.chats.length,base=30;
  if(n){
    var last=p.chats.slice().sort(function(a,b){return b.at-a.at}).slice(0,tune.lastN);
    base=last.reduce(function(s,c){return s+chatMinutes(c,tune)},0)/last.length;
  }
  var r=ratio==null?1:ratio,boost=1;
  if(r>1)boost=1+(tune.gapBoost-1)*Math.min(1,(r-1)/Math.max(0.5,tune.gapRatio-1));
  var trust=Math.min(1,n/Math.max(1,tune.trustChats));
  var f=1+(boost-1)*(1-tune.historyDamp*trust);
  var m=Math.max(5,Math.min(tune.expCap,Math.round(base*f/5)*5));
  return {min:m,sure:n>=3&&f<1.15};
}
function statusOf(p,now,tune){
  if(p.archived)return 'archived';
  if(p.snoozedUntil&&p.snoozedUntil>now)return 'snoozed';
  if(p.skippedDay&&p.skippedDay===ymd(USER_TZ,now))return 'skipped';
  var lc=lastChatAt(p);
  if(lc&&ymd(USER_TZ,lc)===ymd(USER_TZ,now))return 'today';
  var t=hm(p.tz,now),mins=t.h*60+t.m;
  if(mins<tune.awakeStart*60||mins>=tune.awakeEnd*60)return 'asleep';
  return 'ok';
}
function rank(people,now,tune){
  var rows=people.filter(function(p){return !p.archived}).map(function(p){
    var last=lastContactMs(p,now),days=Math.max(0,(now-last)/DAY),iv=intervalOf(p,tune),ratio=days/iv;
    var st=statusOf(p,now,tune);
    if((st==='ok'||st==='asleep')&&ratio<tune.dueFloor)st='notdue';
    var info=expectedInfo(p,tune,ratio);
    return {p:p,days:days,iv:iv,ratio:ratio,status:st,exp:info.min,sure:info.sure};
  });
  rows.sort(function(a,b){
    var ao=a.status==='ok'?0:1,bo=b.status==='ok'?0:1;
    if(ao!==bo)return ao-bo;
    if(b.ratio!==a.ratio)return b.ratio-a.ratio;
    if(b.days!==a.days)return b.days-a.days;
    return a.p.name.localeCompare(b.p.name);
  });
  return rows;
}
function chipFits(chip,exp,tune){
  if(chip==='15')return exp<=tune.chip15Max;
  if(chip==='30')return exp>=tune.chip30Min;
  if(chip==='long')return exp>=tune.chipLongMin;
  return true;
}
function pickHero(rows,chip,tune){
  var ok=rows.filter(function(r){return r.status==='ok'});
  if(!ok.length)return {row:null,note:''};
  var best=null,bs=-1,bfit=true;
  ok.forEach(function(r){
    var fit=!chip||chipFits(chip,r.exp,tune),sc=r.ratio*(fit?1:tune.chipPenalty);
    if(sc>bs){bs=sc;best=r;bfit=fit}
  });
  var note='';
  if(chip&&!bfit)note=chip==='15'?'A quick hello still counts.':'Not a perfect fit for that, but they are the most due.';
  return {row:best,note:note};
}
function wakeInMin(p,now,tune){var t=hm(p.tz,now),cur=t.h*60+t.m,s=tune.awakeStart*60;return cur<s?s-cur:1440-cur+s}
function whyLine(r){
  var over=r.days-r.iv,a;
  if(over>=90)a='Overdue by '+Math.floor(over/30)+' months';
  else if(over>=14)a='Overdue by '+Math.floor(over/7)+' weeks';
  else if(over>=1)a='Overdue by '+Math.floor(over)+(Math.floor(over)===1?' day':' days');
  else if(over>-1)a='Due today';
  else a='Due in '+Math.ceil(-over)+(Math.ceil(-over)===1?' day':' days');
  a+=' · '+(r.sure?'usually':'probably')+' a '+r.exp+' minute '+(r.exp<=20?'check-in':r.exp<=45?'catch-up':'long chat');
  return a;
}
function agoText(days){
  if(days<1)return 'today';
  if(days<14)return Math.floor(days)+(Math.floor(days)===1?' day ago':' days ago');
  if(days<60)return Math.floor(days/7)+' weeks ago';
  return Math.floor(days/30)+' months ago';
}
function upcoming(people,now,limitDays){
  var t=ymd(USER_TZ,now).split('-').map(Number),today=Date.UTC(t[0],t[1]-1,t[2]),out=[];
  function add(label,sub,mmdd,pid){
    if(!mmdd)return;
    var m=/^(\d\d)-(\d\d)$/.exec(mmdd);
    if(!m)return;
    var c=Date.UTC(t[0],+m[1]-1,+m[2]);
    if(c<today)c=Date.UTC(t[0]+1,+m[1]-1,+m[2]);
    var days=Math.round((c-today)/DAY);
    if(days<=limitDays)out.push({label:label,sub:sub,days:days,at:c,pid:pid});
  }
  people.forEach(function(p){
    if(p.archived)return;
    add(p.name+"'s birthday",'',p.birthday,p.id);
    p.rels.forEach(function(f){add(f.name+"'s birthday",p.name+"'s "+(f.relation||'person'),f.birthday,p.id)});
  });
  out.sort(function(a,b){return a.days-b.days});
  return out;
}
function dateLabel(at){return new Date(at).toLocaleDateString('en-US',{weekday:'short',month:'short',day:'numeric',timeZone:'UTC'})}
function fmtDate(ms,now){
  var d=new Date(ms),same=new Date(now).getFullYear()===d.getFullYear();
  return d.toLocaleDateString('en-US',same?{month:'short',day:'numeric'}:{month:'short',day:'numeric',year:'numeric'});
}
function sampleData(now){
  var bd=function(n){var d=new Date(now+n*DAY);return pad(d.getUTCMonth()+1)+'-'+pad(d.getUTCDate())};
  var ch=function(daysAgo,type,length,depth,duration,feelings){return {id:uid(),at:now-daysAgo*DAY,type:type,length:length,depth:depth,duration:duration||0,feelings:feelings||[]}};
  var ln=function(block,text,done){return {id:uid(),block:block,text:text,done:!!done}};
  var rel=function(name,relation,birthday,notes){return {id:uid(),name:name,relation:relation,birthday:birthday||'',notes:(notes||[]).map(function(t){return {id:uid(),text:t}})}};
  var P=function(o){return Object.assign({id:uid(),name:'',group:'friends',tz:'UTC',contact:{type:'text',value:''},birthday:'',chats:[],lines:[],rels:[],hometown:'',socials:'',estimate:null,intervalOverride:0,snoozedUntil:0,skippedDay:'',archived:false},o)};
  var people=[
    P({name:'Sam',group:'friends',tz:'Europe/Lisbon',contact:{type:'text',value:'+351 555 0142'},birthday:'03-14',hometown:'Porto',socials:'@sam.r',
      chats:[ch(51,'call','catchup','varied',0,['happy']),ch(70,'text','quick','shallow'),ch(104,'person','long','deep',150,['excited'])],
      lines:[ln('next_time','Ask about the new job'),ln('next_time','Did the move go ahead?'),ln('next_time','Send the trail photos'),ln('interests','Trail running'),ln('interests','Pottery'),ln('interests','Fado'),ln('interests','Film photography'),ln('interests','Sourdough'),ln('interests','Chess'),ln('about','Works in logistics'),ln('about','Moved flats in 2024'),ln('about','Allergic to cats')],
      rels:[rel('Maria','mother','06-02',['Retired teacher','Loves the garden']),rel('Tomas','brother','11-23'),rel('Ines','partner','09-09',['Nurse']),rel('Rosa','grandmother')]}),
    P({name:'Mom',group:'parents',tz:'America/Chicago',contact:{type:'call',value:'+1 555 0100'},birthday:bd(3),hometown:'Madison',
      chats:[ch(9,'call','catchup','deep',40,['happy']),ch(24,'call','catchup','varied')],
      lines:[ln('next_time','Ask how the garden is doing'),ln('about','Walks every morning')],rels:[rel('Gran','grandmother')]}),
    P({name:'Dad',group:'parents',tz:'America/Chicago',contact:{type:'call',value:'+1 555 0101'},birthday:'08-19',
      chats:[ch(31,'call','quick','shallow'),ch(52,'call','quick','shallow')],lines:[ln('next_time','Did he fix the boat trailer?'),ln('interests','Fishing'),ln('interests','Woodworking')]}),
    P({name:'Kate',group:'siblings',tz:'America/Denver',contact:{type:'text',value:'+1 555 0177'},birthday:'01-30',
      chats:[ch(40,'text','quick','shallow'),ch(70,'call','long','deep',75)],lines:[ln('next_time','Ask about the new apartment'),ln('about','Training for a half marathon')]}),
    P({name:'Alex',group:'friends',tz:'Australia/Sydney',contact:{type:'text',value:'+61 555 0103'},birthday:bd(6),estimate:60,lines:[ln('about','Met at the dive shop in Cebu')]}),
    P({name:'Priya',group:'friends',tz:'Asia/Kolkata',contact:{type:'text',value:'+91 555 0121'},birthday:'12-05',
      chats:[ch(15,'text','catchup','varied'),ch(40,'call','long','deep',70)],lines:[ln('interests','Bouldering')]}),
    P({name:'Marcus',group:'friends',tz:'America/New_York',contact:{type:'call',value:'+1 555 0188'},birthday:'05-21',
      chats:[ch(62,'call','long','deep',90,['excited']),ch(120,'call','catchup','varied')],lines:[ln('next_time','Ask how the new job is going'),ln('about','Just had a baby')],rels:[rel('Dana','partner'),rel('Theo','child','10-03')]}),
    P({name:'Noor',group:'friends',tz:'Asia/Dubai',contact:{type:'text',value:'+971 555 0132'},birthday:'07-08',
      chats:[ch(33,'call','quick','shallow'),ch(60,'call','quick','shallow'),ch(90,'text','quick','shallow')],lines:[ln('about','Always up for a quick call')]}),
    P({name:'Jun',group:'friends',tz:'Asia/Tokyo',contact:{type:'text',value:'+81 555 0144'},birthday:'02-17',estimate:30}),
    P({name:'Elena',group:'friends',tz:'Europe/Berlin',contact:{type:'text',value:'+49 555 0166'},birthday:'04-11',
      chats:[ch(100,'person','long','deep',180,['happy']),ch(130,'call','catchup','varied')],lines:[ln('next_time','Ask about the thesis')]}),
    P({name:'Lena',group:'siblings',tz:'Europe/London',contact:{type:'text',value:'+44 555 0155'},birthday:'10-02',chats:[ch(0,'call','catchup','varied')]}),
    P({name:'Ruth',group:'friends',tz:'Pacific/Auckland',contact:{type:'text',value:'+64 555 0199'},birthday:'09-27',chats:[ch(80,'person','long','deep',120)]})
  ];
  var sam=people[0],c0=sam.chats[0];
  sam.lines.forEach(function(l){if(l.text==='Sourdough'||l.text==='Film photography'||l.text==='Moved flats in 2024')l.addedIn=c0.id});
  sam.rels.forEach(function(r){if(r.name==='Ines')r.addedIn=c0.id});
  c0.note='Caught up on the move and the trail photos. He is thinking about a pottery class.';
  return {people:people,custom:[],tune:JSON.parse(JSON.stringify(TUNE0))};
}
/*LOGIC_END*/
