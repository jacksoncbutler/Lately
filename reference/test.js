const fs=require('fs');
let fails=0;const ok=(c,m)=>{if(!c){fails++;console.log('FAIL',m)}else console.log('ok  ',m)};
eval(fs.readFileSync('logic.js','utf8')+`
const now=Date.now();
const d=sampleData(now);
const rows=rank(d.people,now,d.tune);
rows.forEach(r=>console.log(r.p.name.padEnd(8),r.status.padEnd(8),r.ratio.toFixed(2),(r.sure?'':'~')+r.exp,clockStr(r.p.tz,now)));
const by=n=>rows.find(r=>r.p.name===n);
ok(by('Lena').status==='today','Lena talked today is excluded');
ok(by('Priya').status==='notdue','Priya (ratio .5) is not due');
ok(by('Mom').ratio>=0.6&&by('Mom').ratio<1,'Mom ratio between floor and 1');
// same-day rule holds for every chip
['15','30','long',null].forEach(c=>{const x=pickHero(rows,c,d.tune);ok(!x.row||x.row.p.name!=='Lena','chip '+c+' never picks Lena: '+(x.row&&x.row.p.name))});
// calendar day not rolling 24h: a chat 20h ago in a previous calendar day is not 'today'
const p2=Object.assign({},d.people[0]);
const mid=new Date(now);mid.setHours(0,0,0,0);
p2.chats=[{id:'x',at:mid.getTime()-3600000,type:'call',length:'quick',depth:'shallow',duration:0,feelings:[]}];
ok(statusOf(p2,now,d.tune)!=='today','chat just before local midnight is not same day');
p2.chats=[{id:'x',at:mid.getTime()+1000,type:'call',length:'quick',depth:'shallow',duration:0,feelings:[]}];
ok(statusOf(p2,mid.getTime()+7200000,d.tune)==='today','chat just after midnight is same day');
// gap-scaled length
const mk=(chats)=>({chats:chats,estimate:null});
const c=(m)=>({duration:m,length:'catchup'});
const iv=30;
const a=expectedInfo(mk([c(20),c(20),c(20),c(20),c(20)]),d.tune,0.9).min;
const b=expectedInfo(mk([c(20),c(20),c(20),c(20),c(20)]),d.tune,6).min;
ok(b>a,'long gap raises guess ('+a+' -> '+b+')');
ok(b<=30,'five short chats mostly hold the guess ('+b+')');
const e=expectedInfo(mk([c(20)]),d.tune,6).min;
ok(e>b,'thin history lets the gap matter more ('+e+')');
ok(expectedInfo(mk([c(200)]),d.tune,6).min<=d.tune.expCap,'guess never above cap');
ok(expectedInfo(mk([]),d.tune,1).min===30,'no history, on time: 30');
// soft chips
const h0=pickHero(rows,null,d.tune);
const h15=pickHero(rows,'15',d.tune);
console.log('no chip:',h0.row.p.name,'| 15:',h15.row.p.name,h15.note,'| 30:',pickHero(rows,'30',d.tune).row.p.name,'| long:',pickHero(rows,'long',d.tune).row.p.name);
ok(!!h15.row,'chip still returns someone');
// a very overdue person beats a barely due short-chat person under the 15 chip
const rA={p:{name:'A'},ratio:3.0,exp:60,status:'ok'},rB={p:{name:'B'},ratio:1.2,exp:15,status:'ok'};
ok(pickHero([rA,rB],'15',d.tune).row.p.name==='A'&&pickHero([rA,rB],'15',d.tune).note==='A quick hello still counts.','very overdue beats chip fit and shows note');
const rC={p:{name:'C'},ratio:1.3,exp:60,status:'ok'};
ok(pickHero([rC,rB],'15',d.tune).row.p.name==='B','similar ratio: chip fit wins');
// caught up
const none=rank(d.people.map(p=>Object.assign({},p,{chats:[{id:'z',at:now,type:'call',length:'quick',depth:'shallow',duration:0,feelings:[]}]})),now,d.tune);
ok(pickHero(none,null,d.tune).row===null,'everyone talked today -> caught up (no hero)');
// rels in dates
ok(upcoming(d.people,now,365).some(x=>/Maria/.test(x.label)),'their people birthdays feed Dates');
console.log(whyLine(h0.row),'|',whyLine(by('Alex')));
`);
console.log(fails?fails+' FAILED':'all passed');process.exit(fails?1:0);
