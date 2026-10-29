// One music bus, bounded decoded cache and cancellable context-owned voices.
const MUSIC=(()=>{
 const XF=3,FADE=.8,CACHE_LIMIT=64*1024*1024;
 const MAP={home:'menu',build:'build',wave:'wave',paths:'paths',boss:'boss'};
 let raw=null,bus=null,unlocked=false,cur=null,want='',busy=false,timer=null,jing=null,generation=0;
 const buffers=new Map(),decoding=new Map(),fading=new Set();
 try{raw=JSON.parse(document.getElementById('music-data').textContent)}catch(_){}
 const ok=()=>!!((window.AudioContext||window.webkitAudioContext)&&raw&&Object.keys(raw).length);
 const blocked=()=>audioHeld||nativeAudioHeld||!!document.hidden;
 const vol=()=>Math.max(0,Math.min(100,Number.isFinite(+prefs.musicVol)?+prefs.musicVol:60))/100;
 const bytes=b=>(b.length||0)*(b.numberOfChannels||1)*4;
 function trim(){let total=[...buffers.values()].reduce((n,b)=>n+bytes(b),0);for(const [id,b] of buffers){if(total<=CACHE_LIMIT)break;if(id===cur?.id||id===jing?.id||[...fading].some(v=>v.id===id))continue;buffers.delete(id);total-=bytes(b)}}
 function context(){return ok()?audioCtx():null}
 function setup(){const c=context();if(c&&!bus){bus=c.createGain();bus.gain.value=0;bus.connect(c.destination)}return c}
 function decode(id){
  if(buffers.has(id)){const b=buffers.get(id);buffers.delete(id);buffers.set(id,b);return Promise.resolve(b)}
  if(decoding.has(id))return decoding.get(id);const c=context();if(!c||!raw?.[id])return Promise.resolve(null);
  const p=Promise.resolve().then(()=>new Promise(resolve=>{let done=false;const finish=b=>{if(done)return;done=true;resolve(b||null)};try{const bin=atob(raw[id]),u=new Uint8Array(bin.length);for(let i=0;i<bin.length;i++)u[i]=bin.charCodeAt(i);const result=c.decodeAudioData(u.buffer,finish,()=>finish(null));if(result?.then)result.then(finish,()=>finish(null))}catch(_){finish(null)}})).then(b=>{if(b){buffers.set(id,b);trim()}return b}).finally(()=>decoding.delete(id));
  decoding.set(id,p);return p;
 }
 function stop(v){if(!v)return;v.dead=true;if(v.timeout)clearTimeout(v.timeout);fading.delete(v);for(const s of v.sources){try{s.onended=null;s.stop();s.disconnect()}catch(_){}}v.sources.length=0;try{v.g.disconnect()}catch(_){}}
 function cancelJingle(){generation++;if(jing){stop(jing);jing=null}}
 function fade(v){if(!v)return;v.dead=true;fading.add(v);const c=actx;try{v.g.gain.cancelScheduledValues(c.currentTime);v.g.gain.setValueAtTime(v.g.gain.value,c.currentTime);v.g.gain.linearRampToValueAtTime(0,c.currentTime+FADE)}catch(_){}v.timeout=setTimeout(()=>stop(v),FADE*1000+40)}
 function voice(id,b){const c=setup(),g=c.createGain();g.gain.value=1;g.connect(bus);const v={id,g,sources:[],dead:false,next:c.currentTime+.02};
  v.pump=()=>{if(v.dead)return;const overlap=Math.min(XF,b.duration/4),period=Math.max(.1,b.duration-overlap);while(v.next<c.currentTime+1){const when=Math.max(v.next,c.currentTime+.02),s=c.createBufferSource(),gain=c.createGain();s.buffer=b;s.connect(gain);gain.connect(g);gain.gain.setValueAtTime(0,when);gain.gain.linearRampToValueAtTime(1,when+overlap);gain.gain.setValueAtTime(1,when+b.duration-overlap);gain.gain.linearRampToValueAtTime(0,when+b.duration);s.start(when);s.stop(when+b.duration+.02);v.sources.push(s);s.onended=()=>{v.sources=v.sources.filter(x=>x!==s);try{s.disconnect();gain.disconnect()}catch(_){}};v.next=when+period}};v.pump();return v;
 }
 function wanted(){if(!prefs.music||blocked())return '';if(!started||phase==='intro')return MAP.home;if(phase==='wave')return enemies.some(e=>!e.dead&&isBoss(e))?MAP.boss:gameMode==='paths'?MAP.paths:MAP.wave;return MAP.build}
 async function switchTo(id){if(busy||!id)return;busy=true;try{const b=await decode(id);if(!b||wanted()!==id||blocked()||!unlocked||!prefs.music||actx?.state!=='running')return;if(cur?.id===id&&!cur.dead)return;if(cur)fade(cur);cur=voice(id,b);trim()}finally{busy=false}}
 function levels(){if(!bus||!actx)return;const now=actx.currentTime;bus.gain.cancelScheduledValues(now);bus.gain.setValueAtTime(prefs.music&&!blocked()?Math.pow(vol(),1.3)*.95:0,now);if(cur&&!cur.dead){cur.g.gain.cancelScheduledValues(now);cur.g.gain.setTargetAtTime((jing&&jing.sources.length)? .12 : (started&&paused&&phase!=='intro')? .35 : over? .4 : 1,now,.12)}}
 function tick(){if(!ok())return;want=wanted();if(!prefs.music){if(timer!==null){clearInterval(timer);timer=null}cancelJingle();if(cur){stop(cur);cur=null}for(const v of [...fading])stop(v)}levels();if(!unlocked||blocked()||!prefs.music||actx?.state!=='running')return;if(want&&(!cur||cur.id!==want||cur.dead))switchTo(want);cur?.pump()}
 function schedule(){if(timer===null&&typeof setInterval==='function')timer=setInterval(tick,250)}
 function unlock(){if(!ok()||blocked())return;const c=setup();if(!c)return;unlocked=true;schedule();tick()}
 function revive(){if(!unlocked||blocked())return;schedule();tick()}
 function suspend(){cancelJingle();if(timer!==null){clearInterval(timer);timer=null}for(const v of [...fading])stop(v);levels()}
 function reset(){suspend();stop(cur);cur=null;try{bus?.disconnect()}catch(_){}bus=null;unlocked=false}
 function jingle(id){cancelJingle();const token=generation;if(!prefs.music||blocked()||!unlocked)return;decode(id).then(b=>{if(!b||token!==generation||!prefs.music||blocked()||!unlocked||actx?.state!=='running')return;const c=setup(),g=c.createGain(),s=c.createBufferSource();g.gain.value=1;g.connect(bus);s.buffer=b;s.connect(g);const v={id,g,sources:[s],dead:false};jing=v;s.onended=()=>{stop(v);if(jing===v)jing=null;levels()};s.start();levels()}).catch(()=>{})}
 return{unlock,revive,tick,jingle,cancelJingle,suspend,reset,available:ok,state:()=>({unlocked,cur:cur?.id,want,ctx:actx?.state,level:bus?.gain.value||0,cacheBytes:[...buffers.values()].reduce((n,b)=>n+bytes(b),0),voices:(cur?1:0)+fading.size+(jing?1:0)})};
})();
