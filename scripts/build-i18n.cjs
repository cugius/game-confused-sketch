#!/usr/bin/env node
// Compatibility command: all assets now share the reproducible source build.
require('child_process').execFileSync(process.execPath,[require('path').join(__dirname,'build-web.cjs'),...process.argv.slice(2)],{stdio:'inherit'});
