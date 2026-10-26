#!/usr/bin/env node
// Genera gamecenter/definitions.json e docs/ACHIEVEMENTS.md da ACH/GC_BOARDS e dalle traduzioni.
const fs=require('fs'),path=require('path');
const root=path.join(__dirname,'..'),html=fs.readFileSync(path.join(root,'dist/index.html'),'utf8');
const L=['it','en','es','fr','de','ja'];
const rows=new Map(fs.readFileSync(path.join(root,'i18n/rows.jsonl'),'utf8').split('\n').filter(Boolean).map(l=>{const r=JSON.parse(l);return[r[0],r]}));
const m=html.match(/^const ACH=\[[\s\S]*?^\]\.map\([^\n]*\n/m),g=html.match(/^const ACH_GROUPS=[^;]*;/m),b=html.match(/^const GC_BOARDS=[^;]*;/m);
if(!m||!g||!b)throw new Error('ACH non trovato');
const {ACH,ACH_GROUPS,GC_BOARDS}=new Function('statGet','meta','starTotal','statObj','statMax','meta',g[0]+m[0]+b[0]+';return{ACH,ACH_GROUPS,GC_BOARDS}')(()=>0,{badges:{}},()=>0,()=>({}),()=>0);
const tl=(s,goal)=>L.reduce((o,l,i)=>{let r=rows.get(s)||rows.get(s.replace(/\d+/g,'{0}'));o[l]=((r&&r[i])||s).replace(/\{0\}/g,goal);return o},{});
const defs={prefix:'cs.',achievements:ACH.map(a=>({id:'cs.'+a.k,group:ACH_GROUPS[a.grp],points:a.points,goal:a.goal,names:tl(a.n,a.goal),descriptions:tl(a.d,a.goal)})),
leaderboards:GC_BOARDS.map(([k,name])=>({id:'cs.'+k,names:tl(name,'')}))};
const total=defs.achievements.reduce((a,x)=>a+x.points,0);
const miss=defs.achievements.filter(a=>L.slice(1).some(l=>a.names[l]===a.names.it||a.descriptions[l]===a.descriptions.it));
fs.writeFileSync(path.join(root,'gamecenter/definitions.json'),JSON.stringify(defs,null,2)+'\n');
let md=`# Traguardi e classifiche Game Center\n\nGenerato da \`node tools/gc-definitions.cjs\` — non modificare a mano.\n\n- Prefisso identificatori: \`cs.\`\n- Traguardi: ${defs.achievements.length} · punti totali ${total} (massimo Apple: 1000, 100 per traguardo)\n- Lingue: ${L.join(', ')}\n\nDa creare in App Store Connect → Game Center prima della pubblicazione: ogni ID sotto, con punti e localizzazioni da \`gamecenter/definitions.json\`.\n\n`;
for(const grp of ACH_GROUPS){md+=`## ${grp}\n\n| ID | Nome | Obiettivo | Punti |\n|---|---|---|---|\n`;for(const a of defs.achievements.filter(x=>x.group===grp))md+=`| \`${a.id}\` | ${a.names.it} / ${a.names.en} | ${a.goal} | ${a.points} |\n`;md+='\n'}
md+=`## Classifiche\n\n| ID | Nome |\n|---|---|\n`+defs.leaderboards.map(x=>`| \`${x.id}\` | ${x.names.it} / ${x.names.en} |`).join('\n')+'\n';
fs.writeFileSync(path.join(root,'docs/ACHIEVEMENTS.md'),md);
console.log(`${defs.achievements.length} traguardi, ${total} punti, ${defs.leaderboards.length} classifiche; senza traduzione: ${miss.map(a=>a.id).join(', ')||'nessuno'}`);
