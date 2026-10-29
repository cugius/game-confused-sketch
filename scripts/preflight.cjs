#!/usr/bin/env node
// Focused release-source checks; this is not a full security certification.
const fs=require('fs'),path=require('path'),assert=require('assert');
const {build,translations}=require('./build-web.cjs');
assert.equal(fs.readFileSync('dist/index.html','utf8'),build(),'Offline bundle is stale');
const game=fs.readFileSync('web/src/game.js','utf8'),music=fs.readFileSync('web/src/music.js','utf8'),template=fs.readFileSync('web/src/index.template.html','utf8');
new Function(build().match(/<script>([\s\S]*)<\/script>/)[1]);
const files=[];for(const dir of ['web','ios/ConfusedSketch','scripts','.github/workflows'])walk(dir);
function walk(dir){for(const f of fs.readdirSync(dir,{withFileTypes:true})){const p=path.join(dir,f.name);if(f.isDirectory())walk(p);else if(/\.(js|cjs|swift|yml|html|json|strings)$/.test(p))files.push(p)}}
for(const p of files){const s=fs.readFileSync(p,'utf8');assert(!/-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/.test(s),`Private key in ${p}`);if(p.startsWith('web/'))assert(!/\beval\s*\(|new\s+Function\s*\(/.test(s),`Dynamic code execution in ${p}`)}
const all=game+'\n'+music+'\n'+template, candidates=[];
for(const m of game.matchAll(/function\s+(\w+)\s*\(/g)){const count=(all.match(new RegExp('\\b'+m[1]+'\\b','g'))||[]).length;if(count===1)candidates.push(m[1])}
assert.deepEqual(candidates,[],'Review unreferenced function candidates (including HTML/native entry points)');
for(const p of ['GameCenterBridge.swift','HapticsBridge.swift'])assert(fs.readFileSync('ios/ConfusedSketch/'+p,'utf8').includes('BridgeOrigin.accepts'),'Missing bridge origin validation');
assert(template.includes('connect-src \'none\''),'Unexpected network capability');
const rows=translations();
for(const key of ['Game Center disattivato','Accesso a Game Center…','Dettagli grafici'])assert(rows.some(r=>r[0]===key),'Missing new UI translation: '+key);
console.log('PASS: source/output integrity, syntax, locale columns/placeholders, private-key scan, dynamic-code restriction, bridge guards and dead-function candidates');
