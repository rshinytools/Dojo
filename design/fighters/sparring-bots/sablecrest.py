"""Sablecrest Lynx, an original agile Dojo sparring opponent."""

from math import radians


def build(p):
    fur = p.material("Lilac slate fur", "7E758E", .82, 105)
    fur_light = p.material("Winter cheek fur", "DDD1CA", .86, 105)
    fur_dark = p.material("Dark ear tips and broken stripes", "3A3148", .82)
    nose = p.material("Mulberry leather nose", "533648", .61)
    ink = p.material("Deep plum eye rim", "1E182D", .68)
    white = p.material("Pale lavender eye", "F1E5D9", .47)
    iris = p.material("Honey amber iris", "DD9446", .42)
    lining = p.material("Rose gray ear velvet", "A06370", .87, 70)
    vest = p.material("Dark mulberry sparring vest", "4C283E", .82, 88)
    plum = p.material("Mulberry dyed silk weave", "8C385F", .77, 95)
    edge = p.material("Wine-red fold", "663654", .84)
    jade = p.material("Weathered turquoise glaze", "4A9091", .51, 105)
    jade_dark = p.material("Blue-black glazed leather", "214C59", .65, 95)
    bronze = p.material("Antique rose bronze", "B48564", .44, metallic=.35)
    thread = p.material("Dull copper thread", "DCB596", .78)
    leather = p.material("Charcoal cloth and leather", "292535", .87, 125)
    T, H = "Torso", "Head"

    p.loft(T, "Tapered fitted vest", [(1.46,0,.13,.41,.29),(1.80,0,.12,.52,.33),
           (2.25,.03,.12,.52,.36),(2.79,.02,.09,.70,.38),(3.10,.01,.07,.61,.34),
           (3.24,.01,.06,.38,.28)], vest, .06)
    p.loft(T, "Overlapping chest and scarf", [(2.04,-.08,-.222,.24,.067),(2.49,-.09,-.255,.32,.073),
           (2.94,-.08,-.23,.49,.071),(3.16,.01,-.216,.41,.065),(3.31,.06,-.172,.29,.073)], plum, .023)
    for index, (z, x, width) in enumerate(((2.35,-.16,.31),(2.55,-.09,.35),(2.76,-.01,.40),(2.98,.06,.44))):
        p.plate(T, f"Scarf overlapping fold {index+1}", [(x-width,-.319,z+.045),
                (x+width,-.341,z-.07),(x+width-.035,-.344,z-.105),(x-width,-.324,z-.006)][::-1], edge, .037, .008)
    p.loft(T, "Double-wound plum sash", [(1.57,0,.096,.51,.356),(1.65,0,.094,.58,.394),
           (1.87,0,.095,.57,.392),(1.93,0,.094,.51,.351)], edge, .029)
    for index in range(3):
        z = 1.65 + index*.09
        p.rounded_box(T, "Sash binding", (.02,-.306,z), (1.00,.045,.030), thread, .008,
                      (0,radians(-5+5*index),0))
    p.rounded_box(T, "Turquoise belt clasp", (.22,-.347,1.76), (.30,.132,.273), jade_dark, .047)
    p.rounded_box(T, "Bronze clasp frame", (.22,-.422,1.76), (.20,.034,.19), bronze, .028)
    p.plate(T, "Cold enamel clasp lozenge", [(.22,-.447,1.835),(.146,-.447,1.76),
            (.22,-.447,1.68),(.295,-.447,1.76)], jade, .013, .01)
    for side in (-1,1):
        p.plate(T, "Split tailcoat panel", [(side*.07,-.281,1.66),(side*.49,-.242,1.64),
                (side*.60,-.235,1.12),(side*.26,-.296,1.03),(side*.09,-.312,1.19)][::(-side)], vest, .073, .015)
        p.tube(T, "Tailcoat copper trim", [(side*.57,-.269,1.15),(side*.26,-.332,1.067),
               (side*.108,-.349,1.213)], [.018,.018,.015], bronze, sides=5)
    p.tube(T, "Scarf trailing tie", [(.42,.29,2.91),(.55,.59,2.78),(.62,.78,2.57),(.58,.92,2.28),
           (.51,1.04,1.97)], [.12,.124,.117,.087,.028], plum, sides=6, aspect=.48)

    p.loft(H, "Angular lynx skull", [(3.19,.026,.026,.33,.25),(3.37,.02,.014,.53,.39),
           (3.67,.01,.031,.63,.44),(3.97,0,.074,.64,.45),(4.23,0,.09,.49,.35),
           (4.36,0,.11,.31,.275)], fur, .041)
    p.loft(H, "Pale brow-to-chin blaze", [(3.30,0,-.322,.16,.14),(3.43,0,-.401,.29,.206),
           (3.64,0,-.416,.34,.203),(3.80,0,-.361,.25,.122),(3.94,0,-.365,.135,.064),
           (4.12,0,-.312,.08,.041)], fur_light, .033)
    p.loft(H, "Lynx nose leather", [(3.658,0,-.621,.043,.029),(3.703,0,-.632,.138,.041),
           (3.787,0,-.616,.121,.046),(3.81,0,-.593,.099,.034)], nose, .017)
    p.tube(H, "Set feline mouth", [(-.19,-.555,3.46),(-.115,-.598,3.444),(0,-.618,3.466),
           (.110,-.594,3.443),(.186,-.552,3.455)], [.013,.017,.019,.016,.012], ink, sides=6)
    for side in (-1,1):
        x = side*.322
        face = (0, radians(10*side), radians(14*side))
        p.rounded_box(H, "Narrow kohl eye socket", (x,-.347,3.952), (.355,.134,.197), ink, .054, face)
        p.rounded_box(H, "Narrow ivory sclera", (x,-.414,3.943), (.256,.043,.125), white, .056, face)
        p.ellipse(H, "Gold lynx iris", (x-side*.029,-.439,3.937), (.065,.025,.067), iris)
        p.ellipse(H, "Dark lynx pupil", (x-side*.021,-.458,3.944), (.024,.012,.054), ink)
        p.rounded_box(H, "Sharp lowered brow", (x,-.386,4.031), (.43,.124,.112), fur_dark, .032,
                      (0,radians(-17*side),radians(13*side)))
        for j, (base, z, length) in enumerate(((.40,3.665,.364),(.42,3.535,.32),(.41,3.42,.252))):
            outline = [(side*base,-.35,z+.09),(side*(base+length),-.18,z-.13),
                       (side*(base+.16),-.36,z-.12),(side*(base-.045),-.393,z-.035)]
            p.plate(H, f"Pointed winter cheek ruff {j+1}", outline[::(-side)], fur_light, .13, .016)
        p.plate(H, "Temple mackerel mark", [(side*.43,-.302,4.13),(side*.62,-.246,4.05),
                (side*.61,-.273,3.93),(side*.50,-.33,4.028)][::(-side)], fur_dark, .02, .006)
        for j in range(3):
            p.ellipse(H, "Whisker spot", (side*(.15+.046*j),-.614+.035*j,3.57+.021*j), (.019,.014,.019), nose)
        ear = [(side*.28,.002,4.20),(side*.45,.098,4.98),
               (side*.602,.081,5.11),(side*.72,.011,4.308)]
        p.plate(H, "Lynx angular ear", ear[::-side], fur, .142, .028)
        patch = [(side*.355,-.035,4.35),(side*.494,.021,4.888),(side*.573,.014,4.984),(side*.660,-.031,4.394)]
        p.plate(H, "Inset rose ear velvet", patch[::-side], lining, .045, .012)
        p.tube(H, "Signature lynx ear tuft", [(side*.586,.061,4.983),(side*.636,.074,5.113),
               (side*.68,.081,5.29),(side*.696,.088,5.38)], [.076,.058,.027,.009], fur_dark, sides=6, aspect=.75)
        if side == 1:
            p.rounded_box(H, "Small ear bronze accent", (.689,.020,4.42), (.103,.143,.091), bronze, .024)

    pivots = {T:(0,0,1.78),H:(0,.03,3.23),"Tail":(0,.39,1.55)}
    for side, label in ((-1,"Left"),(1,"Right")):
        arm, leg = label+" Arm",label+" Leg"
        pivots[arm]=(side*.647,.04,2.96)
        pivots[leg]=(side*.335,.14,1.57)
        advance = -.13 if side == 1 else .03
        p.tube(arm, "Athletic bent upper sleeve", [(side*.59,.03,3.02),(side*.81,.02,2.87),
               (side*1.01,-.12+advance,2.50),(side*1.046,-.20+advance,2.40)],
               [.23,.29,.233,.20], vest, sides=9, aspect=1.06)
        p.tube(arm, "Taped forearm", [(side*1.046,-.18+advance,2.44),
               (side*1.04,-.42+advance,2.57),(side*.979,-.65+advance,2.77),
               (side*.925,-.81+advance,2.891)], [.19,.235,.218,.187], fur, sides=9)
        p.rounded_box(arm, "Angular padded glove", (side*.942,-.866+advance,2.978),
                      (.50,.504,.524), jade_dark, .087, (radians(-22),0,radians(-9*side)))
        p.rounded_box(arm, "Inset teal knuckle pad", (side*.940,-1.096+advance,3.044),
                      (.422,.158,.273), jade, .058, (radians(-13),0,radians(-9*side)))
        for j in range(3):
            p.rounded_box(arm, "Wine wrist wrap", (side*(1.029-.026*j),-.405-.099*j+advance,2.572+.086*j),
                          (.435,.133,.44), plum if j!=1 else edge, .035, (radians(-42),0,radians(-6*side)))
        p.rounded_box(arm, "Shoulder leather base", (side*.787,.009,3.019), (.58,.661,.392),
                      vest, .074, (0,radians(-18*side),0))
        if side == -1:
            for j in range(3):
                p.rounded_box(arm, "Jade shoulder lames", (-.80-.086*j,.003-.033*j,3.139-.105*j),
                              (.445,.588-.054*j,.122), jade if j==0 else jade_dark, .049,
                              (0,radians(-15),0))
            for y in (-.213,.147):
                p.ellipse(arm, "Bronze shoulder stud", (-.839,y,3.218), (.059,.059,.033), bronze)
        else:
            p.tube(arm, "Double shoulder cord", [(.705,-.28,3.17),(.86,-.329,3.054),
                   (1.01,-.216,2.97)], [.034,.043,.034], thread, sides=6)
        bx, by = side*.52, -.09 if side == 1 else .26
        p.loft(leg, "Tapered shin and knee", [(.29,bx,by,.211,.206),(.49,bx,by+.035,.25,.251),
               (.82,bx-side*.035,by+.065,.267,.268),(1.13,side*.45,by+.075,.29,.282),
               (1.59,side*.335,.13,.29,.26)], leather, .034)
        p.loft(leg, "Ankle cuff", [(.43,bx,by,.251,.244),(.53,bx,by+.008,.27,.259),
               (.63,bx,by+.020,.258,.25)], edge, .025)
        p.rounded_box(leg, "Soft split-toe sparring boot", (bx,by-.156,.188),(.569,.818,.376),
                      leather,.074,(0,0,radians(-6*side)))
        p.rounded_box(leg, "Glazed boot toe", (bx,by-.505,.208),(.465,.18,.274),jade_dark,.047)
        p.rounded_box(leg, "Rose bronze toe seam", (bx,by-.59,.214),(.029,.026,.199),bronze,.009)
        p.plate(leg,"Tapered shin facing", [(bx-.167,by-.235,.88),(bx-.137,by-.249,.55),
                (bx+.132,by-.249,.55),(bx+.165,by-.235,.88)],jade,.031,.019)
        p.rounded_box(leg,"Shin facing stitch",(bx,by-.257,.77),(.22,.040,.028),thread,.009)
    p.tube("Tail", "Short lynx bobtail", [(0,.37,1.61),(.07,.62,1.54),(.13,.79,1.65),
           (.165,.9,1.81)], [.137,.158,.129,.074], fur, sides=9)
    p.tube("Tail", "Dark bobtail end", [(.13,.79,1.65),(.166,.904,1.817),(.176,.943,1.90)],
           [.129,.076,.019], fur_dark, sides=9)
    return pivots
