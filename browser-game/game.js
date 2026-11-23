'use strict';
(() => {
 const engine=window.BEAST_ENGINE, art=window.BEAST_ART;
 const {districts,fighters,trophies,bosses,arenaModes,stageOf,levelCap,levelProgress,botTiers,boosts,boostRemaining,owned,has,trophyProgress,districtSeals,unlockRule,distance,walkable}=engine;
 const $=id=>document.getElementById(id), shell=$('game'), canvas=$('world'), panel=$('panel'), overlay=$('overlay');
 const scene=art.create(canvas);
 const showroom=new URLSearchParams(location.search).get('showroom')==='1';
 const input={keys:new Set(),stick:{x:0,y:0},pad:{x:0,y:0},kind:matchMedia('(pointer:coarse)').matches?'touch':'keys',padButtons:[]};
 let started=false, modal='', priorFocus=null, toastUntil=0, filter='All', fighterFilter='All', frameTime=0, lastUI=0;
 let fightResult=null, activityResult=null, audio=null, pendingNode=null, queue=null, practice=null;
 const demoWait=8;
 const queueSeconds=()=>Math.floor((performance.now()-queue.started)/1000);
 const text=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
 const action=(label,key,{primary=false,disabled=false}={})=>'<button type="button" data-command="'+key+'" class="'+(primary?'primary':'')+'" '+(disabled?'disabled':'')+'>'+text(label)+'</button>';
 const card=(title,html,cls='')=>'<article class="entry '+cls+'"><h3>'+text(title)+'</h3>'+html+'</article>';
 const paragraph=s=>'<p>'+text(s)+'</p>';
 const row=html=>'<div class="panel-actions">'+html+'</div>';
 const grid=items=>'<div class="panel-grid">'+items.join('')+'</div>';
 function progressLabel(xp){
  const {level,remaining}=levelProgress(xp);
  return 'Lv. '+level+' / '+levelCap+' · '+stageOf(xp)+' · '+(remaining?remaining+' XP to next level':'Max level');
 }
 function progressNote(progress){
  return progress.level>progress.before?paragraph(progress.fighter+' reached Level '+progress.level+' · '+stageOf(state.profile.fighterXP[state.profile.active])):'';
 }
 function toast(s){$('toast').textContent=s;$('toast').hidden=false;toastUntil=performance.now()+3000;}
 function sound(kind){
  if(!state.profile.settings.sound||!audio||audio.state!=='running')return;
  const frequency={step:590,hit:182,swing:335,guard:700,hurt:115,dash:260}[kind]||440;
  const voice=audio.createOscillator(),env=audio.createGain(),now=audio.currentTime;
  voice.type=kind==='hit'?'triangle':'sine';voice.frequency.setValueAtTime(frequency,now);
  voice.frequency.exponentialRampToValueAtTime(Math.max(45,frequency*.63),now+.12);
  env.gain.setValueAtTime(.08,now);env.gain.exponentialRampToValueAtTime(.001,now+.16);
  voice.connect(env);env.connect(audio.destination);voice.start(now);voice.stop(now+.17);
 }
 function initAudio(){
  try{audio ||= new (window.AudioContext||window.webkitAudioContext)();audio.resume().catch(()=>{});}catch{}
 }
 const storage=showroom?{getItem:()=>null,setItem:()=>{}}:{
  getItem:k=>localStorage.getItem(k),setItem:(k,v)=>localStorage.setItem(k,v)
 };
 const game=engine.makeGame(storage,{
  toast,sound,arrive:interact,
  activity:a=>{if(a.pattern)show('challenge');},
  activityResult:r=>{activityResult=r;show('activity-result');},
  fight:()=>{closePanel();updateHUD();},
  fightResult:r=>{fightResult=r;show('fight-result');}
 });
 const state=game.state;
 const fighter=()=>fighters[state.profile.active];
 function setInput(kind){
  if(input.kind!==kind){input.kind=kind;updateHUD();}
 }
 function show(id,remember=true){
  if(!modal&&remember)priorFocus=document.activeElement;
  if(id!=='queue')queue=null;
  modal=id;overlay.hidden=false;paintPanel();
  panel.scrollTop=0;
 }
 function closePanel(){
  if(modal==='challenge'){game.finishActivity(false);return;}
  modal='';queue=null;overlay.hidden=true;
  if(priorFocus?.isConnected&&priorFocus.getClientRects().length)priorFocus.focus({preventScroll:true});
  priorFocus=null;
 }
 function paintPanel(){
  const p=state.profile, district=districts[state.region];
  let title='',category='',body='';
  if(modal==='controls'||modal==='settings'){
   title=modal==='controls'?'Controls':'Settings';category='Beast Dojo';
   body=grid([
    card('Keyboard',paragraph('WASD or arrow keys move. E interacts. J strikes, K uses a style skill, I uses a charged signature, L parries, Space dashes and R tags your backup.')),
    card('Touch',paragraph('Drag the left stick to walk or tap a marked place to approach. Use the action buttons on the right. Signature lights up when it is ready.')),
    card('Gamepad',paragraph('Left stick moves. A / Cross interacts, X / Square strikes, Y / Triangle uses skill, B / Circle guards, LB / L1 dashes, RT / R2 uses your signature and RB / R1 tags. Menu opens the journal. Use the directional pad to select.')),
    card('Progress',paragraph('Quests, fighters, trophies and room decorations save in this browser. The world restores the last district you reached.'))
   ]);
   if(modal==='settings'){
    body+=row(action(p.settings.sound?'Sound on':'Sound off','setting:sound')+action(p.settings.motion?'Effects on':'Reduced effects','setting:motion')+action(p.settings.touch?'Touch controls on':'Touch controls auto','setting:touch'));
    body+=paragraph('Browser save status · '+state.status)+row(action('Restart adventure…','reset-confirm'));
   }
  }else if(modal==='reset-confirm'){
   title='Restart adventure?';category='Settings';
   body=paragraph('This clears the Beast Dojo progress stored by this browser. The next session starts in Dojo Valley.')+row(action('Keep my progress','panel:settings',{primary:true})+action('Reset browser save','reset'));
  }else if(modal==='mentor'){
   const d=districts[pendingNode.district], step=p.quests[d.index];
   title=d.mentor;category=d.name;
   const greeting=[
    'A steady step matters more than a fast one. Follow the reed path, then try the lantern drill.',
    'The tide makes paths appear and disappear. Follow the markers and learn the harbor signals.',
    'The workshop is humming again. Try the steam path and listen to the bellows.',
    'Find your balance before the wind changes. The bridges and the chimes will show you how.',
    'The gardens reward patience. Follow the ice marks and bring light to the reflectors.',
    'The circuit is ready to light up. Try the rooftop route and trace the signal.'
   ][d.index];
   body=paragraph(step===4?'That chapter is recorded in your journal. The Grand Dojo is proud of your progress.':step===2?'You have learned the district’s drills. The training court is ready for your guided spar.':greeting);
   body+=card(d.chapter,paragraph(d.steps[Math.min(2,Math.max(0,step-1))])+row(action(step===4?'See the world map':'Continue exploring',step===4?'panel:map':'close',{primary:true})));
  }else if(modal==='map'){
   title='World map';category=p.found.length+' of 6 districts discovered';
   body=paragraph('Follow the bridges from the Grand Dojo. A gold fighting ring sign marks the local arena.');
   body+='<div class="world-map">'+districts.map(d=>'<button style="--region:'+d.palette[2]+'" data-command="region:'+d.index+'">'+text(d.name)+'<small>'+(p.found.includes(d.index)?(p.quests[d.index]===4?'Chapter complete':'Discovered'):'Unexplored')+(d.index===state.region?' · Here':'')+'</small></button>').join('')+'</div>';
   body+=row(action('Return to Grand Dojo','travel:0')+action('World journal','panel:journal'));
  }else if(modal==='region'){
   const d=districts[pendingNode.district];title=d.name;category=d.landmark;
   body=paragraph(d.chapter+' · '+districtSeals(p,d.index)+' / 3 seals found');
   body+=grid(d.nodes.filter(n=>['mentor','route','puzzle','spar','boss'].includes(n.kind)).map(n=>card(n.kind==='spar'?'Fighting ring':n.label,
    (n.kind==='spar'?paragraph(n.label):'')+action(n.kind==='spar'?'Guide me to the ring':'Set destination','go:'+d.index+':'+n.id,{primary:n.kind==='spar'}))));
   body+=row(action('Track this chapter','track:'+d.index)+action('Fast travel','travel:'+d.index,{disabled:!p.found.includes(d.index)})+action('Back to map','panel:map'));
  }else if(modal==='journal'){
   title='Field journal';category=p.quests.filter(n=>n===4).length+' of 6 mentor chapters';
   const current=game.objective();
   body=card(current.title,paragraph(current.detail)+row(current.node?action('Follow objective','objective',{primary:true}):action('Choose a district','panel:map',{primary:true})));
   body+=grid(districts.map(d=>card(d.name,paragraph(d.chapter)+
    '<small>'+(['Find the mentor','Complete both activities','Win the guided spar','Return to the mentor','Chapter complete'][p.quests[d.index]])+' · '+districtSeals(p,d.index)+'/3 seals</small>'+action('View district','region:'+d.index))));
  }else if(modal==='fighters'){
   title='Fighter collection';category=fighters.filter(f=>owned(p,f.id)).length+' of '+fighters.length+' available';
   body='<div class="filters"><label for="fighter-filter">Element</label><select id="fighter-filter">'+['All','Land','Aquatic','Magma','Sky'].map(k=>'<option '+(k===fighterFilter?'selected':'')+'>'+k+'</option>').join('')+'</select></div>';
   body+=grid(fighters.filter(f=>fighterFilter==='All'||f.element===fighterFilter).map(f=>{
    const unlocked=owned(p,f.id), xp=p.fighterXP[f.id]||0;
    return '<article class="entry fighter-card '+(unlocked?'earned':'')+'"><canvas class="portrait" width="64" height="64" data-portrait="'+f.id+'" data-stage="'+stageOf(xp)+'"></canvas><div><span class="tag">'+f.element+' · '+f.rarity+' · '+f.role+'</span><h3>'+text(f.name)+'</h3><small>'+text(f.ultimate)+'</small>'+
     paragraph(unlocked?progressLabel(xp):unlockRule(f.id).label)+
     (unlocked?row(action(f.id===p.active?'Equipped':'Equip','equip:'+f.id,{primary:f.id!==p.active,disabled:f.id===p.active})+
       (f.id===p.active?'':action(f.id===p.backup?'Backup set':'Set backup','backup:'+f.id,{disabled:f.id===p.backup}))):'')+'</div></article>';
   }));
  }else if(modal==='trophies'){
   title='Trophy collection';category=Object.keys(p.trophies).length+' of '+trophies.length+' earned';
   body='<div class="filters"><label for="trophy-filter">Category</label><select id="trophy-filter">'+['All','Journey','Discovery','Mastery','Arena','World challenges'].map(k=>'<option '+(k===filter?'selected':'')+'>'+k+'</option>').join('')+'</select>'+action('My trophy room','panel:room',{primary:true})+'</div>';
   body+=grid(trophies.filter(t=>filter==='All'||t.category===filter).map(t=>{
    const earned=has(p,t.id), [amount,goal]=trophyProgress(p,t);
    return card(t.name,'<span class="tag">'+text(t.category)+' · '+(earned?'Earned':'In progress')+'</span>'+paragraph(t.criterion)+
     '<small>'+(earned?'Earned '+new Date(p.trophies[t.id]).toLocaleDateString():Math.min(amount,goal)+' / '+goal)+'</small>'+
     (earned?action('Display trophy','pick:'+t.id):action(p.pin===t.id?'Tracked':'Track goal','pin:'+t.id,{disabled:p.pin===t.id})),earned?'earned':'');
   }));
  }else if(modal==='room'){
   title='Your trophy room';category='Personal dojo';
   body='<div class="room-display theme-'+p.theme+'">'+p.shelf.map((id,slot)=>{
    const t=trophies.find(t=>t.id===id);
    return '<article class="pedestal"><canvas width="80" height="76" data-award="'+(t?.category||'')+'"></canvas><strong>'+text(t?.name||'Empty pedestal')+'</strong>'+action(t?'Change display':'Choose trophy','slot:'+slot)+'</article>';
   }).join('')+'</div>';
   body+=row(action(state.room?'Walk around the room':'Enter trophy room',state.room?'close':'enter-room',{primary:true})+action('Change room style','theme')+action('Browse collection','panel:trophies')+(state.room?action('Return to the grounds','exit-room'):'')+'<a class="game-link" href="?showroom=1" target="_blank" rel="noopener">See a furnished room</a>');
  }else if(modal==='slot'||modal==='pick'){
   const picking=modal==='pick';
   title=picking?'Choose a pedestal':'Choose a trophy';category='Personal dojo';
   body=picking?grid(p.shelf.map((id,i)=>card('Pedestal '+(i+1),paragraph(trophies.find(t=>t.id===id)?.name||'Empty')+action('Place here','place:'+i+':'+pendingNode.trophy,{primary:true})))) :
    grid(trophies.filter(t=>has(p,t.id)).map(t=>card(t.name,action('Place trophy','place:'+pendingNode.slot+':'+t.id,{primary:true}))));
   if(!picking)body+=row(action('Clear pedestal','place:'+pendingNode.slot+':none')+action('Back to room','panel:room'));
   if(!picking&&Object.keys(p.trophies).length===0)body+=paragraph('Meet the Reed court keeper to earn your first trophy.');
  }else if(modal==='arena'||modal==='ring'){
   const atRing=modal==='ring',d=atRing?districts[pendingNode.district]:district;
   title=atRing?'Fighting ring':'Arena matches';category=d.arena+' · Browser edition';
   body=paragraph(fighter().name+' · '+progressLabel(p.fighterXP[p.active]||0));
   body+=grid([
    card('Fight a bot',paragraph('Choose a difficulty, play one round and earn fighter XP.')+action('Choose a bot','practice:'+d.index,{primary:true}),'earned'),
    card('Matchmaking preview',paragraph('Try the search, wait and match-found flow. All queue activity is simulated.')+row(action('Join casual queue','queue:casual:'+d.index)+action('Join ranked queue','queue:ranked:'+d.index)))
   ]);
   body+=atRing?card('Guided spar',paragraph('A win against the training automaton counts toward this district’s mentor chapter.')+action('Start guided spar','fight:spar')):
    row(action('Guide me to the ring','go:'+d.index+':spar'));
   body+=grid(arenaModes.map(m=>card(m.name,paragraph(m.id==='duel'?'Best of three against a computer-controlled fighter.':m.detail)+action(m.id==='raid'?'Choose a boss':'Enter '+m.name,'fight:'+m.id))));
   body+=row(action('Boost preview','panel:boosts')+action('Fighter collection','panel:fighters'));
  }else if(modal==='practice'){
   title='Choose a bot';category=districts[practice.district].arena+' · Practice';
   const detail={beginner:'Slow attacks with clear wind-ups. Start here to learn the controls.',standard:'Faster movement and shorter openings.',advanced:'Fast approaches, short wind-ups and frequent attacks.'};
   body=paragraph('One round · Fighter XP on completion')+grid(Object.entries(botTiers).map(([id,tier])=>
    card(tier.name,paragraph(detail[id])+action('Fight '+tier.name+' bot','fight-bot:'+id,{primary:id==='beginner'}))));
   body+=row(action('Back to arena','panel:arena'));
  }else if(modal==='queue'){
   const ranked=queue.mode==='ranked', elapsed=queueSeconds();
   title=ranked?'Ranked queue':'Casual queue';category='Simulated matchmaking';
   if(queue.found){
    body=card('Match found',paragraph('Sample opponent · Similar skill · Good connection')+
     paragraph('In Roblox, accepting sends the matched players to a reserved ring.')+
     row(action('Accept preview','finish-queue',{primary:true})+action('Decline','cancel-queue')),'earned');
   }else{
    const stage=elapsed<4?'Searching nearby skill ratings':elapsed<demoWait?'Widening the skill range':'Searching for more players';
    body=card(stage,'<p>Elapsed · <time id="queue-elapsed">'+elapsed+'s</time></p>'+
     '<progress id="queue-progress" aria-label="Initial search progress" max="'+demoWait+'" value="'+Math.min(elapsed,demoWait)+'"></progress>');
    body+=paragraph(ranked?'Ranked pairs human players at a normalized combat baseline.':'Casual looks for humans first. You can switch to practice after the initial search.');
    if(!ranked&&queue.offer&&!queue.keptWaiting)body+=card('Want to fight now?',paragraph('Leave the queue and pick a labeled practice bot.')+
     row(action('Play with a bot','practice:'+queue.district,{primary:true})+action('Keep waiting','keep-queue')),'earned');
    body+=row((queue.offer?action('Preview match found','preview-match'):'')+action('Cancel queue','cancel-queue'));
   }
  }else if(modal==='queue-complete'){
   title='Match accepted';category='Simulated matchmaking';
   body=paragraph('The reserved ring handoff is the next step in the Roblox version.')+row(action('Back to arena','panel:arena',{primary:true}));
  }else if(modal==='boosts'){
   title='Boost preview';category='Free browser simulation';
   body=paragraph('Try a boost for free. Roblox products would show their actual Robux price before purchase.');
   body+=grid(Object.entries(boosts).map(([id,boost])=>{
    const remaining=boostRemaining(p,id);
    const info=id==='xp'?'Earn 2× fighter XP from activities and battles for 15 minutes.':'Deal 15% more damage in guided sparring, bot practice and standard raids for 10 minutes.';
    return card(boost.name,paragraph(info)+(remaining?'<small data-boost-time="'+id+'">Active · '+timeLeft(remaining)+'</small>':'')+
     action(remaining?'Active':'Try free boost','boost:'+id,{primary:!remaining,disabled:!!remaining}),remaining?'earned':'');
   }));
   body+=paragraph('Timers continue while you are away. Arena PvP rules exclude paid combat boosts.')+row(action('Back to arena','panel:arena'));
  }else if(modal==='bosses'){
   title='Co-op raid';category='Choose a boss';
   body=grid(bosses.map((b,i)=>card(b.name,paragraph('Three dojo fighters join your party. Watch for the boss’s marked attack zone.')+action('Enter raid','fight:raid:'+i,{primary:true}))));
  }else if(modal==='events'){
   title='World events';category='Grand Dojo';
   body=grid([card('Lantern Relay',paragraph('Run the marked lantern route. Finish it to earn the Lantern Keeper trophy.')+action('Start relay','activity:relay')),
    card('Training Festival',paragraph('Complete the dojo timing challenge. Your festival trophy records up to three completions.')+action('Start activity','activity:festival'))]);
  }else if(modal==='graduation'){
   title='Grand Dojo graduation';category=p.quests.filter(q=>q===4).length+' of 6 chapters complete';
   body=paragraph('Complete the six mentor chapters, then face the Kilnback Custodian in a solo mastery trial.');
   body+=row(action('Begin graduation trial','fight:graduation:0',{primary:true,disabled:!p.quests.every(q=>q===4)})+action('World journal','panel:journal'));
  }else if(modal==='challenge'){
   const a=state.activity;if(!a){closePanel();return;}
   title=a.title;category=districts[a.i].name;
   if(a.pattern==='timing'){
    body=paragraph('Strike when the marker enters the gold band. Land three good strikes.')+
     '<div class="timing-track"><div></div><i id="timing-marker"></i></div><p id="puzzle-progress"></p>'+
     row(action('Strike on the beat','timing',{primary:true}));
   }else{
    const names=['Reed','Wave','Spark'];
    body=paragraph(a.started?'Repeat the four lanterns in order.':'Remember the order of these four lanterns.');
    if(!a.started)body+='<div class="sequence">'+a.seq.map(n=>'<span>'+names[n]+'</span>').join('')+'</div>'+row(action('I’m ready','begin-sequence',{primary:true}));
    else body+='<p id="puzzle-progress"></p>'+row(names.map((n,i)=>action(n,'sequence:'+i,{primary:i===0})).join(''));
    if(a.mistakes>0&&!a.started)body+=paragraph('Try the sequence again from the beginning.');
   }
  }else if(modal==='fight-result'){
   const r=fightResult;
   title=r.won?(r.mode==='graduation'?'Grand Dojo Graduate':'Victory!'):'Round complete';category=r.mode==='brawl'?'Placement '+r.place:districts[r.district].arena;
   body=paragraph(r.mode==='graduation'&&r.won?'You finished the six mentor chapters and won the graduation trial. Your final trophy is ready to display.':r.won?'Your fighter is ready for the next challenge.':'Read the incoming attack, dash away, or parry just before it lands.');
   const {progress}=r;
   if(progress)body+=card('Rewards',paragraph('+'+r.coins+' coins · +'+progress.xp+' fighter XP'+(progress.bonus?' · '+progress.bonus+' boost XP included':''))+
    progressNote(progress)+'<small>'+text(state.status)+'</small>');
   if(r.mode==='practice')body+=paragraph('Practice · '+botTiers[r.botTier].name+' bot');
   body+=row(action('Back to the world','close',{primary:true})+
    (r.mode==='practice'?action('Rematch','fight-bot:'+r.botTier)+action('Choose another bot','practice:'+r.district):action('Rematch','fight:'+r.mode+':'+r.bossIndex))+
    action('Trophy collection','panel:trophies'));
  }else if(modal==='activity-result'){
   const r=activityResult;
   title=r.success?(r.expert?'Expert clear!':'Activity complete'):'Activity ended';category=r.title;
   body=paragraph(r.success?'Your activity progress has been recorded for this session. '+state.status:'Try again from the activity marker when you are ready.');
   if(r.progress)body+=paragraph('+'+r.progress.xp+' fighter XP'+(r.progress.bonus?' · XP boost applied':''))+progressNote(r.progress);
   body+=row(action('Return to the world','close',{primary:true})+action('View journal','panel:journal'));
  }else if(modal==='activity-pause'){
   title='Activity paused';category=state.activity.title;
   body=row(action('Keep going','close',{primary:true})+action('End activity','end-activity'));
  }else{
   title='Paused';category='Beast Dojo';
   body=row(action('Keep fighting','close',{primary:true})+action('Leave match','leave'));
  }
  const prior=panel.contains(document.activeElement)?document.activeElement.dataset.command:null;
  panel.innerHTML='<header class="panel-head"><div><small>'+text(category)+'</small><h2 id="panel-title">'+text(title)+'</h2></div>'+action(modal==='challenge'?'End activity':'Close','close')+'</header>'+body;
  art.portraits(panel);art.awardArt(panel);updateActivity();
  const selected=prior&&[...panel.querySelectorAll('[data-command]')].find(b=>b.dataset.command===prior&&!b.disabled);
  (selected||panel.querySelector('.primary:not(:disabled)')||panel.querySelector('[data-command="cancel-queue"]')||panel.querySelector('button'))?.focus({preventScroll:true});
 }
 function timeLeft(milliseconds){
  const seconds=Math.ceil(milliseconds/1000);
  return Math.floor(seconds/60)+':'+String(seconds%60).padStart(2,'0');
 }
 function updateTimedPanels(){
  if(modal==='queue'&&!queue.found){
   const elapsed=queueSeconds(), stage=elapsed<4?0:elapsed<demoWait?1:2;
   if(stage!==queue.stage){
    queue.stage=stage;queue.offer=stage===2;paintPanel();
   }
   const label=$('queue-elapsed');
   if(label.textContent!==elapsed+'s')label.textContent=elapsed+'s';
   $('queue-progress').value=Math.min(elapsed,demoWait);
  }
  if(modal==='boosts'){
   for(const label of panel.querySelectorAll('[data-boost-time]')){
    const remaining=boostRemaining(state.profile,label.dataset.boostTime);
    if(!remaining){paintPanel();break;}
    const value='Active · '+timeLeft(remaining);
    if(label.textContent!==value)label.textContent=value;
   }
  }
 }
 function start(){
  if(started)return;
  started=true;initAudio();
  $('title-screen').hidden=true;
  for(const id of ['hud','menu','objective'])$(id).hidden=false;
  if(state.status==='Restored')toast('Welcome back to '+districts[state.region].name);
  else if(!state.canSave)toast('Save unavailable. Continue for this session or reset in Settings.');
  else toast('Find the Reed court keeper');
  updateHUD();
 }
 function interact(node){
  if(!started||state.fight||state.activity||modal)return;
  node=node||game.nearby();
  if(!node){toast('Move near a marked activity to interact');return;}
  pendingNode=node;
  const i=node.district;
  if(node.kind==='mentor'){game.talk(i);show('mentor');}
  else if(node.kind==='seal')game.collect(node);
  else if(node.kind==='room'){game.enterRoom();toast('Your trophy room');}
  else if(node.kind==='room-exit')game.exitRoom();
  else if(node.kind==='pedestal'){pendingNode={slot:node.slot};show('slot');}
  else if(node.kind==='events')show('events');
  else if(node.kind==='graduation')show('graduation');
  else if(node.kind==='route'||node.kind==='puzzle')game.beginActivity(i,node.kind);
  else if(node.kind==='spar')show('ring');
  else if(node.kind==='boss'){pendingNode={district:i};show('bosses');}
  updateHUD();
 }
 function objectiveGo(){
  const n=game.objective().node;
  if(!n)return;
  closePanel();game.exitRoom();game.approach(n);
 }
 function command(raw) {
  const [cmd,a,b]=raw.split(':'),p=state.profile;
  if(cmd==='close'){closePanel();return;}
  if(cmd==='panel'){show(a);return;}
  if(cmd==='practice'){practice={district:Number(a)};show('practice');return;}
  if(cmd==='fight-bot'){
   const district=modal==='fight-result'?fightResult.district:practice.district;
   game.exitRoom();game.startFight('practice',district,0,a);return;
  }
  if(cmd==='queue'){
   queue={mode:a,district:Number(b),started:performance.now(),stage:0,offer:false,found:false,keptWaiting:false};
   show('queue');return;
  }
  if(cmd==='keep-queue'){queue.keptWaiting=true;paintPanel();return;}
  if(cmd==='preview-match'){queue.found=true;paintPanel();return;}
  if(cmd==='finish-queue'){show('queue-complete');return;}
  if(cmd==='cancel-queue'){show('arena');return;}
  if(cmd==='boost'){if(game.activateBoost(a))paintPanel();return;}
  if(cmd==='region'){pendingNode={district:Number(a)};show('region');return;}
  if(cmd==='go'){
   const n=districts[Number(a)].nodes.find(n=>n.id===b);closePanel();game.exitRoom();game.approach(n);
   if(n.kind==='spar')toast('Follow the gold route to the fighting ring');
   return;
  }
  if(cmd==='track'){p.track=Number(a);p.pin=null;game.save();closePanel();objectiveGo();return;}
  if(cmd==='objective'){objectiveGo();return;}
  if(cmd==='travel'){if(game.travel(Number(a))){closePanel();toast('Arrived in '+districts[Number(a)].name);}return;}
  if(cmd==='equip'||cmd==='backup'){if(game.equip(Number(a),cmd==='backup')){paintPanel();updateHUD();}return;}
  if(cmd==='pin'){p.pin=a;game.save();paintPanel();return;}
  if(cmd==='slot'){pendingNode={slot:Number(a)};show('slot');return;}
  if(cmd==='pick'){pendingNode={trophy:a};show('pick');return;}
  if(cmd==='place'){if(game.display(Number(a),b==='none'?null:b))show('room');return;}
  if(cmd==='theme'){p.theme=(p.theme+1)%3;game.save();paintPanel();return;}
  if(cmd==='enter-room'){if(game.enterRoom()){closePanel();toast('Your trophy room');}return;}
  if(cmd==='exit-room'){game.exitRoom();closePanel();return;}
  if(cmd==='setting'){p.settings[a]=!p.settings[a];game.save();paintPanel();updateHUD();return;}
  if(cmd==='reset-confirm'){show('reset-confirm');return;}
  if(cmd==='reset'){game.reset();closePanel();toast('A new adventure begins');return;}
  if(cmd==='activity'){closePanel();game.exitRoom();game.travel(0);game.beginActivity(0,a);return;}
  if(cmd==='fight'){
   if(a==='raid'&&b===undefined){show('bosses');return;}
   const result=fightResult;
   const district=modal==='fight-result'?result.district:a==='graduation'?0:a==='raid'?([2,1,3][Number(b)]??state.region):modal==='ring'?pendingNode.district:state.region;
   game.exitRoom();game.startFight(a,district,Number(b)||0);return;
  }
  if(cmd==='leave'){game.leaveFight();return;}
  if(cmd==='end-activity'){game.finishActivity(false);return;}
  if(cmd==='timing'){game.timing();updateActivity();return;}
  if(cmd==='begin-sequence'){state.activity.started=true;paintPanel();return;}
  if(cmd==='sequence'){game.sequence(Number(a));updateActivity();}
 }
 function movement(){
  const k=input.keys, pressed=(a,b)=>Number(k.has(a)||k.has(b));
  const x=pressed('KeyD','ArrowRight')-pressed('KeyA','ArrowLeft')+input.stick.x+input.pad.x;
  const y=pressed('KeyS','ArrowDown')-pressed('KeyW','ArrowUp')+input.stick.y+input.pad.y;
  const norm=Math.max(1,Math.hypot(x,y));return {x:x/norm,y:y/norm};
 }
 function updateActivity(){
  const a=state.activity, box=$('activity'); box.hidden=!a?.points;
  if(a?.points){
   const value=Math.ceil(Math.max(0,a.limit-a.time));
   box.innerHTML='<strong>'+text(a.title)+'</strong><small>'+a.at+' / '+a.points.length+' lanterns · '+value+'s left</small>'+
    '<small>Follow the highlighted ring · Expert '+a.expert+'s</small>';
  }
  if(a?.pattern==='timing'){
   const marker=$('timing-marker');if(marker)marker.style.left=(a.phase*100)+'%';
  }
  const progress=$('puzzle-progress');
  if(a&&progress){
   const count=a.pattern==='sequence'?a.seq.length:a.targetHits;
   const label=a.hits+' / '+count+' correct';
   if(progress.textContent!==label)progress.textContent=label;
  }
 }
 function updateHUD(){
  shell.dataset.input=state.profile.settings.touch?'touch':input.kind;
  shell.dataset.fight=String(!!state.fight);
  shell.dataset.activity=String(!!state.activity);
  $('touch').hidden=showroom||!started||shell.dataset.input!=='touch'||!!modal;
  if(showroom)return;
  if(!started)return;
  const f=state.fight, p=state.profile, a=state.activity, actual=fighter(), xp=p.fighterXP[actual.id]||0;
  $('fighter-name').textContent=actual.name;
  const progress=levelProgress(xp);
  $('fighter-level').textContent='Lv. '+progress.level+' / '+levelCap+' · '+stageOf(xp);
  $('fighter-xp').style.width=(progress.ratio*100)+'%';
  $('coins').textContent=p.coins.toLocaleString()+' Coins';
  const count=Object.keys(p.trophies).length;
  $('trophy-count').textContent=count+(count===1?' Trophy':' Trophies');
  const status=$('save-state');if(status.textContent!==state.status)status.textContent=state.status;
  state.objective=game.objective();$('location').textContent=state.room?'Personal Dojo':districts[state.region].name;
  const ringRoute=state.target?.kind==='spar';
  $('objective-name').textContent=ringRoute?'Fighting ring':state.objective.title;
  $('objective-detail').textContent=ringRoute?'Heading to '+state.target.label:state.objective.detail;
  const n=game.nearby(), label=n?.kind==='spar'?'Enter fighting ring':n?.label;
  const interactButton=$('interact');
  interactButton.hidden=!!modal||!n;interactButton.className='primary';
  if(n)interactButton.textContent=(input.kind==='keys'?'E · ':input.kind==='pad'?'A / Cross · ':'')+label;
  const keys=$('desktop-keys');keys.hidden=!!modal;
  keys.textContent=input.kind==='pad'?(f?'X / Square Strike · Y / Triangle Skill · RT / R2 Signature · B / Circle Guard · LB / L1 Dash':'Stick Move · A / Cross Interact · Menu Journal'):
   f?'WASD Move · J Strike · K Skill · I Signature · L Parry · Space Dash'+(f.mode==='tag'?' · R Tag':''):'WASD or arrows to move · E Interact · Space Dash · G Follow objective';
  const combat=$('combat');combat.hidden=!f;
  if(f){
   const h=f.hero, focus=[...f.enemies].filter(e=>e.hp>0).sort((a,b)=>distance(h,a)-distance(h,b))[0]||f.enemies[0];
   const m=arenaModes.find(m=>m.id===f.mode)?.name||(f.mode==='practice'?'Bot practice':f.mode==='spar'?'Guided spar':'Graduation trial');
   const announcement=f.transition>0?'Next round…':focus.phase==='wind'?'Incoming! Dash or parry.':'Skill '+(h.skill>0?h.skill.toFixed(1)+'s':'ready')+' · Guard '+(h.guardCooldown>0?h.guardCooldown.toFixed(1)+'s':'ready');
   const cap=(name,actor)=>'<div><b>'+text(name)+'</b><meter min="0" max="'+actor.max+'" value="'+Math.floor(actor.hp)+'" aria-label="'+text(name)+' health"></meter><span>'+Math.ceil(actor.hp)+' HP</span></div>';
   combat.innerHTML='<strong>'+m+' · '+Math.ceil(f.timer)+'s'+(f.mode==='duel'?' · '+f.wins+'–'+f.losses:'')+'</strong><div class="bars">'+cap(h.name,h)+cap(focus.name+(f.mode==='practice'?' · '+botTiers[f.botTier].name+' bot':''),focus)+'</div><small>'+announcement+'</small><small class="signature" data-ready="'+(h.charge>=100)+'">'+text(fighters[h.id].ultimate)+' · '+(h.charge>=100?'Ready':h.charge+'%')+'</small>'+
    (f.mode==='tag'&&!f.tagUsed?'<button class="tag-button" data-command="tag">Tag backup</button>':'');
  }
  const touch=$('touch');
  touch.classList.toggle('exploring',!f);
  touch.querySelector('[data-touch="ultimate"]').classList.toggle('charged',!!f&&f.hero.charge>=100);
  if(a?.points)interactButton.hidden=true;
  updateActivity();
 }
 function playAction(id){
  if(!started||modal)return;
  if(id==='dash')game.dash(movement());
  else if(id==='tag')game.tag();
  else game.attack(id);
 }
 const keyPanels={KeyM:'map',KeyQ:'journal',KeyF:'fighters',KeyT:'trophies',KeyB:'arena'};
 const keyActions={KeyJ:'attack',KeyK:'skill',KeyI:'ultimate',KeyL:'guard',Space:'dash',KeyR:'tag'};
 document.addEventListener('keydown',event=>{
  const k=event.code;
  if(showroom)return;
  setInput('keys');
  if(modal){
   if(k==='Escape'){event.preventDefault();closePanel();}
   else if(k==='Tab'){
    const focus=[...panel.querySelectorAll('button:not(:disabled),select,a[href]')], index=focus.indexOf(document.activeElement);
    if(index<0||(event.shiftKey?index===0:index===focus.length-1)){
     event.preventDefault();focus[event.shiftKey?focus.length-1:0]?.focus();
    }
   }
   return;
  }
  if(!started)return;
  if(['KeyW','KeyA','KeyS','KeyD','ArrowUp','ArrowDown','ArrowLeft','ArrowRight','Space'].includes(k)){
   if(k==='Space'&&event.target.closest('button'))return;
   event.preventDefault();input.keys.add(k);
  }
  if(event.repeat)return;
  if(k==='Escape'){show(state.fight?'pause':state.activity?'activity-pause':'settings');return;}
  if(k==='KeyE'){interact();return;}
  if(k==='KeyG'&&!state.fight&&!state.activity){objectiveGo();return;}
  if(!state.fight&&!state.activity&&keyPanels[k]){show(keyPanels[k]);return;}
  if(keyActions[k])playAction(keyActions[k]);
 });
 document.addEventListener('keyup',e=>input.keys.delete(e.code));
 window.addEventListener('blur',()=>{input.keys.clear();input.stick={x:0,y:0};});
 $('start').addEventListener('click',start);
 $('controls').addEventListener('click',()=>show('controls'));
 $('interact').addEventListener('click',()=>interact());
 shell.addEventListener('click',e=>{
  const b=e.target.closest('button');if(!b||b.disabled)return;
  if(b.dataset.panel)show(b.dataset.panel);
  if(b.dataset.command==='tag')game.tag();
  else if(b.dataset.command)command(b.dataset.command);
 });
 panel.addEventListener('change',e=>{
  if(e.target.id==='trophy-filter'){filter=e.target.value;paintPanel();$('trophy-filter')?.focus();}
  if(e.target.id==='fighter-filter'){fighterFilter=e.target.value;paintPanel();$('fighter-filter')?.focus();}
 });
 canvas.addEventListener('pointerdown',e=>{
  if(showroom||!started||modal)return;
  setInput(e.pointerType==='touch'?'touch':'keys');
  if(state.fight){if(e.pointerType!=='touch')playAction('attack');return;}
  const target=scene.point(e);
  if(state.activity?.points){if(walkable(target))state.target={...target,queue:[target]};return;}
  const list=state.room?state.room.nodes:districts.flatMap(d=>d.nodes).filter(n=>n.kind!=='seal'||distance(n,state.player)<145);
  const n=list.find(n=>distance({x:n.x,y:n.y-19},target)<39);
  const ring=districts[state.region].nodes.find(node=>node.kind==='spar');
  if(!state.room&&Math.abs(target.x-ring.x)<89&&Math.abs(target.y-(ring.y-56))<42){game.approach(ring);return;}
  if(n){game.approach(n);return;}
  if(state.room?(Math.abs(target.x)<280&&target.y>-185&&target.y<245):walkable(target))state.target={...target,queue:[target]};
 });
 const stick=$('stick'),knob=stick.querySelector('i');
 let stickPointer=null;
 function steer(e){
  if(e.pointerId!==stickPointer)return;
  const rect=stick.getBoundingClientRect(),radius=rect.width*.35;
  let x=(e.clientX-rect.left-rect.width/2)/radius,y=(e.clientY-rect.top-rect.height/2)/radius;
  const norm=Math.max(1,Math.hypot(x,y));x/=norm;y/=norm;
  input.stick={x,y};knob.style.transform='translate('+x*radius+'px,'+y*radius+'px)';
 }
 stick.addEventListener('pointerdown',e=>{stickPointer=e.pointerId;stick.setPointerCapture(e.pointerId);setInput('touch');steer(e);});
 stick.addEventListener('pointermove',steer);
 for(const evt of ['pointerup','pointercancel','lostpointercapture'])stick.addEventListener(evt,e=>{
  if(e.pointerId!==stickPointer)return;stickPointer=null;input.stick={x:0,y:0};knob.style.transform='';
 });
 $('touch').addEventListener('pointerdown',e=>{
  const target=e.target.closest('[data-touch]');if(target){e.preventDefault();setInput('touch');playAction(target.dataset.touch);}
 });
 function gamepad(){
  const pad=[...(navigator.getGamepads?.()||[])].find(Boolean);
  if(!pad){input.pad={x:0,y:0};input.padButtons=[];return;}
  const edges=pad.buttons.map((b,i)=>b.pressed&&!input.padButtons[i]);
  input.padButtons=pad.buttons.map(b=>b.pressed);
  const axis=n=>Math.abs(pad.axes[n]||0)>.19?pad.axes[n]:0;
  input.pad={x:axis(0),y:axis(1)};
  if(input.pad.x||input.pad.y||edges.some(Boolean))setInput('pad');
  if(modal){
   const targets=[...panel.querySelectorAll('button:not(:disabled),select,a[href]')];
   const selected=document.activeElement;
   if(selected.matches('select')&&(edges[14]||edges[15])){
    selected.selectedIndex=(selected.selectedIndex+(edges[14]?-1:1)+selected.options.length)%selected.options.length;
    selected.dispatchEvent(new Event('change',{bubbles:true}));
   }else if(edges[12]||edges[13]||edges[14]||edges[15]){
    const index=targets.indexOf(document.activeElement), delta=(edges[12]||edges[14])?-1:1;
    targets[(Math.max(0,index)+delta+targets.length)%targets.length]?.focus();
   }
   if(edges[0]&&document.activeElement.matches('button,a[href]'))document.activeElement.click();
   if(edges[1])closePanel();
   return;
  }
  if(!started){if(edges[0])start();return;}
  if(edges[9]){show(state.fight?'pause':state.activity?'activity-pause':'journal');return;}
  if(edges[0]&&!state.fight)interact();
  if(edges[2])playAction('attack');
  if(edges[3])playAction('skill');
  if(edges[1])playAction('guard');
  if(edges[4])playAction('dash');
  if(edges[5])playAction('tag');
  if(edges[7])playAction('ultimate');
  if(edges[12]&&!state.fight&&!state.activity)show('map');
  if(edges[13]&&!state.fight&&!state.activity)show('trophies');
 }
 function frame(now){
  const dt=Math.min(.045,(now-frameTime)/1000||0);frameTime=now;
  if(!showroom)gamepad();
  const motion=movement();
  if(started&&!showroom&&(!modal||modal==='challenge'))game.tick(dt,modal?{x:0,y:0}:motion);
  if(now-lastUI>86){updateHUD();updateTimedPanels();lastUI=now;}
  if(now>toastUntil)$('toast').hidden=true;
  updateActivity();
  scene.draw(state,{title:!started,reduce:!state.profile.settings.motion,moving:!!(motion.x||motion.y||state.target)});
  requestAnimationFrame(frame);
 }
 new ResizeObserver(()=>scene.resize()).observe(canvas);scene.resize();
 shell.dataset.input=input.kind;
 if(showroom){
  started=true;$('title-screen').hidden=true;$('showroom').hidden=false;
  state.profile.shelf=['journey-01','discovery-valley','mastery-coast','arena-01','world-01','journey-06'];
  const awards=$('showroom-awards');awards.hidden=false;
  awards.innerHTML=state.profile.shelf.map(id=>'<li>'+text(trophies.find(t=>t.id===id).name)+'</li>').join('');
  game.enterRoom();canvas.setAttribute('aria-label','Furnished trophy room with six sample awards on display');
 }
 state.objective=game.objective();
 requestAnimationFrame(frame);
})();
