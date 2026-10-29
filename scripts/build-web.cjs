#!/usr/bin/env node
// Build the single offline artifact from authoritative sources and original assets.
const fs=require('fs'),path=require('path');
const root=path.resolve(__dirname,'..'),read=p=>fs.readFileSync(path.join(root,p),'utf8');
function translations(){
 const rows=read('assets/i18n/rows.jsonl').split('\n').filter(x=>x.trim()).map(x=>JSON.parse(x)),seen=new Set();
 const tokens=s=>(s.match(/\{\d+\}/g)||[]).sort().join(',');
 for(const [i,row] of rows.entries()){
  if(!Array.isArray(row)||row.length!==6||row.some(x=>typeof x!=='string'||!x.trim()))throw Error(`Invalid locale columns at row ${i+1}`);
  if(seen.has(row[0]))throw Error(`Duplicate translation: ${row[0]}`);seen.add(row[0]);
  if(row.some(x=>tokens(x)!==tokens(row[0])||(x.match(/✎/g)||[]).length!==(row[0].match(/✎/g)||[]).length))throw Error(`Invalid translation placeholders at row ${i+1}`);
 }
 return rows.sort((a,b)=>a[0].localeCompare(b[0],'it'));
}
function build(){
 const data={};for(const id of ['menu','build','wave','paths','boss','victory','gameover'])data[id]=fs.readFileSync(path.join(root,'assets/audio',id+'.mp3')).toString('base64');
 const script=read('web/src/game.js').replace('{{MUSIC_SCRIPT}}',()=>read('web/src/music.js')).replace('{{I18N_ROWS}}',()=>JSON.stringify(translations()));
 const styles=read('web/src/styles.css').replace('{{FONT_DATA}}',()=>fs.readFileSync(path.join(root,'assets/fonts/PatrickHand-latin.woff')).toString('base64'));
 let html=read('web/src/index.template.html');
 for(const [key,value] of Object.entries({GAME_STYLES:styles,GAME_SCRIPT:script,MUSIC_BLOCK:'<!--music-data:start--><script type="application/json" id="music-data">'+JSON.stringify(data)+'</script><!--music-data:end-->'}))html=html.replace('{{'+key+'}}',()=>value);
 if(/\{\{(?:GAME_|I18N_ROWS|FONT_DATA|MUSIC_BLOCK)/.test(html))throw Error('Unresolved build placeholder');
 return html;
}
if(require.main===module){const html=build(),out=path.join(root,'dist/index.html');if(process.argv.includes('--check')){if(read('dist/index.html')!==html)throw Error('Generated HTML is stale: node scripts/build-web.cjs');console.log('PASS: reproducible offline bundle and locale columns')}else{fs.writeFileSync(out,html);console.log('Built dist/index.html')}}
module.exports={build,translations};
