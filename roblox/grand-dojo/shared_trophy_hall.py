"""Build the public walk-up exhibits inside the existing Trophy Hall shell."""

import json
from math import cos, radians, sin
from pathlib import Path


def build_shared_trophy_hall(hall, *, item, part, prop, asset, sign, lamp, threshold_light,
                            wood, slate, fabric, metal, smooth):
    gallery = item(hall, "Folder", "Walk-up Exhibits")
    murals = json.loads((Path(__file__).parent / "art/trophy-murals/assets.json").read_text())
    exhibits = (
        ("world-04", "Lantern Keeper", "relay", -7.4, -46.1, 24, "9D4229", "FFBE74"),
        ("mastery-sky", "Skywalk Peaks Master", "cloudbreak", 7.6, -50.0, -21, "285D66", "8DDCD7"),
        ("arena-01", "First Duel", "sparring", 8.5, -40.2, -33, "913B35", "FFB887"),
    )
    for key, title, image, x, z, yaw, enamel, glow in exhibits:
        bay = item(gallery, "Model", key)
        angle = radians(yaw)
        c, s = cos(angle), sin(angle)

        def position(u, y, v):
            return x + u*c + v*s, y, z - u*s + v*c

        def piece(name, size, u, y, v, tint, material=wood, *, solid=False):
            detail = part(bay, name, position(u,y,v), size, tint,
                          yaw=yaw, material=material, collide=solid)
            prop(detail, "bool", "CastShadow", solid)
            return detail

        piece("Woven exhibit mat", (6.1,.035,4.50), 0,3.625,.50,enamel,fabric)
        for side in (-1,1):
            piece("Woven brass border",(.07,.02,4.43),side*2.91,3.65,.50,"C98E50",fabric)
        piece("Sculpture cabinet",(5.55,1.23,2.75),0,4.28,0,"50302C",solid=True)
        piece("Raised slate toe kick",(5.40,.16,2.76),0,3.75,0,"332730",slate)
        piece("Brass step molding",(5.65,.09,2.83),0,4.78,0,"D89F57",metal)
        piece("Lacquer display top",(5.74,.18,2.90),0,4.94,0,enamel)
        piece("Title plaque surround",(5.32,.76,.16),0,4.30,1.42,"BD864B",metal)
        px,py,pz = position(0,4.31,1.54)
        sign(bay,title.upper(),px,py,pz,5.05,.54,yaw=yaw,tint="53322D",face_only=True,wayfinding=True)
        for side in (-1,1):
            piece("Painted mural jamb",(.31,5.7,.33),side*2.94,6.64,-1.56,enamel)
            piece("Brass jamb foot",(.46,.24,.46),side*2.94,3.74,-1.56,"C4894D",metal)
            piece("Brass jamb collar",(.46,.22,.46),side*2.94,9.30,-1.56,"D2A36C",metal)
        piece("Brass mural frame",(5.71,4.45,.20),0,7.14,-1.56,"B68758",metal)
        mural = piece("Activity mural",(5.47,4.20,.06),0,7.14,-1.42,"DFC5A0",smooth)
        picture = item(mural,"Decal",title+" mural")
        asset(picture,"TextureContent",f"rbxassetid://{murals[image]}")
        prop(picture,"token","Face",2)
        piece("Stepped canopy",(6.28,.27,.91),0,9.64,-1.33,enamel)
        piece("Canopy brass drip edge",(6.36,.08,.97),0,9.51,-1.30,"D29756",metal)
        for side in (-1,1):
            lx,ly,lz = position(side*2.55,6.08,.06)
            lamp(bay,lx,ly,lz,scale=.34)
        lx,ly,lz = position(0,9.35,.25)
        threshold_light(bay,lx,ly,lz,reach=10,spread=80,brightness=.7,tint=glow,pitch=-72)

        mount = piece("SculptureMount",(.1,.1,.1),0,5.03,0,"FFFFFF")
        prop(mount,"float","Transparency",1)
        anchor = piece("ExhibitPrompt",(.1,.1,.1),0,5.13,1.64,"FFFFFF")
        prop(anchor,"float","Transparency",1)
        prompt = item(anchor,"ProximityPrompt","Inspect")
        prop(prompt,"string","ObjectText",title)
        prop(prompt,"string","ActionText","Inspect trophy")
        prop(prompt,"float","MaxActivationDistance",5)
        prop(prompt,"bool","RequiresLineOfSight",False)

    portal = item(hall,"Model","Personal Room Portal")
    for x in (-3.35,3.35):
        part(portal,"Lacquered portal jamb",(x,6.15,-53.17),(.55,5.10,.55),"883F2E",material=wood,collide=False)
        part(portal,"Brass portal boot",(x,3.91,-53.13),(.72,.59,.66),"B3834C",material=metal,collide=False)
        lamp(portal,x,7.7,-52.50,scale=.45)
    part(portal,"Recessed amber screen",(0,6.23,-53.89),(6.2,5.15,.18),"E1A66D",material=wood,collide=False)
    for x in (-2.1,-1.05,0,1.05,2.1):
        part(portal,"Screen cedar lattice",(x,6.23,-53.75),(.08,5.14,.12),"623C34",material=wood,collide=False)
    part(portal,"Portal cedar header",(0,8.86,-53.18),(7.37,.47,.69),"6B322B",material=wood,collide=False)
    sign(portal,"PERSONAL TROPHY ROOM",0,8.83,-52.75,6.70,.60,tint="743B34",wayfinding=True)
