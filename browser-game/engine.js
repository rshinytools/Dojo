'use strict';
(() => {
 const {districts, fighters, trophies} = window.BEAST_CONTENT;
 const clamp = (n,min,max) => Math.max(min,Math.min(max,n));
 const distance = (a,b) => Math.hypot(a.x-b.x,a.y-b.y);
 const centers = [[0,0],[1150,420],[-1150,420],[800,-1000],[-800,-1000],[0,1300]];
 const palettes = [
  ['#679764','#92b779','#326554','#ead49d'], ['#4f9392','#85bab1','#27696d','#eed39d'],
  ['#ad775b','#cf9b72','#774c48','#f2bc78'], ['#7d95ad','#a9bcc5','#4f6586','#e8d9ac'],
  ['#89aeb6','#c4dee0','#537d97','#fff0ce'], ['#737b9b','#9b99b7','#4f5b83','#e8b4a7']
 ];
 const districtsMap = districts.map((district,index) => {
  const [x,y] = centers[index];
  const point = (id,label,dx,dy,kind,extra={}) => ({id,label,x:x+dx,y:y+dy,kind,district:index,...extra});
  return {...district,index,x,y,palette:palettes[index],nodes:[
   point('mentor',district.mentor,-120,70,'mentor'),
   point('route',district.activities[0],-288,170,'route'),
   point('puzzle',district.activities[1],279,135,'puzzle'),
   point('spar',district.arena,-57,-101,'spar'),
   point('seal-0','Hidden seal',-302,-147,'seal',{seal:0}),
   point('seal-1','Hidden seal',325,-124,'seal',{seal:1}),
   point('seal-2','Hidden seal',187,317,'seal',{seal:2}),
   ...(index===0 ? [point('room','Trophy room',220,-100,'room'),point('events','World events',-212,-73,'events'),point('graduation','Graduation court',220,240,'graduation')] : []),
   ...([1,2,3].includes(index) ? [point('boss','Co-op raid gate',180,-279,'boss')] : [])
  ]};
 });
 const arenaModes = [
  {id:'duel',name:'Duels',detail:'One opponent. Win two rounds.',count:1,rounds:2},
  {id:'tag',name:'Tag Team',detail:'Two on two with bots. Swap to your backup when needed.',count:2,rounds:1},
  {id:'brawl',name:'Dojo Brawl',detail:'Eight fighters. Last fighter in the ring wins.',count:7,rounds:1},
  {id:'raid',name:'Co-op Raid',detail:'Fight a boss with three bot allies.',count:1,rounds:1}
 ];
 const bosses = [
  {name:'Kilnback Custodian',id:'world-01',species:3,color:'#c38154'},
  {name:'Abyssal Kraken',id:'world-02',species:11,color:'#658baf'},
  {name:'Solar Phoenix',id:'world-03',species:22,color:'#d99850'}
 ];
 const levelThresholds=[0,80,180,300,460,650,830,1030,1260,1500];
 const levelCap=levelThresholds.length;
 const levelOf=xp=>1+levelThresholds.slice(1).filter(threshold=>xp>=threshold).length;
 const stageOf=xp=>levelOf(xp)===levelCap?'Grandmaster':levelOf(xp)>=5?'Warrior':'Rookie';
 function levelProgress(xp){
  const level=levelOf(xp), next=levelThresholds[level];
  const current=levelThresholds[level-1];
  return {level,next,remaining:next===undefined?0:next-xp,ratio:next===undefined?1:(xp-current)/(next-current)};
 }
 const botTiers={
  beginner:{name:'Beginner',health:78,speed:86,wind:.8,interval:1.35,damage:10},
  standard:{name:'Standard',health:105,speed:102,wind:.55,interval:1.03,damage:13},
  advanced:{name:'Advanced',health:145,speed:131,wind:.36,interval:.76,damage:16}
 };
 const boosts={
  xp:{name:'Training XP',minutes:15},
  strength:{name:'PvE strength',minutes:10}
 };
 const boostRemaining=(p,id,now=Date.now())=>Math.max(0,(p.boosts?.[id]||0)-now);
 const distanceToSegment = (p,a,b) => {
  const dx=b.x-a.x,dy=b.y-a.y;
  const t=clamp(((p.x-a.x)*dx+(p.y-a.y)*dy)/(dx*dx+dy*dy||1),0,1);
  return Math.hypot(p.x-a.x-dx*t,p.y-a.y-dy*t);
 };
 function walkable(p) {
  return districtsMap.some(d=>distance(p,d)<454) || districtsMap.slice(1).some(d=>distanceToSegment(p,districtsMap[0],d)<86);
 }
 const empty = () => ({
  version:1,coins:0,active:0,backup:6,fighterXP:{0:0,6:0},found:[0],checkpoint:0,
  quests:[0,0,0,0,0,0],routes:{},puzzles:[],spar:[],seals:[],trophies:{},shelf:Array(6).fill(null),
  stats:{duels:0,parries:0,matches:0,festival:0},rank:0,track:0,pin:null,theme:0,
  graduated:false,boosts:{},settings:{sound:true,motion:true,touch:false}
 });
 const storageKey='beast-dojo-adventure-v1';
 function validProfile(p) {
  return p?.version===1 && Array.isArray(p.quests) && p.quests.length===6 &&
   ['found','puzzles','spar','seals','shelf'].every(k=>Array.isArray(p[k])) &&
   ['fighterXP','routes','trophies','stats','settings'].every(k=>p[k]&&typeof p[k]==='object') &&
   Number.isInteger(p.checkpoint) && !!districtsMap[p.checkpoint] &&
   Number.isInteger(p.active) && !!fighters[p.active] && Number.isFinite(p.coins);
 }
 function readProfile(storage) {
  try {
   const raw=storage.getItem(storageKey);
   if(raw===null) return {profile:empty(),status:'Ready',canSave:true};
   const profile=JSON.parse(raw);
   if(!validProfile(profile)) throw Error('Invalid save');
   profile.boosts=Object.fromEntries(Object.keys(boosts).flatMap(id=>{
    const until=profile.boosts?.[id];
    return Number.isFinite(until)&&until>0?[[id,until]]:[];
   }));
   return {profile,status:'Restored',canSave:true};
  } catch { return {profile:empty(),status:'Save unavailable',canSave:false}; }
 }
 const elementAdvantage = {Land:'Aquatic',Aquatic:'Magma',Magma:'Sky',Sky:'Land'};
 // Signature styles share five reusable effects. Distances are browser world units.
 const signatures = [
  ['lunge',130,58],['burst',143,45],['burst',150,59],['lunge',145,55],['lunge',121,66],['lunge',197,58],
  ['lunge',169,53],['bolt',202,52],['bolt',242,62],['burst',154,60],['lunge',184,63],['pull',201,64],
  ['trail',144,49],['pull',160,57],['lunge',157,57],['bolt',212,58],['burst',169,64],['bolt',247,66],
  ['lunge',164,51],['pull',171,54],['lunge',191,57],['lunge',169,62],['pull',194,62],['bolt',263,71]
 ];
 const has = (p,id) => Object.hasOwn(p.trophies,id);
 function unlockRule(id) {
  const row=Math.floor(id/6), col=id%6;
  if(id===0||id===6)return {label:'Starter roster',test:()=>true};
  const district=districtsMap[(id+row)%6];
  if(row===0)return {label:'Discover '+district.name,test:p=>p.found.includes(district.index)};
  if(row===1)return {label:'Complete '+district.name+' mentor chapter',test:p=>p.quests[district.index]===4};
  if(row===2)return {label:'Find all seals in '+district.name,test:p=>districtSeals(p,district.index)===3};
  if(id===23)return {label:'Win the Grand Dojo graduation trial',test:p=>p.graduated};
  return {label:'Earn '+(6+col*2)+' trophies',test:p=>Object.keys(p.trophies).length>=6+col*2};
 }
 const districtSeals = (p,d) => p.seals.filter(id=>id.startsWith(d+':')).length;
 const owned = (p,id) => unlockRule(id).test(p);
 function trophyProgress(p,t) {
  const d=districtsMap.find(d=>t.id.endsWith('-'+d.id));
  if(t.id.startsWith('discovery-')) return [districtSeals(p,d.index),3];
  if(t.id.startsWith('mastery-')) return [Number(p.routes[d.index]?.expert||false),1];
  const entries = {
   'journey-01':[Number(p.quests[0]>0),1], 'journey-02':[Number(p.quests[0]===4),1],
   'journey-03':[p.found.length,6], 'journey-04':[Number(Object.values(p.fighterXP).some(x=>stageOf(x)!=='Rookie')),1],
   'journey-05':[p.quests.filter(q=>q===4).length,6], 'journey-06':[Number(p.graduated),1],
   'arena-01':[p.stats.duels,1], 'arena-02':[Number(p.stats.brawl||false),1], 'arena-03':[Number(p.stats.tag||false),1],
   'arena-04':[p.stats.duels,10], 'arena-05':[p.stats.parries,10], 'arena-06':[p.stats.matches,20],
   'world-01':[Number(p.stats.boss0||false),1], 'world-02':[Number(p.stats.boss1||false),1],
   'world-03':[Number(p.stats.boss2||false),1], 'world-04':[Number(p.stats.relay||false),1],
   'world-05':[p.stats.festival,3], 'world-06':[[0,1,2].filter(i=>p.stats['boss'+i]).length+Number(p.stats.relay||false)+Number(p.stats.festival>=3),5]
  };
  return entries[t.id] ?? [0,1];
 }
 function makeGame(storage, events={}) {
  let {profile,status,canSave}=readProfile(storage);
  const state={profile,status,canSave,player:{x:0,y:190,face:1,vx:0,vy:0}, region:0,
   fight:null,activity:null,room:null,target:null,clock:0,lastDash:-10,fx:[],revision:0};
  const emit=(name,detail)=>events[name]?.(detail);
  const say=(message)=>emit('toast',message);
  function save() {
   try {
    if(!state.canSave)throw Error('Storage unavailable');
    storage.setItem(storageKey,JSON.stringify(state.profile));
    state.status='Saved';
   } catch {state.status='Save unavailable';}
   state.revision++;
  }
  function settle(message) {
   const p=state.profile, earned=[];
   for(const t of trophies){
    const [n,goal]=trophyProgress(p,t);
    if(n>=goal&&!has(p,t.id)){
     p.trophies[t.id]=new Date().toISOString();
     earned.push(t.name);
    }
   }
   save();
   if(earned.length) say((state.status==='Saved'?'Trophy earned · ':'Trophy earned in this session · ')+earned.join(' • '));
   else if(message) say(message);
  }
  function reward(coins,xp,message) {
   const p=state.profile;
   const before=levelOf(p.fighterXP[p.active]||0);
   const bonus=boostRemaining(p,'xp')>0?xp:0;
   p.coins+=coins;
   p.fighterXP[p.active]=(p.fighterXP[p.active]||0)+xp+bonus;
   const level=levelOf(p.fighterXP[p.active]);
   settle(level>before?fighters[p.active].name+' reached Lv. '+level:message);
   return {xp:xp+bonus,bonus,before,level,fighter:fighters[p.active].name};
  }
  function activateBoost(id) {
   const p=state.profile;
   if(!Object.hasOwn(boosts,id)||state.fight||state.activity||boostRemaining(p,id)>0)return false;
   p.boosts[id]=Date.now()+boosts[id].minutes*60000;
   save();
   return true;
  }
  function travel(index,allowNew=false) {
   if(!districtsMap[index]||(!allowNew&&!state.profile.found.includes(index))||state.fight||state.activity)return false;
   const d=districtsMap[index];state.room=null;
   Object.assign(state.player,{x:d.x,y:d.y+210,vx:0,vy:0});
   state.target=null; state.region=index; state.profile.checkpoint=index;
   save();return true;
  }
  function reset() {
   state.profile=empty();state.canSave=true;state.fight=null;state.activity=null;
   state.lastDash=-10;state.fx=[];travel(0,true);
  }
  travelInitial();
  function travelInitial() {
   const d=districtsMap[state.profile.checkpoint];
   Object.assign(state.player,{x:d.x,y:d.y+210});
   state.region=d.index;
  }
  function equip(id,backup=false) {
   if(!fighters[id]||!owned(state.profile,id)||state.fight)return false;
   const p=state.profile;
   if(backup&&id===p.active)return false;
   if(!backup&&p.backup===id)p.backup=p.active;
   p[backup?'backup':'active']=id;
   save();return true;
  }
  function display(slot,id) {
   if(!Number.isInteger(slot)||slot<0||slot>=6||id!==null&&!has(state.profile,id))return false;
   const shelf=state.profile.shelf;
   if(id!==null)for(let i=0;i<shelf.length;i++)if(shelf[i]===id)shelf[i]=null;
   shelf[slot]=id;save();return true;
  }
  function nearby() {
   if(state.fight||state.activity)return null;
   const nodes=state.room?state.room.nodes:districtsMap[state.region].nodes;
   return nodes.filter(n=>n.kind!=='seal'||!state.profile.seals.includes(n.district+':'+n.seal))
    .reduce((best,n)=>distance(state.player,n)<(best?distance(state.player,best):76)?n:best,null);
  }
  function approach(node) {
   const d=districtsMap[node.district],from=districtsMap[state.region];
   const entrance=node.kind==='spar'?[{x:node.x,y:node.y+77},node]:[node];
   const queue=state.room||d===from?entrance:[from,districtsMap[0],...(d.index?[d]:[]),...entrance];
   state.target={...node,queue};
  }
  function enterRoom(){
   if(state.fight||state.activity||state.room)return false;
   const returnAt={x:state.player.x,y:state.player.y};
   const nodes=Array.from({length:6},(_,slot)=>({id:'pedestal-'+slot,kind:'pedestal',label:'Inspect pedestal '+(slot+1),slot,x:(slot%3-1)*145,y:slot<3?-84:44}));
   nodes.push({id:'exit',kind:'room-exit',label:'Return to dojo grounds',x:0,y:210});
   state.room={returnAt,nodes};state.target=null;state.fx=[];
   Object.assign(state.player,{x:0,y:177,vx:0,vy:0});return true;
  }
  function exitRoom(){
   if(!state.room)return false;
   Object.assign(state.player,state.room.returnAt,{vx:0,vy:0});state.room=null;state.target=null;state.fx=[];return true;
  }
  function talk(index) {
   const p=state.profile,d=districtsMap[index],step=p.quests[index];
   p.track=index;p.pin=null;
   if(step===0){p.quests[index]=1;reward(20,25,'Mentor chapter started');}
   else if(step===3){p.quests[index]=4;reward(105,150,'Chapter complete');}
   else save();
   return {district:d,step:p.quests[index]};
  }
  function questUpdate(i) {
   const p=state.profile;
   if(p.quests[i]===1&&p.routes[i]&&p.puzzles.includes(i))p.quests[i]=p.spar.includes(i)?3:2;
   if(p.quests[i]===2&&p.spar.includes(i))p.quests[i]=3;
  }
  function collect(node) {
   const key=node.district+':'+node.seal;
   if(state.profile.seals.includes(key))return;
   state.profile.seals.push(key);
   reward(25,30,'Reed seal found · '+districtSeals(state.profile,node.district)+'/3');
  }
  function beginActivity(i,type) {
   if(state.fight||state.activity)return;
   const d=districtsMap[i],p=state.profile;
   if(type==='route'||type==='relay'){
    const start={x:d.x-278,y:d.y+155};
    const patterns=[[[0,0],[62,-95],[175,-140],[260,-40],[170,75],[50,63]],
     [[0,0],[20,100],[146,125],[244,45],[170,-68],[68,-87]],
     [[0,0],[64,75],[190,62],[260,-44],[148,-116],[25,-96]],
     [[0,0],[52,-80],[136,-190],[244,-223],[261,-117],[232,10]],
     [[0,0],[78,54],[181,31],[268,-32],[208,-128],[123,-170]],
     [[0,0],[53,-104],[153,-80],[241,-79],[252,38],[149,109]]];
    const points=patterns[i].map(([x,y])=>({x:d.x-235+x,y:d.y+153+y}));
    Object.assign(state.player,start);
    state.activity={type,i,title:type==='relay'?'Lantern Relay':d.activities[0],points,at:0,time:0,limit:35,expert:16+i};
   } else {
    state.activity={type,i,title:type==='festival'?'Training Festival':d.activities[1],pattern:i%2===0?'timing':'sequence',
     time:0,hits:0,mistakes:0,targetHits:3,phase:0,seq:Array.from({length:4},(_,k)=>(i+k*2+Math.floor(k/2))%3),started:false};
   }
   state.target=null;emit('activity',state.activity);
  }
  function finishActivity(success) {
   const a=state.activity;if(!a)return;
   const p=state.profile;
   let progress=null;
   state.activity=null;
   if(success){
    if(a.type==='route'){
     const prev=p.routes[a.i];
     p.routes[a.i]={best:Math.min(a.time,prev?.best??Infinity),expert:!!prev?.expert||a.time<=a.expert};
    }
    if(a.type==='puzzle'&&!p.puzzles.includes(a.i))p.puzzles.push(a.i);
    if(a.type==='relay')p.stats.relay=true;
    if(a.type==='festival')p.stats.festival=Math.min(3,p.stats.festival+1);
    questUpdate(a.i);
    progress=reward(35,85,'Activity complete');
   }
   emit('activityResult',{success,title:a.title,time:a.time,expert:a.type==='route'&&a.time<=a.expert,progress});
  }
  function timing() {
   const a=state.activity;
   if(!a||!['puzzle','festival'].includes(a.type)||a.pattern!=='timing')return;
   if(Math.abs(a.phase-.5)<.19){
    a.hits++;say('Perfect timing!');
    if(a.hits>=a.targetHits)finishActivity(true);
   } else {a.mistakes++;say('Try when the marker reaches the center');}
  }
  function sequence(choice) {
   const a=state.activity;
   if(!a||a.pattern!=='sequence'||!a.started)return;
   if(a.seq[a.hits]===choice){
    a.hits++;
    if(a.hits===a.seq.length)finishActivity(true);
   } else {a.hits=0;a.mistakes++;a.started=false;a.time=0;emit('activity',a);}
  }
  function actor(id,x,y,team,health,scale=1) {
   const f=fighters[id];
   return {id,name:f.name,x,y,team,hp:health,max:health,face:team==='you'?1:-1,vx:0,vy:0,
    cool:0,phase:'idle',wind:0,next:1,guard:0,inv:0,skill:0,charge:0,flash:0,scale};
  }
  function spawnRound(f) {
   const {mode,round,district,bossIndex}=f;
   const p=state.profile,id=p.active,x=f.x,y=f.y;
   f.hero=actor(id,x-103,y,'you',playerHealth(id));
   const count={duel:1,practice:1,spar:1,tag:2,brawl:7,raid:1,graduation:1}[mode];
   f.enemies=Array.from({length:count},(_,n)=>{
    const angle=mode==='tag'?n*.84-.42:n/count*Math.PI*2+0.16;
    const enemy=actor((district*4+n+round+1)%24,x+Math.cos(angle)*147,y+Math.sin(angle)*147,mode==='brawl'?'rival'+n:'enemy',
     mode==='raid'?500:mode==='graduation'?420:mode==='spar'?92:mode==='brawl'?95:botTiers[f.botTier]?.health??145,mode==='raid'||mode==='graduation'?1.7:1);
    if(mode==='raid'||mode==='graduation'){enemy.id=bosses[bossIndex].species;enemy.name=bosses[bossIndex].name;enemy.color=bosses[bossIndex].color;}
    else enemy.name=mode==='spar'?'Training automaton':fighters[enemy.id].name;
    return enemy;
   });
   f.allies=mode==='raid'?[0,6,12].map((id,n)=>actor(id,x-115+n*90,y+115,'ally',110)):
    mode==='tag'?[actor((id+7)%24,x-92,y+100,'ally',115)]:[];
   f.timer=mode==='raid'||mode==='graduation'?115:mode==='practice'?45:75;
   f.heroBack=null;f.tagUsed=false;f.enemyTag=false;
   f.transition=0;
  }
  function playerHealth(id){
   return Math.round(fighters[id].hp/9)+4*(levelOf(state.profile.fighterXP[id]||0)-1);
  }
  function startFight(mode,i=state.region,bossIndex=0,botTier='') {
   if(state.fight||state.activity||state.room||!districtsMap[i]||!['duel','practice','spar','tag','brawl','raid','graduation'].includes(mode))return false;
   if(mode==='graduation'&&!state.profile.quests.every(q=>q===4))return false;
   if(mode==='practice'&&!Object.hasOwn(botTiers,botTier))return false;
   const d=districtsMap[i];
   state.fight={mode,district:i,bossIndex,botTier:mode==='practice'?botTier:'',round:1,wins:0,losses:0,parries:0,x:d.x,y:d.y-195,returnAt:{x:state.player.x,y:state.player.y}};
   spawnRound(state.fight);state.target=null;emit('fight',state.fight);return true;
  }
  const isOpponent = (a,b) => a!==b&&a.team!==b.team&&!(['you','ally'].includes(a.team)&&['you','ally'].includes(b.team));
  function tag() {
   const f=state.fight,p=state.profile;
   if(f?.mode!=='tag'||f.tagUsed||f.transition||!owned(p,p.backup))return;
   const h=f.hero;
   f.hero=actor(p.backup,h.x,h.y,'you',playerHealth(p.backup));
   f.hero.inv=.6;f.tagUsed=true;say('Backup fighter joined');
  }
  function damage(attacker,target,power,knockback) {
   if(target.inv>0||target.hp<=0)return;
   if(target.guard>0){
    if(target.team==='you'){
     state.fight.parries++;say('Parry!');
     target.charge=Math.min(100,target.charge+20);
     attacker.phase='idle';attacker.next=1.15;attacker.hp=Math.max(0,attacker.hp-7);
     state.fx.push({x:target.x,y:target.y,life:.38,max:.38,color:'#c8f5ad',radius:72});
    }
    return;
   }
   const element=fighters[attacker.id].element, defended=fighters[target.id].element;
   const strength=attacker.team==='you'&&['spar','practice','raid'].includes(state.fight.mode)&&boostRemaining(state.profile,'strength')>0?1.15:1;
   const mult=(elementAdvantage[element]===defended?1.18:elementAdvantage[defended]===element?.88:1)*strength;
   target.hp=Math.max(0,target.hp-Math.round(power*mult));target.inv=.21;target.flash=.21;
   if(attacker.team==='you')attacker.charge=Math.min(100,attacker.charge+Math.round(power*.55));
   if(target.team==='you')target.charge=Math.min(100,target.charge+9);
   const angle=Math.atan2(target.y-attacker.y,target.x-attacker.x);
   const boost=knockback*(1+(1-target.hp/target.max)*.8);
   target.vx+=Math.cos(angle)*boost;target.vy+=Math.sin(angle)*boost;
   if(target.team==='you')emit('sound','hurt');
  }
  function attack(kind) {
   const f=state.fight;
   if(!f||f.transition)return;
   const h=f.hero;
   if(h.hp<=0)return;
   if(kind==='guard'){
    if(h.guardCooldown>0)return;
    h.guard=.43;h.guardCooldown=1.05;emit('sound','guard');return;
   }
   if(kind==='ultimate'){
    if(h.charge<100){say('Charge your signature by landing hits and parries');return;}
    const [effect,range,power]=signatures[h.id];
    const nearby=f.enemies.filter(e=>e.hp>0&&distance(e,h)<range).sort((a,b)=>distance(a,h)-distance(b,h));
    const targets=['bolt','lunge'].includes(effect)?nearby.slice(0,1):nearby;
    h.charge=0;h.swing=.34;h.inv=.23;
    for(const enemy of targets){
     h.face=Math.sign(enemy.x-h.x)||h.face;
     damage(h,enemy,power,effect==='pull'?-148:effect==='trail'?105:320);
    }
    if(effect==='lunge'&&targets[0]){
     const enemy=targets[0],d=distance(enemy,h)||1;
     const stride=Math.max(0,Math.min(64,d-40));
     h.x+=(enemy.x-h.x)/d*stride;h.y+=(enemy.y-h.y)/d*stride;
    }
    state.fx.push({x:h.x,y:h.y,life:.52,max:.52,color:'#ffe184',radius:range,shape:effect});
    say(fighters[h.id].ultimate);emit('sound','hit');return;
   }
   const skill=kind==='skill';
   if((skill?h.skill>0:h.cool>0))return;
   if(skill)h.skill=4.7; else h.cool=.36;
   const species=fighters[h.id],skillRange={Land:108,Aquatic:180,Magma:137,Sky:158}[species.element];
   const range=skill?skillRange:79;
   const targets=f.enemies.filter(a=>a.hp>0&&distance(a,h)<range).sort((a,b)=>distance(h,a)-distance(h,b));
   const power=skill?Math.round(species.attack*.35):Math.round(species.attack*.17);
   for(const enemy of skill?targets:targets.slice(0,1)){
    h.face=Math.sign(enemy.x-h.x)||h.face;
    damage(h,enemy,power,skill?260:118);emit('sound','hit');
   }
   h.swing=.21;
   state.fx.push({x:h.x,y:h.y,life:.26,max:.26,color:skill?'#ffcd69':'#fff2bb',radius:range});
   if(!targets.length)emit('sound','swing');
  }
  function dash(input) {
   if(state.clock-state.lastDash<.9)return;
   const h=state.fight?.hero??state.player;
   const dx=input.x||(!input.y?h.face:0),dy=input.y;
   h.vx+=dx*435;h.vy+=dy*435;h.inv=.29;state.lastDash=state.clock;
   state.fx.push({x:h.x,y:h.y,life:.25,max:.25,color:'#d6f6cf',radius:47});
   emit('sound','dash');
  }
  function returnFromFight(f){
   state.fight=null;
   Object.assign(state.player,f.returnAt,{vx:0,vy:0});
  }
  function awardFight(f,won,place) {
   const p=state.profile, m=f.mode;
   if(!['spar','practice','graduation'].includes(m))p.stats.matches++;
   p.stats.parries=Math.min(10,p.stats.parries+f.parries);
   if(m==='brawl'&&place<=3)p.stats.brawl=true;
   if(won){
    if(m==='duel')p.stats.duels++;
    if(m==='tag')p.stats.tag=true;
    if(m==='raid')p.stats['boss'+f.bossIndex]=true;
    if(m==='spar'&&!p.spar.includes(f.district)){p.spar.push(f.district);questUpdate(f.district);}
    if(m==='graduation')p.graduated=true;
   }
   const coins=won?(m==='raid'?140:m==='graduation'?300:65):10;
   const xp=won?(m==='raid'?230:m==='graduation'?425:105):25;
   const progress=reward(coins,xp,won?'Victory!':'Practice makes progress');
   returnFromFight(f);
   emit('fightResult',{won,place,mode:m,district:f.district,bossIndex:f.bossIndex,botTier:f.botTier,coins,progress});
  }
  function stepFight(dt,input) {
   const f=state.fight,h=f.hero,tier=botTiers[f.botTier];
   if(f.transition>0){
    f.transition-=dt;
    if(f.transition<=0){f.round++;spawnRound(f);}
    return;
   }
   f.timer-=dt;
   h.x+=input.x*192*dt;h.y+=input.y*192*dt;
   if(input.x)h.face=Math.sign(input.x);
   const actors=[h,...f.enemies,...f.allies];
   for(const a of actors) {
    for(const k of ['cool','guard','guardCooldown','inv','skill','flash','swing'])a[k]=Math.max(0,(a[k]||0)-dt);
    if(a.hp<=0)continue;
    a.x+=a.vx*dt;a.y+=a.vy*dt;a.vx*=Math.exp(-6*dt);a.vy*=Math.exp(-6*dt);
    if(distance(a,f)>240){a.hp=0;continue;}
    if(a===h)continue;
    const targets=actors.filter(b=>b.hp>0&&isOpponent(a,b)).sort((l,r)=>distance(a,l)-distance(a,r));
    const target=targets[0];if(!target)continue;
    const d=distance(a,target),range=a.scale>1?94:48;
    a.face=Math.sign(target.x-a.x)||a.face;
    if(a.phase==='wind'){
     a.wind-=dt;
     if(a.wind<=0){
      a.phase='idle';a.next=tier?.interval??(a.scale>1?1.26:1.03);
      a.swing=.22;
      state.fx.push({x:a.x,y:a.y,life:.28,max:.28,color:'#f0966b',radius:range+17});
      for(const b of targets)if(distance(a,b)<range+17)damage(a,b,tier?.damage??(a.team==='ally'?14:a.scale>1?23:13),a.scale>1?196:130);
     }
    }else{
     a.next-=dt;
     if(d>range){
      const speed=tier?.speed??(a.scale>1?67:a.team==='ally'?132:102);
      a.x+=(target.x-a.x)/d*speed*dt;a.y+=(target.y-a.y)/d*speed*dt;
     }else if(a.next<=0){a.phase='wind';a.wind=tier?.wind??(a.scale>1?.85:.55);}
    }
   }
   // Keep crowded fighters readable and prevent bodies sitting at the same point.
   for(let i=0;i<actors.length;i++)for(let j=i+1;j<actors.length;j++){
    const a=actors[i],b=actors[j],gap=distance(a,b);
    if(a.hp>0&&b.hp>0&&gap<26&&gap>.05){
     const overlap=(26-gap)*.23;
     const x=(a.x-b.x)/gap*overlap,y=(a.y-b.y)/gap*overlap;
     a.x+=x;a.y+=y;b.x-=x;b.y-=y;
    }
   }
   if(f.mode==='tag'&&h.hp<=0&&!f.tagUsed){tag();return;}
   const living=f.enemies.filter(e=>e.hp>0);
   if(h.hp>0&&living.length&&f.timer>0)return;
   const won=h.hp>0&&(living.length===0||(['duel','practice'].includes(f.mode)&&h.hp/h.max>living[0].hp/living[0].max));
   if(f.mode==='duel'){
    if(won)f.wins++;else f.losses++;
    if(f.wins<2&&f.losses<2){f.transition=1.05;say(won?'Round won':'Round lost');return;}
    return awardFight(f,f.wins===2,1);
   }
   awardFight(f,won,won?1:living.length+1);
  }
  function tick(dt,input={x:0,y:0}) {
   state.clock+=dt;
   for(const fx of state.fx)fx.life-=dt;
   state.fx=state.fx.filter(fx=>fx.life>0);
   if(state.fight){stepFight(dt,input);return;}
   const h=state.player,a=state.activity;
   if(a){a.time+=dt;a.phase=(Math.sin(a.time*3.5)+1)/2;}
   if(a?.type==='puzzle'||a?.type==='festival')return;
   let {x,y}=input;
   if(x||y)state.target=null;
   if(state.target&&state.target.queue.length){
    const t=state.target.queue[0],d=distance(h,t);
    const last=state.target.queue.length===1;
    if(d<(last&&state.target.kind?45:12)){
     if(last){const node=state.target;state.target=null;if(node.kind)emit('arrive',node);}
     else state.target.queue.shift();
    }else{x=(t.x-h.x)/d;y=(t.y-h.y)/d;}
   }
   if(h.inv>0)h.inv-=dt;
   const speed=230+(fighters[state.profile.active].speed-16)*5;
   const nx=h.x+(x*speed+h.vx)*dt,ny=h.y+(y*speed+h.vy)*dt;
   if(state.room?(Math.abs(nx)<280&&ny>-185&&ny<245):walkable({x:nx,y:ny})){h.x=nx;h.y=ny;}
   if(x)h.face=Math.sign(x);
   h.vx*=Math.exp(-7*dt);h.vy*=Math.exp(-7*dt);
   if(state.room)return;
   const region=districtsMap.find(d=>distance(h,d)<440);
   if(region&&state.region!==region.index){
    state.region=region.index;const p=state.profile;p.checkpoint=region.index;
    if(!p.found.includes(region.index)){p.found.push(region.index);reward(20,45,'Discovered '+region.name);}
    else save();
   }
   const near=nearby();if(near?.kind==='seal'&&distance(h,near)<31)collect(near);
   if(a?.points){
    if(distance(h,a.points[a.at])<31){a.at++;emit('sound','step');}
    if(a.at>=a.points.length)finishActivity(true);
    else if(a.time>a.limit)finishActivity(false);
   }
  }
  function objective() {
   const p=state.profile,d=districtsMap[p.track]||districtsMap[0],q=p.quests[d.index];
   if(p.pin){
    const t=trophies.find(t=>t.id===p.pin);
    if(t&&!has(p,t.id)){const [n,max]=trophyProgress(p,t);return {title:t.name,detail:n+'/'+max+' · '+t.criterion,node:null};}
   }
   if(p.graduated)return {title:'Grand Dojo Graduate',detail:'Revisit trials and complete the collection.',node:null};
   if(p.quests.every(n=>n===4))return {title:'The graduation trial',detail:'Return to the Grand Dojo graduation court.',node:districtsMap[0].nodes.find(n=>n.kind==='graduation')};
   const title=q===0?'Meet the mentor':d.chapter;
   const kind=q===0||q===3?'mentor':q===1?(p.routes[d.index]?'puzzle':'route'):'spar';
   const node=d.nodes.find(n=>n.kind===kind);
   const detail=q===0?'Talk to '+d.mentor+' in '+d.name:q===1?'Complete '+(p.routes[d.index]?d.activities[1]:d.activities[0]):q===2?'Win the guided spar':q===3?'Report back to the mentor':'Open the map and track the next district.';
   return {title,detail,node:q===4?null:node};
  }
  return {state,tick,save,settle,travel,reset,equip,display,nearby,approach,enterRoom,exitRoom,talk,collect,beginActivity,
   finishActivity,timing,sequence,startFight,attack,tag,dash,objective,activateBoost,
   leaveFight:()=>{
    const f=state.fight;if(!f)return;
    if(f.mode!=='practice'){awardFight(f,false,8);return;}
    returnFromFight(f);
    emit('fightResult',{won:false,mode:f.mode,district:f.district,botTier:f.botTier,progress:null});
   }};
 }
 window.BEAST_ENGINE={makeGame,districts:districtsMap,fighters,trophies,bosses,arenaModes,owned,has,stageOf,levelOf,levelCap,levelProgress,botTiers,boosts,boostRemaining,trophyProgress,districtSeals,unlockRule,clamp,distance,walkable};
})();
