"""Original lacquered portico at the entrance to the Lantern Relay."""

from math import atan2, degrees, hypot


# Keep the walkable geometry and collision envelope from the original gate.
_PILLAR_COLLIDERS = (
    (.43, 2.70, .83, "927E80"),
    (.95, 2.34, .31, "AB9690"),
    (5.63, 1.57, 9.12, "C14B32"),
    (2.05, 1.72, .36, "D69742"),
    (9.37, 1.77, .46, "E9A744"),
    (10.52, 2.71, 1.02, "813A29"),
)


def build_relay_arrival_portico(
    parent, *, center, item, part, prop, beam, banner, curved_plaque, marquee_title,
    reed_mark, roof_panel, roof_barrel, arrival_hanging_lantern, festival_lantern,
    threshold_light, wood, slate, limestone, metal, fabric, variant_field,
    wood_variant, metal_variant, stone_variant, fabric_variant,
):
    portico = item(parent, "Model", "Lacquered Relay portico")
    z = 31.0
    face_z = 32.36
    profile = [
        (x, 17.02 + 3.03 * (1 - (x / 12.35)**2))
        for x in (-12.35,-10.1,-7.6,-5.05,-2.55,0,2.55,5.05,7.6,10.1,12.35)
    ]
    variants = {wood: wood_variant, metal: metal_variant, slate: stone_variant}

    def detail(scope, name, position, size, tint, material, *, roll=0, shadow=False):
        piece = part(scope, name, position, size, tint, material=material, roll=roll, collide=False)
        prop(piece, "bool", "CastShadow", shadow)
        if material in variants:
            prop(piece, "string", variant_field, variants[material])

    for side in (-1, 1):
        x = center + side * 9.45
        for y, width, height, tint in _PILLAR_COLLIDERS:
            collider = part(parent, "Entrance pillar", (x,y,z), (width,height,width),
                            tint, transparency=1)
            prop(collider, "bool", "CastShadow", False)

        pier = item(portico, "Model", "Relay cedar pier")
        for name, y, width, height, depth, tint, material in (
            ("Slate plinth footing", .37, 3.42, .69, 3.30, "81737C", slate),
            ("Slate plinth course", .92, 3.18, .41, 3.05, "97838A", slate),
            ("Sandstone plinth cap", 1.20, 3.26, .19, 3.14, "CFAC8A", limestone),
            ("Vermilion timber column", 8.76, 2.43, 14.91, 2.53, "BA4431", wood),
            ("Column brass shoe", 1.39, 2.53, .28, 2.63, "D18B4C", metal),
            ("Burnished lower collar", 2.03, 2.56, .24, 2.67, "D89C57", metal),
            ("Burnished upper collar", 14.96, 2.64, .31, 2.76, "E9B264", metal),
            ("Cedar saddle", 15.54, 2.94, .55, 3.10, "943D31", wood),
            ("Cedar corbel step", 16.03, 3.25, .42, 3.28, "9C4934", wood),
            ("Cedar corbel cap", 16.42, 3.70, .36, 3.41, "783A32", wood),
        ):
            detail(pier, name, (x,y,z), (width,height,depth), tint, material,
                   shadow=name=="Vermilion timber column")
        detail(pier, "Inset lacquered cedar face", (x,8.76,z+1.29), (1.86,12.51,.11),
               "DA5434", wood)
        for edge in (-1,1):
            detail(pier, "Warm column edge", (x+edge*.96,8.78,z+1.34), (.09,12.51,.05),
                   "EC7243", wood)
        beam(pier, "Carved relay knee brace", (x,13.87,z+.39),
             (x-side*2.58,16.71,z+.77), .47, "A65333")
        beam(pier, "Knee brace brass inlay", (x-side*.37,14.20,z+.65),
             (x-side*2.20,16.28,z+1.03), .10, "D39250")

        standard = banner(portico,x+side*1.39,8.45,32.79,scale=1.64,vermilion=True)
        for piece in standard.findall("Item"):
            if piece.findtext("Properties/token[@name='Material']")==str(fabric):
                prop(piece,"string",variant_field,fabric_variant)

        lamp_x = x - side * 1.43
        lamp_y = 12.51
        lamp_z = 32.82
        beam(pier, "Relay lantern bracket", (x,15.24,z+.68), (lamp_x,14.73,lamp_z),
             .20,"A76341")
        beam(pier, "Relay lantern hanging cord", (lamp_x,14.74,lamp_z),
             (lamp_x,14.03,lamp_z),.09,"864831")
        arrival_hanging_lantern(portico,lamp_x,lamp_y,lamp_z,1.68,
                                light_profile=(.80,16.0),entrance_paper=True,tint="F3B264")

    curved_plaque(portico,center,face_z,profile,4.20,"9D2F28","E7A249",
                  rim_height=.24,rim_depth=.36)
    for (left, low), (right, high) in zip(profile,profile[1:]):
        x = center + (left+right)/2
        y = (low+high)/2
        width = hypot(right-left,high-low)
        roll = degrees(atan2(high-low,right-left))
        roof_panel(portico,"Indigo arch coping",(x,y+2.26,31.89),
                   (width+.08,.42,2.37),"384776",roll=roll)
        roof_barrel(portico,"Ceramic arch rib",(x,y+2.51,31.88),2.49,.26,"546692")
        detail(portico,"Swept rear cedar fascia",(x,y+.63,29.64),
               (width+.055,1.29,.28),"8B4438",wood,roll=roll)
        detail(portico,"Recessed cedar soffit",(x,y-1.31,30.63),
               (width+.055,.29,2.94),"7F4332",wood,roll=roll)

    for side in (-1,1):
        edge_x = center + side * 11.90
        detail(portico,"Brass marquee end plate",(edge_x,17.18,32.68),
               (1.08,4.18,.22),"D08743",metal,roll=-side*24)
        detail(portico,"Brass overhanging roof shoe",(edge_x,19.81,32.08),
               (1.39,.47,2.68),"C98740",metal,roll=-side*25)
        reed_mark(portico,center+side*11.23,17.47,32.81,.89)
    marquee_title(portico,"LANTERN RELAY",center,face_z,profile,2.53)

    # One recessed lantern beam separates the near frame from the legible
    # checkpoint arches down the lane and keeps the opening uncluttered.
    lanterns = item(portico, "Model", "Receding Relay lantern beam")
    lx, lz = center-.72, 29.18
    detail(lanterns,"Rear lantern tie beam",(lx,15.53,lz),(15.1,.35,.55),"924A35",wood)
    for offset, scale in ((-4.64,.70),(0,.84),(4.64,.70)):
        lamp_y = 13.64 if offset==0 else 13.43
        beam(lanterns,"Lantern cord",(lx+offset,15.38,lz),
             (lx+offset,lamp_y+scale*.91,lz),.065,"AD7852")
        festival_lantern(lanterns,lx+offset,lamp_y,lz,scale,light=False,tint="FFC173")
    threshold_light(portico,center,14.57,32.63,reach=20.0,spread=71,
                    brightness=1.40,tint="FFBC77",yaw=26,pitch=43)

    for piece in portico.iter("Item"):
        if piece.get("class") in ("Part","WedgePart"):
            if piece.find("Properties/bool[@name='CastShadow']") is None:
                prop(piece,"bool","CastShadow",False)
