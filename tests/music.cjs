// Regression tests exercise the real music module with controlled audio and lifecycle events.
const vm=require('vm'),fs=require('fs'),assert=require('assert');
function fixture({defer=false}={}){
 const sources=[],gains=[],intervals=new Set();let resolveDecode,now=0;
 const param=()=>({value:0,setValueAtTime(v){this.value=v},linearRampToValueAtTime(v){this.value=v},cancelScheduledValues(){},setTargetAtTime(v){this.value=v}});
 const ctx={currentTime:0,state:'running',destination:{kind:'destination'},createGain(){const g={gain:param(),connect(to){this.to=to},disconnect(){this.disconnected=true}};gains.push(g);return g},createBufferSource(){const s={connect(to){this.to=to},disconnect(){this.disconnected=true},start(){this.started=true},stop(when){this.stops??=[];this.stops.push(when)}};sources.push(s);return s},decodeAudioData(ab,ok){const b={duration:12,length:12*48000,numberOfChannels:2};if(defer)return new Promise(r=>{resolveDecode=()=>{ok(b);r(b)}});ok(b);return Promise.resolve(b)}};
 const box={window:{AudioContext:function(){}},document:{hidden:false,getElementById(){return{textContent:JSON.stringify({menu:'AA==',victory:'AA==',gameover:'AA=='})}}},prefs:{music:true,musicVol:60},audioHeld:false,nativeAudioHeld:false,Float32Array,Uint8Array,Map,JSON,Math,Number,performance:{now:()=>now},atob:s=>Buffer.from(s,'base64').toString('binary'),audioCtx:()=>ctx,actx:ctx,started:false,phase:'intro',paused:false,over:false,enemies:[],isBoss:()=>false,gameMode:'campaign',setInterval(fn){const id={fn};intervals.add(id);return id},clearInterval(id){intervals.delete(id)},setTimeout(){return{}},clearTimeout(){}};
 vm.createContext(box);vm.runInContext(fs.readFileSync('web/src/music.js','utf8')+'\nglobalThis.reviewMusic=MUSIC',box);
 return{box,ctx,sources,gains,intervals,m:box.reviewMusic,resolve:()=>resolveDecode()};
}
const flush=async()=>{for(let i=0;i<20;i++)await Promise.resolve()};
(async()=>{
 const f=fixture();f.m.unlock();await flush();assert.equal(f.m.state().cur,'menu');const count=f.sources.length;
 for(let i=0;i<10;i++)f.m.revive();await flush();assert.equal(f.sources.length,count,'foreground notifications never restart an intact voice');assert.equal(f.intervals.size,1);
 f.m.jingle('victory');await flush();let j=f.sources.at(-1);assert(j.started);assert.equal(j.to.to,f.gains[0],'jingle uses the shared music bus');
 f.box.prefs.musicVol=0;f.m.tick();assert.equal(f.gains[0].gain.value,0,'volume zero mutes current jingle');
 f.box.prefs.music=false;f.m.tick();assert(j.stops?.includes(undefined),'music OFF stops the jingle');assert.equal(f.m.state().voices,0);
 f.box.prefs.music=true;f.box.prefs.musicVol=60;f.m.tick();await flush();f.m.jingle('gameover');await flush();j=f.sources.at(-1);f.box.audioHeld=true;f.m.suspend();assert(j.stops?.includes(undefined));assert.equal(f.gains[0].gain.value,0);assert.equal(f.intervals.size,0,'background stops scheduler');
 f.box.audioHeld=false;f.m.revive();await flush();assert.equal(f.intervals.size,1);
 for(const action of ['mute','background','navigation']){const d=fixture({defer:true});d.m.unlock();await flush();d.resolve();await flush();d.m.jingle('victory');await flush();if(action==='mute')d.box.prefs.music=false;if(action==='background')d.box.document.hidden=true;if(action==='navigation')d.m.cancelJingle();const n=d.sources.length;d.resolve();await flush();assert.equal(d.sources.length,n,`${action} cancels late jingle decode`)}
 assert(f.m.state().cacheBytes<=64*1024*1024);
 console.log('PASS: shared jingle bus, immediate mute/zero, background silence and scheduler, idempotent resume, late-decode cancellation, bounded decoded cache');
})().catch(e=>{console.error(e);process.exitCode=1});
