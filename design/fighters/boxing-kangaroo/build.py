"""One geometry source for the Roblox prototype, preview, and Studio builder."""
import json, math, xml.etree.ElementTree as ET
from pathlib import Path

HERE = Path(__file__).resolve().parent
groups = [
    dict(name='Torso', parent=None, pivot=[0, 2.6, 0]),
    dict(name='Head', parent='Torso', pivot=[0, 1.15, 0]),
    dict(name='Right Arm', parent='Torso', pivot=[1.0, .7, 0]),
    dict(name='Left Arm', parent='Torso', pivot=[-1.0, .7, 0]),
    dict(name='Right Leg', parent='Torso', pivot=[.57, -.9, 0]),
    dict(name='Left Leg', parent='Torso', pivot=[-.57, -.9, 0]),
    dict(name='Tail', parent='Torso', pivot=[0, -.65, .45]),
]
parts = []
colors = dict(fur='#BA793E', light='#D89A55', dark='#754A2D', cream='#F2D9A5',
              creamShade='#D9B983', inner='#BD775F', glove='#36BFA8', cuff='#187D79',
              black='#192D32', white='#FFF5DF', belt='#237E78')

def part(name, group, size, pos, color='fur', shape='Ball', rotation=None, core=False):
    parts.append(dict(name=name, group=group, size=size, position=pos,
                      color=colors[color], shape=shape, rotation=rotation or [0,0,0], core=core))

part('Torso','Torso',[1.75,2.1,1.24],[0,0,0],core=True)
part('Chest','Torso',[1.5,.9,1.23],[0,.5,-.05],'light')
part('Belly','Torso',[1.28,1.55,.32],[0,-.15,-.61],'cream')
part('Abdomen patch','Torso',[.86,.52,.08],[0,-.48,-.67],'creamShade')
part('Belt','Torso',[1.62,.25,1.18],[0,-.83,0],'belt','Block')
part('Belt knot','Torso',[.32,.32,.24],[0,-.83,-.67],'glove')
part('Belt end A','Torso',[.17,.62,.12],[-.11,-1.08,-.68],'belt','Block',[0,0,-.18])
part('Belt end B','Torso',[.17,.47,.12],[.13,-1.01,-.69],'glove','Block',[0,0,.23])
part('Head','Head',[1.38,1.35,1.13],[0,.35,0],'light',core=True)
part('Muzzle','Head',[1.03,.66,.86],[0,.06,-.65],'cream')
part('Nose','Head',[.40,.24,.24],[0,.18,-1.04],'black')
part('Mouth','Head',[.42,.045,.07],[0,-.14,-1.04],'dark','Block')
for sign,side in [(1,'Right'),(-1,'Left')]:
    part(side+' ear','Head',[.43,1.62 if sign==1 else 1.20,.34],[sign*.47,1.45 if sign==1 else 1.20,.04],'fur',rotation=[0,0,-sign*(.19 if sign==1 else .44)])
    part(side+' inner ear','Head',[.23,1.23 if sign==1 else .86,.105],[sign*.49,1.46 if sign==1 else 1.20,-.13],'inner',rotation=[0,0,-sign*(.19 if sign==1 else .44)])
    part(side+' eye white','Head',[.27,.35,.13],[sign*.36,.46,-.52],'white')
    part(side+' eye','Head',[.16,.24,.105],[sign*.35,.45,-.60],'black')
    part(side+' eye shine','Head',[.05,.065,.025],[sign*.33,.51,-.653],'white')
    part(side+' brow','Head',[.38,.105,.13],[sign*.36,.70,-.51],'dark','Block',[0,0,sign*.19])
    arm=side+' Arm'
    part(arm,arm,[.68,1.17,.71],[sign*.16,-.46,.01],rotation=[0,0,sign*.21],core=True)
    part(side+' forearm',arm,[.59,.63,1.02],[sign*.20,-.49,-.36],'light',rotation=[-.48,0,0])
    part(side+' cuff',arm,[.68,.45,.65],[sign*.20,-.22,-.67],'cuff')
    part(side+' wrapped fist',arm,[.78,.66,.83],[sign*.20,.09,-.88],'glove','Block')
    part(side+' thumb',arm,[.30,.43,.48],[-sign*.14,-.02,-.82],'light')
    part(side+' wrap stripe',arm,[.70,.10,.67],[sign*.20,-.25,-.68],'cream','Block')
    leg=side+' Leg'
    part(leg,leg,[.91,1.43,1.02],[0,-.45,.10],rotation=[-.12,0,0],core=True)
    part(side+' ankle',leg,[.55,.69,.58],[0,-1.03,-.11],'light')
    part(side+' foot',leg,[.77,.49,1.72],[0,-1.43,-.45],'fur')
    part(side+' toe',leg,[.65,.24,.57],[0,-1.49,-1.04],'light')
part('Reed shoulder guard','Right Arm',[.84,.33,.80],[.10,-.04,.08],'cuff','Block',[0,0,.12])
for i in range(3):
    part('Reed brace '+str(i+1),'Right Arm',[.14,.56,.16],[.49,-.38,-.23-i*.19],'creamShade','Block',[-.48,0,0])
part('Tail','Tail',[.72,1.52,.79],[0,-.48,.48],rotation=[-.66,0,0],core=True)
part('Tail middle','Tail',[.49,.62,1.44],[0,-1.02,1.35],rotation=[.22,0,0])
part('Tail tip','Tail',[.28,.34,.99],[0,-1.22,2.24],'light',rotation=[.12,0,0])

spec=dict(name='Reedguard Kangaroo',stage='Original identity inspection prototype v2',forward='-Z',
          notes='Shared primitive geometry; browser lighting is illustrative. Not yet tested in Roblox Studio.',
          groups=groups,parts=parts)
(HERE/'geometry.json').write_text(json.dumps(spec,indent=2)+'\n')

def matmul(a,b): return [[sum(a[i][k]*b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
def rot(angles):
    x,y,z=angles;cx,sx=math.cos(x),math.sin(x);cy,sy=math.cos(y),math.sin(y);cz,sz=math.cos(z),math.sin(z)
    return matmul(matmul([[1,0,0],[0,cx,-sx],[0,sx,cx]],[[cy,0,sy],[0,1,0],[-sy,0,cy]]),[[cz,-sz,0],[sz,cz,0],[0,0,1]])
def cf(parent,name,position,rotation=(0,0,0)):
    c=ET.SubElement(parent,'CoordinateFrame',name=name)
    for key,value in zip(['X','Y','Z'],position):ET.SubElement(c,key).text=str(round(value,8))
    for i,row in enumerate(rot(rotation)):
        for j,value in enumerate(row):ET.SubElement(c,f'R{i}{j}').text=str(round(value,8))
def prop(parent,tag,name,text):ET.SubElement(parent,tag,name=name).text=str(text)
def vec(parent,name,v):
    c=ET.SubElement(parent,'Vector3',name=name)
    for k,n in zip('XYZ',v):ET.SubElement(c,k).text=str(n)
def item(parent,cls,ref,name):
    i=ET.SubElement(parent,'Item',attrib={'class':cls,'referent':ref});p=ET.SubElement(i,'Properties');prop(p,'string','Name',name);return i,p

root=ET.Element('roblox',version='4');ET.SubElement(root,'External').text='null';ET.SubElement(root,'External').text='nil'
model,mp=item(root,'Model','KANGAROO_MODEL','ReedguardKangaroo_Prototype');prop(mp,'Ref','PrimaryPart','KANGAROO_ROOT')
ri,rp=item(model,'Part','KANGAROO_ROOT','HumanoidRootPart');vec(rp,'size',[2,2,1]);cf(rp,'CFrame',[0,2.6,0]);prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'float','Transparency',1)
world={};refs={};cores={}
for g in groups:
    world[g['name']]=[a+b for a,b in zip(world[g['parent']] if g['parent'] else [0,0,0],g['pivot'])]
for n,p in enumerate(parts):
    ref='KANGAROO_PART_'+str(n);refs[p['name']]=ref
    it,pr=item(model,'Part',ref,p['name']);vec(pr,'size',p['size']);pos=[a+b for a,b in zip(world[p['group']],p['position'])];cf(pr,'CFrame',pos,p['rotation'])
    prop(pr,'Color3uint8','Color3uint8',0xff000000 | int(p['color'][1:],16))
    prop(pr,'token','shape',0 if p['shape']=='Ball' else 1);prop(pr,'token','Material',272);prop(pr,'bool','CanCollide','false');prop(pr,'bool','Massless','true');prop(pr,'bool','CastShadow','true');prop(pr,'float','Reflectance',0)
    if p['core']:cores[p['group']]=(p,ref,it)
for g in groups:
    p,ref,it=cores[g['name']];j,jp=item(model,'Motor6D','KANGAROO_JOINT_'+g['name'].replace(' ',''),'RootJoint' if not g['parent'] else {'Head':'Neck','Right Arm':'Right Shoulder','Left Arm':'Left Shoulder','Right Leg':'Right Hip','Left Leg':'Left Hip','Tail':'TailJoint'}[g['name']])
    parentp=cores[g['parent']][0] if g['parent'] else None
    parentpos=[a+b for a,b in zip(world[g['parent']],parentp['position'])] if parentp else [0,2.6,0]
    # C0/C1 are written from complete transforms by the Luau builder below.
    # Use matrix inversion for rotated limb cores so the authored guard stays unchanged.
    def local_cf(pos,angles,pivot):
        r=rot(angles);rt=list(map(list,zip(*r)));delta=[a-b for a,b in zip(pivot,pos)];tr=[sum(rt[i][k]*delta[k] for k in range(3)) for i in range(3)];return tr,rt
    def matrix_cf(name,position,matrix):
        c=ET.SubElement(jp,'CoordinateFrame',name=name)
        for k,v in zip('XYZ',position):ET.SubElement(c,k).text=str(v)
        for i in range(3):
            for k in range(3):ET.SubElement(c,f'R{i}{k}').text=str(matrix[i][k])
    c0,r0=local_cf(parentpos,parentp['rotation'] if parentp else [0,0,0],world[g['name']]);childpos=[a+b for a,b in zip(world[g['name']],p['position'])];c1,r1=local_cf(childpos,p['rotation'],world[g['name']]);matrix_cf('C0',c0,r0);matrix_cf('C1',c1,r1)
    prop(jp,'Ref','Part0',cores[g['parent']][1] if g['parent'] else 'KANGAROO_ROOT');prop(jp,'Ref','Part1',ref)
for n,p in enumerate(parts):
    if p['core']:continue
    w,wp=item(model,'WeldConstraint','KANGAROO_WELD_'+str(n),'DetailWeld');prop(wp,'Ref','Part0',cores[p['group']][1]);prop(wp,'Ref','Part1',refs[p['name']])
hi,hp=item(model,'Humanoid','KANGAROO_HUMANOID','Humanoid');prop(hp,'float','Health',100);prop(hp,'float','MaxHealth',100);prop(hp,'float','WalkSpeed',16);prop(hp,'token','RigType',0);prop(hp,'bool','RequiresNeck','true');prop(hp,'string','DisplayName','Reedguard Kangaroo')
ai,ap=item(hi,'Animator','KANGAROO_ANIMATOR','Animator')
ET.indent(root);ET.ElementTree(root).write(HERE/'ReedguardKangaroo_Prototype.rbxmx',encoding='utf-8',xml_declaration=True)

def lua(v):
    if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(val) for k,val in v.items())+'}'
    if isinstance(v,list):return '{'+','.join(lua(n) for n in v)+'}'
    if isinstance(v,bool):return 'true' if v else 'false'
    if v is None:return 'nil'
    return json.dumps(v)
builder='''-- Prototype only. Paste into Studio Command Bar in Edit mode to create a display rig.
-- Uses Roblox Parts, WeldConstraints and Motor6Ds; no uploaded meshes or textures.
-- Root is anchored for safe inspection. Playable movement, animation and combat need Studio validation.
local spec = __SPEC__
local model = Instance.new("Model")
model.Name = "ReedguardKangaroo_Prototype"
local function vector(v) return Vector3.new(v[1],v[2],v[3]) end
local root = Instance.new("Part")
root.Name="HumanoidRootPart"; root.Size=Vector3.new(2,2,1)
root.CFrame=CFrame.new(0,2.6,0); root.Transparency=1
root.CanCollide=false; root.Anchored=true; root.Parent=model
local origins, cores, built = {}, {}, {}
for _,g in ipairs(spec.groups) do
    origins[g.name] = (g.parent and origins[g.parent] or CFrame.identity) * CFrame.new(vector(g.pivot))
end
for _,d in ipairs(spec.parts) do
    local p=Instance.new("Part")
    p.Name=d.name; p.Shape=Enum.PartType[d.shape]; p.Size=vector(d.size)
    p.CFrame=origins[d.group]*CFrame.new(vector(d.position))*CFrame.Angles(d.rotation[1],d.rotation[2],d.rotation[3])
    p.Color=Color3.fromHex(d.color);p.Material=Enum.Material.SmoothPlastic
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.CanCollide=false;p.Massless=true;p.Parent=model
    built[d.name]=p
    if d.core then cores[d.group]=p end
end
local names={Head="Neck",["Right Arm"]="Right Shoulder",["Left Arm"]="Left Shoulder",["Right Leg"]="Right Hip",["Left Leg"]="Left Hip",Tail="TailJoint"}
for _,g in ipairs(spec.groups) do
    local a=g.parent and cores[g.parent] or root
    local b=cores[g.name]
    local joint=Instance.new("Motor6D")
    joint.Name=names[g.name] or "RootJoint";joint.Part0=a;joint.Part1=b
    joint.C0=a.CFrame:ToObjectSpace(origins[g.name]);joint.C1=b.CFrame:ToObjectSpace(origins[g.name]);joint.Parent=a
end
for _,d in ipairs(spec.parts) do
    if not d.core then
        local w=Instance.new("WeldConstraint");w.Name="DetailWeld"
        w.Part0=cores[d.group];w.Part1=built[d.name];w.Parent=built[d.name]
    end
end
local humanoid=Instance.new("Humanoid");humanoid.DisplayName="Reedguard Kangaroo";humanoid.Parent=model
local animator=Instance.new("Animator");animator.Parent=humanoid
model.PrimaryPart=root;model:SetAttribute("AssetStage","Primitive prototype — not playtested")
model.Parent=workspace
game:GetService("Selection"):Set({model})
print("Created kangaroo inspection rig. Keep the root anchored until movement and collisions are implemented.")
'''.replace('__SPEC__',lua(spec))
(HERE/'CreateKangaroo.luau').write_text(builder)
print(json.dumps({'parts':len(parts),'joints':len(groups),'welds':len(parts)-len(groups),'folder':str(HERE)}))
