'use strict';
(() => {
 const {districts,fighters,owned,stageOf,distance} = window.BEAST_ENGINE;
 const TAU=Math.PI*2;
 const palette={
  Land:['#c68a52','#eac89f','#3b9482'], Aquatic:['#4d7588','#cce1dc','#62bdd2'],
  Magma:['#d17c55','#ffca8b','#d8593e'], Sky:['#939abb','#eee4cc','#b59ad9']
 };
 const colors=['#c68a52','#71a357','#6c7069','#739269','#7d787c','#68ab83','#526c83','#a57659','#db8a83','#769ca9','#6a8eae','#747d9c','#d98867','#c59269','#b18879','#9c995e','#b2745b','#665a69','#cda882','#af9cae','#8b83a5','#bca3a2','#c39463','#6c8ca2'];
 const shape=['ears','frog','ape','shell','round','cat','bird','round','shrimp','walrus','shark','squid','lizard','scorpion','shell','lizard','round','cat','bird','sail','owl','ram','bird','dragon'];
 function poly(c,points,fill,stroke,width=2){
  c.beginPath();c.moveTo(...points[0]);for(const p of points.slice(1))c.lineTo(...p);c.closePath();
  c.fillStyle=fill;c.fill();if(stroke){c.strokeStyle=stroke;c.lineWidth=width;c.stroke();}
 }
 function oval(c,x,y,w,h,color,angle=0){
  c.beginPath();c.ellipse(x,y,Math.max(.01,w),Math.max(.01,h),angle,0,TAU);c.fillStyle=color;c.fill();
 }
 function box(c,x,y,w,h,r,color,stroke){
  c.beginPath();c.roundRect(x,y,w,h,r);c.fillStyle=color;c.fill();
  if(stroke){c.strokeStyle=stroke;c.lineWidth=2;c.stroke();}
 }
 function line(c,points,color,width){
  c.beginPath();c.moveTo(...points[0]);for(const p of points.slice(1))c.lineTo(...p);c.lineCap='round';c.lineJoin='round';c.strokeStyle=color;c.lineWidth=width;c.stroke();
 }
 function rng(seed){
  let s=seed>>>0;
  return ()=>((s=(1664525*s+1013904223)>>>0)/4294967296);
 }
 function drawAnimal(c,{id=0,x=0,y=0,face=1,scale=1,stage='Rookie',motion=0,guard=0,swing=0,flash=0,color},clock=0){
  c.save();c.translate(x,y);
  oval(c,0,0,23*scale,9*scale,'#173a3260');
  c.scale(scale*face,scale);
  const f=fighters[id],type=shape[id],base=color||colors[id],cream=palette[f.element][1],accent=palette[f.element][2],outline='#24352f';
  const bob=motion?Math.sin(clock*17)*Math.min(4,motion):0;
  c.translate(0,bob);
  if(stage==='Grandmaster'){
   oval(c,0,-7,26,11,'#ffeaa271');
   c.strokeStyle='#fdf195';c.lineWidth=2;c.beginPath();c.ellipse(0,-7,30,12,0,0,TAU);c.stroke();
  }
  if(['ears','lizard','cat','scorpion','dragon','shark'].includes(type)){
   line(c,[[-10,-23],[-23,-11],[-37,-13],[-42,-21]],outline,10);
   line(c,[[-10,-23],[-23,-11],[-37,-13],[-42,-21]],base,7);
  }
  if(type==='sail'||type==='dragon')poly(c,[[-8,-58],[-41,-48],[-28,-31],[-12,-27],[28,-36],[33,-54]],accent,outline);
  if(type==='squid')for(let i=0;i<5;i++)line(c,[[i*7-15,-21],[i*10-20,-9],[i*9-18,-3]],base,7);
  for(const dx of [-12,13]){
   oval(c,dx,-7+(dx===13?-bob:bob),13,8,outline);
   oval(c,dx+1,-9+(dx===13?-bob:bob),11,6,base);
  }
  oval(c,-3,-32,24,27,outline);oval(c,-3,-32,22,25,base);oval(c,5,-28,13,17,cream);
  if(type==='shell'){
   oval(c,-12,-32,22,24,'#414a41');oval(c,-14,-34,18,21,accent);
   poly(c,[[-26,-40],[-13,-49],[0,-40],[-3,-27],[-16,-21],[-27,-28]],'#6f894f','#435b46',2);
   line(c,[[-24,-37],[-12,-29],[-9,-21]],'#aac079',2);
  }
  box(c,-21,-21,44,8,3,stage==='Rookie'?accent:'#e3ae55',outline);
  box(c,-2,-22,9,9,2,'#f4cf73');
  if(type==='shark')poly(c,[[-25,-58],[-12,-86],[2,-57]],base,outline);
  if(type==='ears'){
   oval(c,-4,-75,8,25,outline,-.22);oval(c,-4,-75,6,23,base,-.22);oval(c,-4,-78,3,15,'#f2b78e',-.22);
   oval(c,17,-73,7,19,outline,.33);oval(c,17,-73,5,17,base,.33);oval(c,17,-75,2.6,11,'#f2b78e',.33);
  }
  if(['round','ape','cat','sail'].includes(type)){
   for(const dx of [-13,16]){
    if(type==='cat')poly(c,[[dx-8,-58],[dx-5,-83],[dx+10,-62]],base,outline);
    else {oval(c,dx,-66,10,10,outline);oval(c,dx,-67,8,7,base);oval(c,dx,-67,4,4,cream);}
   }
  }
  if(type==='ram')for(const dx of [-18,19]){
   oval(c,dx,-65,13,12,outline);oval(c,dx,-65,11,10,'#dbb47d');oval(c,dx,-65,5,5,base);
  }
  if(type==='dragon')for(const dx of [-14,16])poly(c,[[dx-6,-58],[dx,-83],[dx+7,-62]],cream,outline);
  const headSize=type==='ape'?26:type==='shell'?18:23;
  oval(c,3,-55,headSize,20,outline);oval(c,3,-56,headSize-2,18,flash?'#fff1d3':base);
  if(type==='frog'){
   oval(c,-10,-69,9,9,outline);oval(c,15,-70,9,9,outline);oval(c,-10,-69,7,7,base);oval(c,15,-70,7,7,base);
  }
  if(type==='owl'||type==='bird'){
   oval(c,2,-55,17,14,cream);
   if(id===18)poly(c,[[-8,-69],[-6,-83],[1,-76],[8,-83],[16,-69]],'#e46d54',outline);
  }
  oval(c,-5,-57,5,6,'#fff7dc');oval(c,14,-57,5,6,'#fff7dc');
  oval(c,-3,-57,2.8,3.8,outline);oval(c,16,-57,2.8,3.8,outline);
  line(c,[[-10,-65],[-3,-64]],outline,2);line(c,[[11,-64],[18,-66]],outline,2);
  if(type==='bird'||type==='owl')poly(c,[[1,-52],[20,-48],[8,-40]],'#f3ad53',outline);
  else{
   oval(c,9,-45,15,9,cream);oval(c,14,-48,5.3,4.1,outline);
   line(c,[[14,-45],[12,-41],[7,-41]],outline,1.5);
  }
  if(type==='walrus'){poly(c,[[3,-43],[6,-29],[9,-43]],'#fff1c9',outline);poly(c,[[16,-44],[19,-30],[22,-45]],'#fff1c9',outline);}
  const extension=swing>0?14:0;
  box(c,-30,-46,18,23,6,base,outline);
  box(c,13+extension,-42,22,21,6,accent,outline);
  box(c,15+extension,-42,5,21,2,'#d9e8c4');
  box(c,-31,-43,18,13,3,accent,outline);
  if(id===0)box(c,-31,-47,18,7,2,'#c0a375',outline);
  if(stage!=='Rookie')box(c,13+extension,-40,19,5,2,'#f0bb63');
  if(guard>0){c.strokeStyle='#c1f6c7';c.lineWidth=3;c.beginPath();c.ellipse(0,-35,42,48,0,0,TAU);c.stroke();}
  c.restore();
 }
 function roof(c,x,y,w,h,accent='#297765'){
  const depth=h*.78;
  box(c,x-w*.44,y-depth,w*.88,depth,4,'#d5a36d','#654c39');
  for(const f of [-.36,-.12,.12,.36])box(c,x+w*f-4,y-depth,8,depth+4,2,'#80543c');
  poly(c,[[x-w*.5,y-depth],[x-w*.32,y-depth-h*.48],[x+w*.31,y-depth-h*.48],[x+w*.51,y-depth]],accent,'#395049',3);
  poly(c,[[x-w*.51,y-depth],[x+w*.51,y-depth],[x+w*.45,y-depth+12],[x-w*.46,y-depth+12]],'#254c43');
  line(c,[[x-w*.34,y-depth-h*.47],[x+w*.33,y-depth-h*.47]],'#efc679',4);
  box(c,x-w*.10,y-depth*.83,w*.20,depth*.84,4,'#446951','#ae7f54');
  for(const f of [-.41,.41]){line(c,[[x+w*f,y-depth+4],[x+w*f,y-19]],'#72513c',3);box(c,x+w*f-8,y-24,16,20,4,'#f2bd60','#a97545');}
 }
 function plant(c,d,o){
  const [x,y,s,flavor]=o,[base,lit,dark]=d.palette;
  oval(c,x+7*s,y+4*s,24*s,10*s,'#18372c35');
  if(d.index===2||d.index===3||d.index===4||flavor<.17){
   poly(c,[[x-16*s,y],[x-22*s,y-15*s],[x-10*s,y-29*s],[x+12*s,y-30*s],[x+23*s,y-15*s],[x+15*s,y]],d.index===4?'#d5ece3':base,dark);
   poly(c,[[x-22*s,y-15*s],[x-10*s,y-29*s],[x+12*s,y-30*s],[x+5*s,y-19*s]],lit);
   if(d.index===2)line(c,[[x+3*s,y-25*s],[x-1*s,y-16*s],[x+8*s,y-13*s]],'#f1ba74',2*s);
  }else if(d.index===5){
   box(c,x-9*s,y-37*s,18*s,37*s,3,'#4b536c','#343b53');
   box(c,x-8*s,y-39*s,16*s,10*s,3,'#f9be9a');
   box(c,x-5*s,y-22*s,10*s,12*s,2,'#91d8c8');
  }else{
   line(c,[[x,y],[x+2*s,y-32*s]],'#74593d',7*s);
   oval(c,x,y-32*s,24*s,22*s,dark);
   oval(c,x-8*s,y-39*s,20*s,16*s,base);
   oval(c,x-6*s,y-46*s,15*s,11*s,lit);
   if(flavor>.77)for(let i=0;i<3;i++)oval(c,x+(i-1)*9*s,y-(40+i%2*5)*s,3*s,3*s,'#ead07f');
  }
 }
 function landscape(c,d){
  const x=d.x,y=d.y,[base,lit,dark]=d.palette;
  if(d.index===1){
   for(let i=0;i<4;i++){
    const px=x+272+(i%2)*50,py=y-52-i*45;
    oval(c,px,py,46,28,'#427c77');oval(c,px-2,py-3,39,22,'#80c1b3');
    line(c,[[px-23,py-1],[px-2,py-6],[px+10,py-3]],'#d5e6c1',2);
   }
   poly(c,[[x-120,y-155],[x-38,y-152],[x-63,y-131],[x-109,y-132]],'#9d7252','#5f5650',3);
   line(c,[[x-80,y-142],[x-80,y-206]],'#715a4a',8);
   poly(c,[[x-77,y-203],[x-42,y-169],[x-78,y-167]],'#ddc998','#a99371');
  }else if(d.index===2){
   for(const offset of [-86,80]){
    box(c,x+offset-18,y-148,36,54,6,'#8a5751','#654a43');
    box(c,x+offset-25,y-100,52,12,3,'#dd9a70','#735248');
    box(c,x+offset-10,y-148,20,6,3,'#f4b870');
    oval(c,x+offset+9,y-169,14,9,'#fce6b292');oval(c,x+offset+16,y-186,23,10,'#fce6b24f');
   }
  }else if(d.index===3){
   for(let i=0;i<5;i++){
    const px=x+210+i*27, py=y+28-i*31;
    oval(c,px,py+16,26,15,'#425e7a63');
    poly(c,[[px-22,py+8],[px-20,py-8],[px,py-22],[px+24,py-7],[px+16,py+9]],lit,dark);
   }
  }else if(d.index===4){
   oval(c,x-228,y-115,124,57,dark);oval(c,x-228,y-120,115,51,'#bfe7ea');
   line(c,[[x-310,y-127],[x-255,y-110],[x-235,y-129],[x-181,y-126]],'#76b2c5',3);
   for(const n of [-1,1])poly(c,[[x+n*53,y-99],[x+n*53+8,y-146],[x+n*53+22,y-100]],'#deefe9','#7fa8b0',3);
  }else if(d.index===5){
   for(let i=0;i<4;i++){
    const px=x-201+i*41,py=y-91+i*15;
    box(c,px-15,py-42,33,42,6,'#505d7b','#384358');
    box(c,px-13,py-41,29,6,4,i%2?'#a6d9c9':'#efb1a4');
    box(c,px-6,py-26,15,13,3,base);
   }
  }else{
   oval(c,x+185,y+26,65,40,'#548c82');oval(c,x+185,y+24,55,32,'#8dc2a5');
   for(let i=0;i<4;i++)oval(c,x+150+i*21,y+18+(i%2)*13,10,6,'#477b60');
   for(const px of [x-76,x+121]){
    line(c,[[px,y+74],[px,y+28]],'#865d42',6);box(c,px-8,y+21,16,20,5,'#f9cb71','#8c633d');
   }
  }
 }
 const decoration=districts.map(d=>{
  const r=rng(2709+d.index*42);
  const plants=[],grass=[];
  for(let i=0;i<115;i++){
   const a=r()*TAU,rad=Math.sqrt(r())*428,x=d.x+Math.cos(a)*rad,y=d.y+Math.sin(a)*rad;
   if(rad>130&&d.nodes.every(n=>Math.hypot(n.x-x,n.y-y)>43)) plants.push([x,y,.64+r()*.83,r()]);
  }
  for(let i=0;i<260;i++){
   const a=r()*TAU,rad=Math.sqrt(r())*448;
   grass.push([d.x+Math.cos(a)*rad,d.y+Math.sin(a)*rad,r()*5+1,r()]);
  }
  return {plants,grass};
 });
 const markers={mentor:['!','#f6c15f'],route:['›','#c8f1a5'],puzzle:['✳','#bde9df'],spar:['✦','#f4a785'],boss:['✦','#f4a785'],room:['★','#f5d18c'],events:['✸','#edbc91'],graduation:['◆','#f9e584'],seal:['◇','#f1e291']};
 function badge(c,x,y,text,color,scale=1){
  c.save();c.translate(x,y);c.scale(scale,scale);
  c.font='800 13px system-ui';
  const width=c.measureText(text).width+18;
  box(c,-width/2,-12,width,25,8,'#16362ef5','#b9c494');
  c.fillStyle=color;c.textAlign='center';c.textBaseline='middle';c.fillText(text,0,0);
  c.restore();
 }
 function marker(c,n,highlight,clock){
  const [symbol,color]=markers[n.kind];
  if(n.kind==='seal'){
   oval(c,n.x,n.y,10,4,'#59422f57');
   poly(c,[[n.x,n.y-18],[n.x+7,n.y-8],[n.x,n.y+1],[n.x-7,n.y-8]],color,'#77543d',1.6);
   return;
  }
  if(highlight){oval(c,n.x,n.y,38,21,'#fff8ae64');oval(c,n.x,n.y,32,17,'#163932a0');}
  const float=highlight?Math.sin(clock*3)*4:0;
  box(c,n.x-13,n.y-44+float,26,26,7,color,'#546547');
  c.fillStyle='#193832';c.font='900 19px system-ui';c.textAlign='center';c.textBaseline='middle';
  c.fillText(symbol,n.x,n.y-31+float);
 }
 function drawRing(c,x,y,r,d,combat){
  oval(c,x+7,y+11,r+10,r+10,'#233f365d');
  oval(c,x,y,r+6,r+6,'#5e503c');
  oval(c,x,y,r,r,d.index===2?'#b38164':d.index===4?'#91b5bf':'#c29c6d');
  c.save();c.beginPath();c.arc(x,y,r,0,TAU);c.clip();
  for(let i=-r;i<r;i+=19)line(c,[[x-r,y+i],[x+r,y+i]],'#624b302a',1.5);
  c.restore();
  c.beginPath();c.arc(x,y,r-11,0,TAU);c.lineWidth=3;c.strokeStyle='#f9d68d';c.stroke();
  if(combat){c.beginPath();c.arc(x,y,240,0,TAU);c.lineWidth=4;c.setLineDash([10,10]);c.strokeStyle='#ffbd8a';c.stroke();c.setLineDash([]);}
  oval(c,x,y,40,40,'#f1c88c55');poly(c,[[x,y-24],[x+24,y],[x,y+24],[x-24,y]],'#ead6a87c');
  if(!combat){
   c.beginPath();c.arc(x,y,r-2,0,TAU);c.lineWidth=6;c.strokeStyle='#a54f37';c.stroke();
   for(const angle of [-2.65,-.49,.61,2.53]){
    const px=x+Math.cos(angle)*r,py=y+Math.sin(angle)*r;
    box(c,px-5,py-25,10,26,3,'#943e31','#643b2f');oval(c,px,py-25,6,4,'#fad784');
   }
  }
 }
 function ringEntrance(c,n,selected){
  const {x,y}=n;
  oval(c,x,y+3,42,15,selected?'#ffe092':'#b98252');
  for(const dx of [-62,62]){
   box(c,x+dx-5,y-72,10,72,3,'#9f5035','#6e4134');
   box(c,x+dx-9,y-27,18,23,4,'#f9c968','#8e5537');
  }
  const width=148;
  box(c,x-width/2,y-74,width,35,8,'#ffe08f','#623a2d');
  c.font='950 17px system-ui';c.fillStyle='#422a26';c.textAlign='center';c.textBaseline='middle';
  c.fillText('DOJO RING',x,y-63);
  c.font='700 11px system-ui';
  c.fillText('Combat to Earn Rewards',x,y-48,width-16);
  poly(c,[[x-8,y-40],[x+8,y-40],[x,y-29]],'#ffe08f','#623a2d');
 }
 function nameplate(c,x,y,label){
  c.font='850 14px system-ui';c.textAlign='center';c.textBaseline='middle';
  const words=label.split(' '),lines=[''];
  for(const word of words){
   const last=lines.length-1,next=lines[last]?lines[last]+' '+word:word;
   if(lines[last]&&c.measureText(next).width>120)lines.push(word);else lines[last]=next;
  }
  const width=Math.min(138,Math.max(...lines.map(s=>c.measureText(s).width))+18);
  box(c,x-width/2,y-11,width,12+lines.length*15,7,'#16362ef5','#b9c494');
  c.fillStyle='#fff4d8';lines.forEach((s,index)=>c.fillText(s,x,y+3+index*15,width-12));
 }
 function create(canvas){
  const c=canvas.getContext('2d');
  let w=0,h=0,dpr=1,z=1,camera={x:0,y:175},projected={x:0,y:0},view='';
  function resize(){
   w=canvas.clientWidth;h=canvas.clientHeight;dpr=Math.min(window.devicePixelRatio||1,1.75);
   canvas.width=Math.max(1,Math.floor(w*dpr));canvas.height=Math.max(1,Math.floor(h*dpr));
  }
  function draw(state,{title=false,reduce=false,moving=false}={}){
   const f=state.fight, a=state.activity;
   if(!w||!h)return;
   z=state.room?Math.max(.32,Math.min((w-20)/628,(h-143)/515,1.52)):
    title?Math.max(.54,Math.min(1.5,w/725,h/490)):f?Math.max(.45,Math.min(w/525,(h-125)/505,1.34)):Math.max(.67,Math.min(1.22,w/940,h/570));
   const actor=f?.hero||state.player;
   const nextView=title?'title':f?'fight':state.room?'room':'world';
   const goal=state.room?{x:0,y:-17-25/z}:title?{x:w<650?-25:-70,y:10}:f?{x:f.x,y:f.y-17}:{x:actor.x,y:actor.y-28};
   const gap=distance(camera,goal);
   const rate=title||reduce||gap>490||view!==nextView?1:.16;
   view=nextView;
   camera.x+=(goal.x-camera.x)*rate;camera.y+=(goal.y-camera.y)*rate;
   projected={x:camera.x-w/(2*z),y:camera.y-h/(2*z)};
   c.setTransform(dpr,0,0,dpr,0,0);
   if(state.room){drawRoom();return;}
   const water=c.createLinearGradient(0,0,w,h);water.addColorStop(0,'#78aaa6');water.addColorStop(1,'#457b81');
   c.fillStyle=water;c.fillRect(0,0,w,h);
   c.save();c.scale(z,z);c.translate(-projected.x,-projected.y);
   const within=(x,y,m=140)=>x>projected.x-m&&y>projected.y-m&&x<projected.x+w/z+m&&y<projected.y+h/z+m;
   for(let ix=Math.floor(projected.x/97)-1;ix<(projected.x+w/z)/97+1;ix++){
    for(let iy=Math.floor(projected.y/58)-1;iy<(projected.y+h/z)/58+1;iy++){
     const x=ix*97+Math.cos(iy*2+ix)*19,y=iy*58+Math.sin(ix+iy)*14;
     line(c,[[x-10,y],[x+4,y],[x+13,y-3]],'#c8dfca4a',1.4);
    }
   }
   for(const d of districts.slice(1)){
    const hub=districts[0];
    line(c,[[hub.x,hub.y],[d.x,d.y]],'#3a6867',196);
    line(c,[[hub.x,hub.y],[d.x,d.y]],'#9c8b69',175);
    line(c,[[hub.x,hub.y],[d.x,d.y]],'#d4b784',151);
    const dx=d.x,dy=d.y,len=Math.hypot(dx,dy),ux=dx/len,uy=dy/len;
    for(let n=432;n<len-429;n+=16){
     const x=n*ux,y=n*uy;
     if(within(x,y,100))line(c,[[x-uy*73,y+ux*73],[x+uy*73,y-ux*73]],'#a28b66',2);
    }
   }
   const items=[];
   for(const d of districts){
    if(!within(d.x,d.y,500))continue;
    const [base,lit,dark,path]=d.palette,decor=decoration[d.index];
    oval(c,d.x+7,d.y+17,475,469,dark);
    const grass=c.createRadialGradient(d.x-80,d.y-90,35,d.x,d.y,460);
    grass.addColorStop(0,lit);grass.addColorStop(1,base);
    oval(c,d.x,d.y,456,456,grass);oval(c,d.x+36,d.y-20,235,181,lit+'58');
    for(const [x,y,r,flavor] of decor.grass){
     if(!within(x,y,8))continue;
     if(flavor<.1)oval(c,x,y,r,2,'#f8da97a6');
     else line(c,[[x-3,y+2],[x,y-2-r],[x+3,y+1]],dark+'64',1.5);
    }
    for(const n of d.nodes.filter(n=>n.kind!=='seal')){
     line(c,[[d.x,d.y],[d.x*.35+n.x*.65,d.y*.62+n.y*.38],[n.x,n.y]],dark+'63',59);
     line(c,[[d.x,d.y],[d.x*.35+n.x*.65,d.y*.62+n.y*.38],[n.x,n.y]],path,49);
    }
    landscape(c,d);
    drawRing(c,d.x,d.y-195,f?.district===d.index?232:108,d,f?.district===d.index);
    const inRing=(x,y)=>f?.district===d.index&&Math.hypot(x-f.x,y-f.y)<315;
    const gate=d.nodes.find(n=>n.kind==='spar');
    for(const o of decor.plants){
     const [x,y]=o;
     const isArena=Math.hypot(x-d.x,y-(d.y-195))<133||Math.abs(x-gate.x)<94&&Math.abs(y-gate.y)<80;
     if(within(x,y)&&!inRing(x,y)&&!isArena)items.push({y,paint:()=>plant(c,d,o)});
    }
    for(const n of d.nodes){
     if(!within(n.x,n.y)||inRing(n.x,n.y))continue;
     if(n.kind==='mentor'){
      items.push({y:n.y,paint:()=>drawAnimal(c,{x:n.x,y:n.y,id:(7+d.index*3)%24,scale:1.05,stage:'Warrior'})});
     }else if(n.kind==='room'||n.kind==='boss'){
      items.push({y:n.y,paint:()=>roof(c,n.x,n.y,115,64,dark)});
     }else if(n.kind==='puzzle'||n.kind==='route'||n.kind==='events'||n.kind==='graduation'){
      items.push({y:n.y,paint:()=>{
       oval(c,n.x,n.y,35,17,'#75654880');oval(c,n.x,n.y-3,30,14,'#eee0a3');
       for(let j=-1;j<=1;j++){box(c,n.x+j*13-4,n.y-14,8,12,2,dark);oval(c,n.x+j*13,n.y-15,5,3,'#f9c56c');}
      }});
     }
    }
    if(d.index===0&&!inRing(59,-46))items.push({y:-46,paint:()=>roof(c,59,-46,220,106,'#458773')});
    else if(d.index!==0&&!inRing(d.x+48,d.y-40))items.push({y:-40+d.y,paint:()=>roof(c,d.x+48,d.y-40,119,69,dark)});
    if(!title&&!f&&!a)badge(c,d.x+4,d.y+363,d.name,'#ffebbd',.98);
   }
   if(a?.points) a.points.forEach((p,i)=>{
    if(!within(p.x,p.y))return;
    oval(c,p.x,p.y,26,23,i===a.at?'#fbdc7b':i<a.at?'#b4eab58a':'#36594cd1');
    oval(c,p.x,p.y,20,17,i===a.at?'#417761':'#416452');
    badge(c,p.x,p.y,i<a.at?'✓':String(i+1),'#fff2c1',.85);
   });
   const motions=state.profile.settings.motion;
   if(f){
    for(const v of [f.hero,...f.enemies,...f.allies]){
     if(v.hp<=0)continue;
     if(v.phase==='wind'){
      const radius=v.scale>1?111:65;
      oval(c,v.x,v.y,radius,radius,'#e8795c77');
      c.strokeStyle='#ffe4ad';c.lineWidth=3;c.beginPath();c.arc(v.x,v.y,radius,0,TAU);c.stroke();
      badge(c,v.x,v.y-v.scale*88,'Incoming!','#ffd1a5');
     }
     items.push({y:v.y,paint:()=>drawAnimal(c,{...v,stage:v.team==='you'?stageOf(state.profile.fighterXP[v.id]||0):'Rookie',motion:motions&&(v===f.hero?moving:!v.wind)?2:0},state.clock)});
    }
   }else{
    const p=title?{x:w<650?135:179,y:w<650?110:162,id:0,scale:w<650?1.9:2.52,face:1}:{...state.player,id:state.profile.active,scale:1.19};
    items.push({y:Infinity,paint:()=>drawAnimal(c,{...p,stage:stageOf(state.profile.fighterXP[p.id]||0),motion:motions&&moving?3:0},state.clock)});
   }
   items.sort((p,q)=>p.y-q.y).forEach(i=>i.paint());
   if(!title&&!f&&!a){
    for(const d of districts)for(const n of d.nodes){
     if(!within(n.x,n.y)||n.kind==='seal'&&(state.profile.seals.includes(n.district+':'+n.seal)||distance(actor,n)>145))continue;
     if(n.kind==='spar'){ringEntrance(c,n,state.target?.kind==='spar'&&state.target.district===n.district);continue;}
     const focus=state.objective?.node;
     marker(c,n,focus?.district===n.district&&focus.id===n.id,reduce?0:state.clock);
     if(n.kind!=='seal'&&distance(actor,n)<195)badge(c,n.x,n.y+18,n.label,'#fff3d7',.9);
    }
    if(state.target){
     oval(c,state.target.x,state.target.y,14,7,'#f7e0a3c9');
     oval(c,state.target.x,state.target.y,8,4,'#3e7564');
    }
    if(state.target?.kind==='spar'){
     let current=actor;
     for(const next of state.target.queue){
      const span=distance(current,next);
      for(let i=34;i<span-12;i+=26){
       const x=current.x+(next.x-current.x)*i/span,y=current.y+(next.y-current.y)*i/span;
       oval(c,x,y,6,6,'#593e2c');oval(c,x,y,4,4,'#ffe394');
      }
      current=next;
     }
    }
   }
   if(!reduce)for(const fx of state.fx){
    c.globalAlpha=fx.life/fx.max;c.strokeStyle=fx.color;c.lineWidth=4;
    c.beginPath();c.arc(fx.x,fx.y-14,fx.radius*(.5+(1-fx.life/fx.max)*.5),0,TAU);c.stroke();c.globalAlpha=1;
   }
   c.restore();
   const waypoint=a?.points?.[a.at]||(!f&&!title?state.target?.queue[0]||state.objective?.node:null);
   if(waypoint){
    const px=(waypoint.x-projected.x)*z,py=(waypoint.y-projected.y)*z;
    if(px<32||px>w-32||py<42||py>h-56){
     const dx=px-w/2,dy=py-h/2,edge=Math.min((w/2-31)/Math.max(1,Math.abs(dx)),(h/2-46)/Math.max(1,Math.abs(dy)));
     c.save();c.translate(w/2+dx*edge,h/2+dy*edge);c.rotate(Math.atan2(dy,dx));
     oval(c,0,0,17,17,'#163a32ed');poly(c,[[-6,-8],[9,0],[-6,8]],'#ffe290','#354b38');c.restore();
    }
   }
   function drawRoom(){
    const backdrop=c.createRadialGradient(w*.47,h*.45,55,w*.48,h*.47,Math.max(w,h)*.71);
    backdrop.addColorStop(0,'#416751');backdrop.addColorStop(1,'#152c29');
    c.fillStyle=backdrop;c.fillRect(0,0,w,h);
    c.save();c.scale(z,z);c.translate(-projected.x,-projected.y);
    const floor=['#ad7d53','#956d53','#858297'][state.profile.theme]||'#ad7d53';
    const rug=['#2e6352','#8c5339','#4b5682'][state.profile.theme]||'#2e6352';
    box(c,-303,-224,606,498,22,'#17362b8c');
    box(c,-302,-240,604,504,22,'#614635','#dbad6c');
    box(c,-280,-170,560,414,14,floor,'#755346');
    for(let y=-160;y<240;y+=24)line(c,[[-276,y],[276,y]],'#583d2c51',2);
    box(c,-278,-218,556,61,12,'#936347','#614536');
    for(const x of [-205,205]){
     box(c,x-53,-210,106,41,4,'#fbe6ad','#7b543e');
     for(let j=-39;j<=39;j+=26)line(c,[[x+j,-209],[x+j,-171]],'#a37b54',3);
     line(c,[[x-53,-191],[x+53,-191]],'#a37b54',3);
    }
    box(c,-181,-212,362,43,8,'#284a3e','#d5af6f');
    c.textAlign='center';c.textBaseline='middle';c.font='900 20px system-ui';c.fillStyle='#ffe6a8';c.fillText('HALL OF ACHIEVEMENTS',0,-190);
    box(c,-236,-157,472,269,18,rug,'#d4b577');
    box(c,-227,-148,454,251,14,rug,'#ffffff2c');
    box(c,-70,115,140,99,10,rug,'#d4b577');
    for(const x of [-252,252]){
     const halo=c.createRadialGradient(x,-142,3,x,-142,67);halo.addColorStop(0,'#ffe8aab5');halo.addColorStop(1,'#ffe8aa00');
     c.fillStyle=halo;c.fillRect(x-67,-209,134,134);
     box(c,x-11,-160,22,31,6,'#ffdd86','#926640');
     box(c,x-13,-164,26,6,2,'#614536');box(c,x-13,-132,26,6,2,'#614536');
     oval(c,x,182,20,13,'#7a523b');plant(c,districts[0],[x,181,.62,.86]);
    }
    for(const n of state.room.nodes){
     if(n.kind==='room-exit'){badge(c,n.x,n.y,'Dojo grounds','#ffe4a3');continue;}
     oval(c,n.x,n.y+13,42,16,'#14382c65');box(c,n.x-34,n.y-18,68,32,6,'#a57d55','#513d2d');box(c,n.x-38,n.y-26,76,14,4,'#e4bb78','#775640');
     const id=state.profile.shelf[n.slot],award=window.BEAST_CONTENT.trophies.find(t=>t.id===id);
     if(award)drawAward(c,award.category,n.x,n.y-43);
     nameplate(c,n.x,n.y+25,award?.name||'Empty pedestal');
    }
    drawAnimal(c,{...actor,id:state.profile.active,scale:1.15,stage:stageOf(state.profile.fighterXP[state.profile.active]||0),motion:moving?3:0},state.clock);
    c.restore();
   }
  }
  const point=(event)=>({x:projected.x+event.offsetX/z,y:projected.y+event.offsetY/z});
  return {resize,draw,point};
 }
 function portraits(root){
  for(const canvas of root.querySelectorAll('[data-portrait]')){
   const c=canvas.getContext('2d'),id=Number(canvas.dataset.portrait);
   drawAnimal(c,{id,x:32,y:59,scale:.64,stage:canvas.dataset.stage||'Rookie'});
  }
 }
 function awardArt(root){
  for(const canvas of root.querySelectorAll('[data-award]')){
   drawAward(canvas.getContext('2d'),canvas.dataset.award,canvas.width/2,canvas.height/2);
  }
 }
 function drawAward(c,category,x,y){
   const tint={Journey:'#f7c765',Discovery:'#8bd5ac',Mastery:'#96c9e3',Arena:'#e8a185','World challenges':'#cfb5ed'}[category];
   oval(c,x,y+21,28,6,'#0b252063');
   box(c,x-23,y+15,46,8,3,'#856245');box(c,x-18,y+8,36,8,2,'#c59b64');
   if(!tint)return;
   if(category==='Discovery')poly(c,[[x,y-31],[x+18,y-8],[x,y+9],[x-18,y-8]],tint,'#fcf0c7');
   else if(category==='Mastery')poly(c,[[x,y-31],[x+7,y-16],[x+23,y-15],[x+11,y-4],[x+14,y+12],[x,y+4],[x-15,y+12],[x-12,y-4],[x-23,y-15],[x-7,y-16]],tint,'#fcf0c7');
   else if(category==='World challenges')poly(c,[[x-22,y-15],[x-16,y-28],[x+16,y-28],[x+22,y-15],[x+12,y+7],[x-12,y+7]],tint,'#fcf0c7');
   else{
    c.strokeStyle=tint;c.lineWidth=5; c.beginPath();c.ellipse(x,y-13,24,12,0,0,TAU);c.stroke();
    poly(c,[[x-17,y-29],[x+17,y-29],[x+12,y-7],[x+4,y],[x+4,y+10],[x-4,y+10],[x-4,y],[x-12,y-7]],tint,'#fcf0c7');
    line(c,[[x-9,y-24],[x-6,y-13]],'#fff3c3',3);
   }
 }
 window.BEAST_ART={create,portraits,awardArt};
})();
