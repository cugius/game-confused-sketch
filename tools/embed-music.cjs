#!/usr/bin/env node
/* Incorpora audio/*.mp3 in dist/index.html (base64, tra i marcatori music-data).
   Uso: node tools/embed-music.cjs [--check] */
const fs=require('fs'),path=require('path');
const root=path.join(__dirname,'..'),html=path.join(root,'dist','index.html'),dir=path.join(root,'audio');
const ids=['menu','frozen','neon','victory','gameover'];
const data={};for(const id of ids)data[id]=fs.readFileSync(path.join(dir,id+'.mp3')).toString('base64');
const block='<!--music-data:start--><script type="application/json" id="music-data">'+JSON.stringify(data)+'</script><!--music-data:end-->';
let s=fs.readFileSync(html,'utf8');
const a=s.indexOf('<!--music-data:start-->'),b=s.indexOf('<!--music-data:end-->');
if(a<0||b<0){console.error('marcatori music-data mancanti in dist/index.html');process.exit(1)}
const next=s.slice(0,a)+block+s.slice(b+'<!--music-data:end-->'.length);
if(process.argv.includes('--check')){if(next!==s){console.error('dist/index.html non è allineato a audio/: esegui node tools/embed-music.cjs');process.exit(1)}console.log('OK: musica incorporata allineata ('+ids.length+' brani)');process.exit(0)}
fs.writeFileSync(html,next);
console.log('Musica incorporata:',ids.map(id=>id+' '+(fs.statSync(path.join(dir,id+'.mp3')).size/1024|0)+' KB').join(', '));
