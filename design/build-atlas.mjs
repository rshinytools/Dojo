// Rebuild the self-contained inline UI study. No network or external dependencies.
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import {fileURLToPath} from 'node:url';
const here=path.dirname(fileURLToPath(import.meta.url));
const output=path.resolve(process.argv[2] || path.join(here,'preview.fragment.html'));
const data=JSON.parse(fs.readFileSync(path.join(here,'ui-system.json'),'utf8'));
let html=fs.readFileSync(path.join(here,'beast-dojo-ui.fragment.html'),'utf8');
html=html.replace('__BD_SYSTEM_DATA__',JSON.stringify(data).replaceAll('<','\\u003c'));
const art=fs.readFileSync(path.join(here,'assets/fighter-portrait-atlas.webp')).toString('base64');
html=html.replace('--bd-radius:20px','--bd-radius:20px;--bd-art:url(data:image/webp;base64,'+art+')');
for(const script of html.matchAll(/<script>([\s\S]*?)<\/script>/g))new vm.Script(script[1]);
if(Buffer.byteLength(html)>=1000000)throw new Error('Inline study exceeds the 1 MB limit.');
fs.writeFileSync(output,html);
console.log(JSON.stringify({output,bytes:Buffer.byteLength(html),syntax:'valid',screenFamilies:data.screens.length,components:data.components.length,colorTokens:Object.keys(data.colors).length}));
