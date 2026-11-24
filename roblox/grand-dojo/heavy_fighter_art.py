"""Floor-aligned native shells for Walrus Sumo and Snapping Tortoise."""

from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _walrus(art):
    slate, gray, stone, mist = "536A82", "34495D", "748CA2", "A6BEC9"
    ink, navy, blue, cyan = "17232D", "253855", "315C86", "579EAC"
    cream, ivory, clay, coral = "DCC2A0", "F6E0AE", "896F71", "B8897C"
    brass = "E9B671"

    body = art.group("Torso", (0, 2.325, -.071), (2.576, 2.366, 2.049))
    art.detail(body, "Broad slate body", (0, 2.35, .02), (2.56, 2.09, 1.85), slate)
    art.detail(body, "Belly strike surface", (0, 2.38, -.668), (1.79, 1.35, .644), mist)
    art.detail(body, "Padded shoulder ruff", (0, 3.075, .073), (2.18, .85, 1.59), gray)
    art.detail(body, "Pale throat", (0, 3.065, -.57), (1.29, .692, .59), stone)
    art.detail(body, "Indigo practice skirt", (0, 1.55, .075), (2.11, .80, 1.62), navy, material=FABRIC)
    art.detail(body, "Sumo belt", (0, 1.75, .024), (2.32, .367, 1.68), blue, material=FABRIC)
    art.detail(body, "White stitched belt facing", (0, 1.838, -.787), (1.83, .125, .146), mist,
               shape=BLOCK, material=FABRIC)
    art.detail(body, "Broad knotted belt fold", (.11, 1.751, -.89), (.646, .402, .25), cyan,
               roll=-12, material=FABRIC)
    art.detail(body, "Long pleated sash end", (.18, 1.480, -.839), (.325, .576, .119), blue,
               shape=BLOCK, roll=-16, material=FABRIC)
    art.detail(body, "Fringed white sash end", (-.11, 1.475, -.846), (.23, .486, .112), mist,
               shape=BLOCK, roll=18, material=FABRIC)
    art.detail(body, "Harbor belt medal", (.10, 1.756, -1.025), (.125, .231, .231), brass,
               shape=CYLINDER, yaw=90)
    for side in (-1, 1):
        art.detail(body, "Wrapped flank of the belt", (side * .855, 1.750, -.497), (.38, .295, .50), blue,
                   yaw=side * -26, material=FABRIC)
        art.detail(body, "Short fold seam", (side * .73, 1.475, -.557), (.09, .39, .113), cyan,
                   roll=side * -15, material=FABRIC)

    head = art.group("Head", (0, 3.843, -.162), (1.963, 1.571, 1.831), (0, 3.16, -.06))
    art.detail(head, "Walrus head", (0, 3.91, .004), (1.94, 1.42, 1.48), stone)
    art.detail(head, "Broad flat walrus brow", (0, 4.245, -.354), (1.72, .60, .82), slate)
    art.detail(head, "Walrus chin", (0, 3.42, -.32), (1.33, .58, .79), clay)
    art.detail(head, "Seal-dark nose", (0, 3.933, -.840), (.56, .273, .37), gray)
    art.detail(head, "Soft nose highlight", (.032, 3.988, -.998), (.25, .078, .057), stone)
    art.detail(head, "Light lower lip", (0, 3.476, -.685), (.61, .186, .36), coral)
    for side in (-1, 1):
        art.detail(head, "Solid muzzle cushion", (side * .35, 3.722, -.700), (.88, .55, .66), cream,
                   yaw=side * 9, roll=side * -9)
        art.detail(head, "Cushion face spot", (side * .455, 3.74, -.976), (.29, .235, .095), ivory,
                   yaw=side * -20)
        art.detail(head, "Blunt cream tusk", (side * .45, 3.453, -.828), (.225, .60, .286), ivory,
                   pitch=15, roll=side * -12)
        art.detail(head, "Rounded tusk end", (side * .502, 3.180, -.904), (.186, .234, .182), "F3DCAF",
                   pitch=17, roll=side * -9)
        art.detail(head, "Warm tusk band", (side * .452, 3.476, -.949), (.088, .127, .069), brass)
        art.detail(head, "Dark eye socket", (side * .518, 4.114, -.622), (.50, .40, .296), gray,
                   yaw=side * -24)
        art.detail(head, "Walrus eye white", (side * .501, 4.105, -.753), (.354, .275, .151), "F5DEC7",
                   yaw=side * -24)
        art.detail(head, "Steady walrus iris", (side * .455, 4.101, -.813), (.145, .179, .104), ink,
                   yaw=side * -22)
        art.detail(head, "Small pupil catchlight", (side * .455 + .029, 4.145, -.850), (.059, .053, .043), "FFF5DC")
        art.detail(head, "Raised sumo brow", (side * .54, 4.253, -.738), (.48, .124, .131), gray,
                   yaw=side * -27, roll=side * 20)
        for index, (y, width, angle) in enumerate(((3.816, .61, 10), (3.748, .68, -3), (3.678, .59, -15))):
            art.detail(head, f"Ivory whisker {index + 1}", (side * .647, y, -.972),
                       (width, .045, .050), ivory, yaw=side * -16, roll=side * angle)

    for side, name in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{name} Arm", (side * 1.255, 2.349, -.154), (1.06, 1.582, 1.336),
                        (side * 1.02, 2.98, .03))
        art.detail(arm, "Heavy shoulder", (side * 1.183, 2.71, .041), (.91, .83, .93), slate,
                   roll=side * 23)
        art.detail(arm, "Walrus forearm", (side * 1.346, 2.247, -.035), (.84, 1.07, .83), gray,
                   roll=side * 16, pitch=-11)
        art.detail(arm, "Broad blue wrist guard", (side * 1.371, 2.104, -.217), (.65, .60, .79), blue,
                   roll=side * 14)
        art.detail(arm, "Contrast wrist binding", (side * 1.378, 2.004, -.253), (.10, .657, .81), mist,
                   shape=CYLINDER, roll=90 + side * 11)
        art.detail(arm, "Open palm", (side * 1.37, 1.80, -.458), (.65, .46, .69), stone)
        art.detail(arm, "Padded palm strike surface", (side * 1.37, 1.80, -.673), (.498, .379, .282), mist)
        art.detail(arm, "Inward thumb pad", (side * 1.178, 1.785, -.542), (.253, .265, .464), stone,
                   yaw=side * 19)
        for index, delta in enumerate((-.153, .005, .163)):
            art.detail(arm, f"Soft finger {index + 1}", (side * (1.37 + delta), 1.682, -.564),
                       (.152, .233, .303), stone, roll=side * -8)

        leg = art.group(f"{name} Leg", (side * .610, .766, -.208), (1.066, 1.532, 1.49), (side * .58, 1.48, .03))
        art.detail(leg, "Sumo trouser leg", (side * .604, 1.06, .048), (1.00, .93, .96), navy,
                   roll=side * -10, material=FABRIC)
        art.detail(leg, "Hip belt fold", (side * .698, 1.279, -.353), (.303, .382, .27), blue, roll=side * -23)
        art.detail(leg, "Wide shin", (side * .612, .59, -.087), (.812, .83, .72), stone,
                   pitch=-12, roll=side * 7)
        art.detail(leg, "Indigo ankle wrap", (side * .610, .389, -.201), (.114, .825, .80), blue,
                   shape=CYLINDER, roll=90 + side * 5)
        art.detail(leg, "Broad planted flipper", (side * .610, .185, -.355), (1.05, .37, 1.18), gray)
        art.detail(leg, "Light flipper toe welt", (side * .610, .132, -.742), (.79, .20, .355), slate)
        art.detail(leg, "Forefoot toe ridge", (side * .627, .194, -.771), (.492, .098, .220), stone)

    tail = art.group("Tail", (0, 1.44, 1.107), (1.214, .561, 1.25), (0, 1.55, .57))
    art.detail(tail, "Walrus tail base", (0, 1.46, .91), (.70, .47, .86), gray, pitch=15)
    for side in (-1, 1):
        art.detail(tail, "Wide rounded tail flipper", (side * .284, 1.32, 1.344), (.62, .278, .778), slate,
                   yaw=side * -14, pitch=10)


def _tortoise(art):
    peat, stone, bark, moss = "263A34", "445F50", "36504A", "67816A"
    basalt, seam, scute, mineral = "293533", "536655", "576D58", "95A880"
    amber, sunrise, lacquer, dark = "E7AF67", "FFD183", "B45638", "49372D"
    plastron, jaw, cream, ink = "BFA77C", "8DA786", "F3D1A0", "202B29"

    body = art.group("Torso", (0, 2.46, .415), (2.627, 2.636, 2.861))
    art.detail(body, "Stone-green abdomen", (0, 2.305, -.011), (2.20, 1.96, 1.64), stone)
    art.detail(body, "Broad shell rim", (0, 2.46, .565), (2.59, 2.62, 1.57), seam)
    art.detail(body, "Basalt back dome", (0, 2.46, .761), (2.50, 2.42, 1.75), basalt)
    art.detail(body, "Deep stone shell center", (0, 2.46, 1.399), (.94, 1.09, .575), scute)
    art.detail(body, "Rounded central shell spur", (0, 2.675, 1.682), (.33, .384, .311), mineral)
    for side in (-1, 1):
        art.detail(body, "Side shell scute", (side * .705, 2.53, 1.302), (.87, 1.031, .465), scute,
                   yaw=side * 35, roll=side * 9)
        art.detail(body, "Raised basalt ridge", (side * .50, 3.175, 1.16), (.58, .66, .542), scute,
                   yaw=side * 29, pitch=-18, roll=side * 21)
        art.detail(body, "Lower shell scute", (side * .465, 1.81, 1.278), (.701, .58, .449), stone,
                   yaw=side * 26, pitch=11, roll=side * -12)
        art.detail(body, "Blunt rear shell spur", (side * .675, 2.754, 1.60), (.328, .384, .320), mineral,
                   yaw=side * 23)
        art.detail(body, "Blunt crown shell spur", (side * .50, 3.336, 1.28), (.295, .401, .316), mineral,
                   yaw=side * 16, roll=side * -23)
        art.detail(body, "Rim plate", (side * 1.093, 2.513, .704), (.337, .938, .65), moss,
                   yaw=side * 24, roll=side * 9)
        art.detail(body, "Wide shell harness band", (side * .438, 2.692, -.740), (.239, 1.296, .169), lacquer,
                   shape=BLOCK, roll=side * -28, material=FABRIC)
        art.detail(body, "Warm stitching on shell harness", (side * .504, 2.77, -.841), (.066, 1.023, .037), amber,
                   shape=BLOCK, roll=side * -28)
        art.detail(body, "Lower plastron scute", (side * .344, 1.98, -.634), (.715, .621, .444), plastron,
                   yaw=side * -19, roll=side * 13)
    art.detail(body, "Heavy plastron", (0, 2.44, -.606), (1.76, 1.63, .658), plastron)
    art.detail(body, "Scute seam", (0, 2.5, -.938), (1.06, .071, .076), dark)
    art.detail(body, "Sunrise belt", (0, 1.68, -.068), (2.29, .34, 1.74), lacquer, material=FABRIC)
    art.detail(body, "Belt crosspiece", (0, 1.756, -.819), (1.48, .095, .167), amber,
               shape=BLOCK, material=FABRIC)
    art.detail(body, "Sunrise clasp", (.174, 1.714, -.937), (.14, .293, .293), sunrise, shape=CYLINDER, yaw=90)

    head = art.group("Head", (0, 3.828, -.263), (1.81, 1.362, 1.69), (0, 3.14, -.07))
    art.detail(head, "Wide tortoise crown", (0, 3.905, -.046), (1.69, 1.19, 1.24), stone)
    art.detail(head, "Broad straight lower jaw", (0, 3.474, -.579), (1.37, .342, .96), jaw, shape=BLOCK,
               pitch=-5)
    art.detail(head, "Tapered snapping muzzle", (0, 3.722, -.614), (1.43, .487, .959), moss, pitch=9)
    art.detail(head, "Blunt upper beak", (0, 3.651, -.987), (.64, .271, .222), cream, pitch=-18)
    art.detail(head, "Square dark beak line", (0, 3.55, -.956), (.812, .061, .17), peat, shape=BLOCK)
    art.detail(head, "Neck fold", (0, 3.384, -.184), (1.23, .457, .86), bark)
    for side in (-1, 1):
        art.detail(head, "Rugged jaw corner", (side * .692, 3.588, -.463), (.383, .53, .72), jaw,
                   yaw=side * -11)
        art.detail(head, "Breaking shell temple plate", (side * .724, 3.987, -.018), (.327, .60, .64), peat,
                   roll=side * -13)
        art.detail(head, "Dark tortoise eye socket", (side * .478, 3.996, -.602), (.465, .385, .318), peat,
                   yaw=side * -25)
        art.detail(head, "Amber tortoise iris", (side * .46, 3.988, -.737), (.305, .247, .13), sunrise,
                   yaw=side * -22)
        art.detail(head, "Tortoise pupil", (side * .427, 3.985, -.791), (.133, .184, .081), ink,
                   yaw=side * -18)
        art.detail(head, "Tortoise eye catchlight", (side * .427 + .024, 4.035, -.820), (.053, .043, .028), "FFF3C4")
        art.detail(head, "Shielded angled brow", (side * .495, 4.133, -.719), (.435, .165, .132), bark,
                   yaw=side * -22, roll=side * 17)

    for side, name in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{name} Arm", (side * 1.18, 2.403, -.093), (.975, 1.40, 1.278),
                        (side * .97, 2.93, .13))
        art.detail(arm, "Broad scale shoulder", (side * 1.132, 2.725, .136), (.877, .72, .802), stone,
                   roll=side * 19)
        art.detail(arm, "Outer shoulder scute", (side * 1.397, 2.719, .128), (.39, .60, .682), moss,
                   roll=side * 18)
        art.detail(arm, "Tortoise forearm", (side * 1.277, 2.312, -.041), (.759, .82, .80), bark,
                   roll=side * 18)
        art.detail(arm, "Padded sparring wrap", (side * 1.276, 2.145, -.143), (.694, .646, .73), lacquer,
                   roll=side * 16, material=FABRIC)
        art.detail(arm, "Sunrise wrist binding", (side * 1.298, 2.034, -.214), (.113, .683, .747), amber,
                   shape=CYLINDER, roll=90 + side * 14)
        art.detail(arm, "Wide tortoise hand", (side * 1.30, 1.92, -.44), (.648, .416, .568), moss)
        art.detail(arm, "Padded tortoise knuckles", (side * 1.30, 1.92, -.600), (.515, .325, .248), plastron)
        art.detail(arm, "Soft thumb", (side * 1.071, 1.933, -.407), (.251, .242, .388), stone, yaw=side * 19)

        leg = art.group(f"{name} Leg", (side * .58, .776, -.214), (1.007, 1.552, 1.430),
                         (side * .56, 1.46, .06))
        art.detail(leg, "Tortoise haunch", (side * .57, 1.101, .046), (.946, .889, .891), bark,
                   roll=side * -10)
        art.detail(leg, "Heavy tortoise shin", (side * .594, .611, -.133), (.801, .82, .785), stone,
                   pitch=-16, roll=side * 8)
        art.detail(leg, "Lacquer shin pad", (side * .599, .608, -.448), (.612, .583, .271), lacquer, pitch=-11)
        art.detail(leg, "Warm ankle binding", (side * .580, .378, -.208), (.104, .826, .781), amber,
                   shape=CYLINDER, roll=90 + side * 11)
        art.detail(leg, "Planted tortoise forefoot", (side * .58, .185, -.340), (.99, .37, 1.16), peat)
        art.detail(leg, "Worn plastron toe cap", (side * .58, .140, -.754), (.76, .212, .295), jaw)
        for index, delta in enumerate((-.234, 0, .234)):
            art.detail(leg, f"Blunt toe {index + 1}", (side * (.58 + delta), .129, -.821),
                       (.137, .162, .193), plastron)

    tail = art.group("Tail", (0, 1.432, 1.458), (.644, .649, 1.084), (0, 1.65, 1.0))
    art.detail(tail, "Tortoise tail base", (0, 1.462, 1.258), (.628, .553, .686), bark, pitch=22)
    art.detail(tail, "Short armored tail end", (0, 1.32, 1.668), (.412, .375, .667), stone, pitch=17)
    art.detail(tail, "Rounded tail scute", (0, 1.481, 1.659), (.294, .199, .481), moss, pitch=17)


def build_heavy_visuals(library, *, item, part, prop, vector):
    """Build original heavyweight fighter art without external asset dependencies."""
    helpers = dict(item=item, part=part, prop=prop, vector=vector)
    _walrus(_FighterArt(library, "walrus-sumo", **helpers))
    _tortoise(_FighterArt(library, "snapping-tortoise", **helpers))
