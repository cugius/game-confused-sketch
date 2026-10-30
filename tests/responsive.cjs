// Browser matrix + dynamic translation coverage. Device audio/haptics still need physical tests.
const {chromium}=require('playwright'),fs=require('fs'),path=require('path'),assert=require('assert');
const output=path.resolve('build/ui-review');fs.mkdirSync(output,{recursive:true});
const sizes=[[320,568],[375,667],[393,852],[440,956],[768,1024]],languages=['it','en','es','fr','de','ja'];
const routes={home:'started=false;intro()',audio:"settingsTab='audio';settingsMenu(false)",game:"settingsTab='game';settingsMenu(false)",look:"settingsTab='access';settingsMenu(false)",achievements:'notebook()',guide:"gameMode='campaign';guide()",tutorial:'startTutorial();tutGo(1)',play:"tutEnd();startGame('campaign','grid');hide()"};
(async()=>{const browser=await chromium.launch({headless:true,...(process.env.CHROME_EXECUTABLE?{executablePath:process.env.CHROME_EXECUTABLE,args:['--no-sandbox','--disable-dev-shm-usage','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader']}: {})});const page=await browser.newPage({deviceScaleFactor:2,isMobile:true,hasTouch:true});const errors=[],missing=new Set(),results=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto('file://'+path.resolve('dist/index.html'));await page.evaluate(()=>{window.requestAnimationFrame=()=>0;prefs.fx='std';prefs.music=false;prefs.sound=false;setPref('gfx','classic',true)});
 for(const [width,height] of sizes){console.log('Screen',width,height);await page.setViewportSize({width,height});for(const lang of languages)for(const big of [false,true]){
  await page.evaluate(({lang,big})=>{setLang(lang);prefs.textScale=big?1.15:1;applyPrefs();i18nMiss=new Set()}, {lang,big});
  for(const [route,code] of Object.entries(routes)){if(process.env.UI_TRACE)console.log(width,lang,big,route);
   await page.evaluate(code);await page.evaluate(()=>{i18nApply();resize();draw()});await page.waitForTimeout(20);
   const metrics=await page.evaluate(()=>{const dialog=document.getElementById('dialog'),r=dialog.getBoundingClientRect();return{overflow:document.documentElement.scrollWidth>innerWidth+1,dialog:document.getElementById('overlay').style.display!=='none'?{left:r.left,right:r.right,top:r.top,bottom:r.bottom}:null,missing:[...i18nMiss],memory:performance.memory?.usedJSHeapSize||null}});
   assert(!metrics.overflow,`${route} horizontal overflow at ${width} ${lang} big=${big}`);
   if(metrics.dialog){const d=metrics.dialog;assert(d.left>=-1&&d.right<=width+1&&d.top>=-1&&d.bottom<=height+1,`${route} dialog outside viewport ${width} ${lang} big=${big}: ${JSON.stringify(d)}`)}
   for(const key of metrics.missing)missing.add(key);
   results.push({width,height,lang,big,route,memory:metrics.memory});
   if(process.env.UI_SCREENSHOTS!=='0'&&lang==='en'&&big&&['home','look','achievements','tutorial'].includes(route))await page.screenshot({path:path.join(output,`${width}-${route}.png`),animations:'disabled'});
  }
 }}
 fs.writeFileSync(path.join(output,'matrix.json'),JSON.stringify({results,errors,missing:[...missing].sort()},null,2));await browser.close();assert.deepEqual(errors,[],'Uncaught browser errors');
 // Some keys are proper names/units/attribution, classified explicitly in the committed allowlist.
 const allowed=JSON.parse(fs.readFileSync('tests/i18n-allowlist.json','utf8'));
 const untranslated=[...missing].filter(x=>!Object.hasOwn(allowed,x));fs.writeFileSync(path.join(output,'missing.json'),JSON.stringify(untranslated,null,2));
 assert.deepEqual(untranslated,[],'Review missing dynamic translations; see build/ui-review/missing.json');
 console.log(`PASS: ${results.length} browser routes across screen sizes, languages and text scales`);
})().catch(e=>{console.error(e);process.exitCode=1});
