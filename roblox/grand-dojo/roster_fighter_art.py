"""Original floor-aligned rigid art for the amphibian and river starters."""

BALL, BLOCK, CYLINDER = 0, 1, 2
FABRIC = 1312
FRAME = ("X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22")
IDENTITY = (1, 0, 0, 0, 1, 0, 0, 0, 1)


class _FighterArt:
    def __init__(self, library, identifier, *, item, part, prop, vector):
        self.model = item(library, "Model", identifier)
        self.item = item
        self.part = part
        self.prop = prop
        self.vector = vector

    def group(self, name, position, size, pivot=None):
        root = self.part(self.model, name, position, size, "FFFFFF", collide=False, transparency=1)
        self.prop(root, "bool", "Massless", True)
        self.prop(root, "bool", "CastShadow", False)
        if pivot is not None:
            attachment = self.item(root, "Attachment", "ArtPivot")
            local_pivot = tuple(point - center for point, center in zip(pivot, position))
            self.vector(attachment, "CoordinateFrame", "CFrame", FRAME, (*local_pivot, *IDENTITY))
        return root

    def detail(self, group, name, position, size, tint, *, shape=BALL, **options):
        detail = self.part(group, name, position, size, tint, shape=shape, collide=False, **options)
        self.prop(detail, "bool", "Massless", True)
        self.prop(detail, "bool", "CastShadow", min(size) >= .22)


def _build_frog(art):
    skin, moss, foot, lip = "7EAB4B", "4B7739", "69953E", "B4C769"
    jade, reed, seam, cream = "305C49", "438066", "123D37", "F1D9A5"
    gold, ink, eye = "E4B963", "152F2A", "F2D781"
    torso = art.group("Torso", (0, 2.32, -.045), (1.66, 2.16, 1.37))
    head = art.group("Head", (0, 3.91, -.163), (1.86, 1.56, 1.45), (0, 3.07, -.03))
    art.detail(torso, "Quilted pond-green jacket", (0, 2.38, .04), (1.61, 1.72, 1.11), jade, material=FABRIC)
    art.detail(torso, "Lichen-colored throat", (0, 3.10, -.05), (.80, .58, .75), lip)
    art.detail(torso, "Underjacket", (0, 2.66, -.43), (.88, .95, .26), reed, material=FABRIC)
    art.detail(torso, "Overlapping gi skirt", (0, 1.67, .05), (1.57, .70, 1.16), seam, material=FABRIC)
    art.detail(torso, "Brocade sash", (0, 1.83, .03), (1.64, .32, 1.18), gold, material=FABRIC)
    art.detail(torso, "Sash binding", (0, 1.86, -.51), (1.25, .09, .11), cream, material=FABRIC)
    art.detail(torso, "Sash knot", (.29, 1.80, -.61), (.37, .27, .21), cream, yaw=13, roll=18, material=FABRIC)
    art.detail(torso, "Folded sash end", (.42, 1.55, -.58), (.19, .45, .10), cream, shape=BLOCK, roll=22, material=FABRIC)
    art.detail(torso, "Folded sash lining", (.22, 1.53, -.57), (.15, .45, .10), gold, shape=BLOCK, roll=-13, material=FABRIC)
    for sign in (-1, 1):
        art.detail(torso, "Ivory crossover collar", (sign * .24, 2.75, -.55), (.18, .88, .10), cream,
                   shape=BLOCK, yaw=sign * -11, roll=sign * -33, material=FABRIC)
        art.detail(torso, "Crossover seam", (sign * .33, 2.74, -.51), (.05, .85, .11), gold,
                   shape=BLOCK, yaw=sign * -11, roll=sign * -33)
        art.detail(torso, "Split green gi panel", (sign * .37, 1.54, -.31), (.65, .57, .56), reed,
                   roll=sign * 9, material=FABRIC)
    art.detail(torso, "Lily badge leaf", (-.48, 2.72, -.49), (.29, .24, .12), gold, roll=18)
    art.detail(torso, "Lily badge center", (-.49, 2.75, -.55), (.10, .10, .04), reed)

    art.detail(head, "Frog crown", (0, 3.76, -.05), (1.66, 1.23, 1.21), skin)
    art.detail(head, "Broad amphibian jaw", (0, 3.52, -.33), (1.64, .73, 1.04), lip)
    art.detail(head, "Rounded snout", (0, 3.78, -.49), (1.57, .56, .77), skin)
    art.detail(head, "Mouth seam", (0, 3.53, -.846), (1.04, .060, .072), moss)
    for sign in (-1, 1):
        art.detail(head, "Raised orbital ridge", (sign * .53, 4.23, -.03), (.78, .90, .83), moss, roll=sign * -13)
        art.detail(head, "Tapered jade eyelid", (sign * .54, 4.34, -.36), (.70, .53, .29), skin, roll=sign * -15)
        art.detail(head, "Golden amphibian iris", (sign * .54, 4.27, -.435), (.48, .44, .23), eye, yaw=sign * -16)
        art.detail(head, "Vertical pupil", (sign * .523, 4.27, -.540), (.115, .329, .09), ink, yaw=sign * -16)
        art.detail(head, "Catchlight", (sign * .52 + .03, 4.366, -.588), (.072, .092, .037), "FFF4CB")
        art.detail(head, "Focused brow", (sign * .523, 4.449, -.505), (.414, .104, .13), moss,
                   yaw=sign * -13, roll=sign * 15)
        art.detail(head, "Outer cheek freckle", (sign * .71, 3.70, -.69), (.12, .091, .046), moss, yaw=sign * -33)
        art.detail(head, "Nostril", (sign * .24, 3.83, -.854), (.111, .056, .036), moss, roll=sign * 16)
        art.detail(head, "Upturned mouth corner", (sign * .52, 3.545, -.802), (.19, .056, .09), moss,
                   yaw=sign * -36, roll=sign * 14)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.025, 2.41, -.14), (.82, 1.45, 1.06), (sign * .79, 2.94, .02))
        art.detail(arm, "Rounded upper arm", (sign * .95, 2.69, .04), (.63, .89, .66), skin, roll=sign * 18)
        art.detail(arm, "Green sleeve cuff", (sign * 1.01, 2.50, -.005), (.16, .65, .64), reed,
                   shape=CYLINDER, roll=90 + sign * 15, material=FABRIC)
        art.detail(arm, "Thick cream wrap", (sign * 1.075, 2.19, -.20), (.59, .73, .63), cream, roll=sign * 16, material=FABRIC)
        for y, z in ((2.34, -.16), (2.20, -.215), (2.06, -.27)):
            art.detail(arm, "Wrapped cord seam", (sign * 1.08, y, z), (.061, .594, .646), gold,
                       shape=CYLINDER, roll=90 + sign * 13)
        art.detail(arm, "Wide frog hand", (sign * 1.10, 1.94, -.35), (.65, .43, .61), moss)
        art.detail(arm, "Rounded knuckle pads", (sign * 1.10, 1.855, -.475), (.60, .32, .36), foot)

        leg = art.group(f"{side} Leg", (sign * .48, .79, -.16), (.86, 1.58, 1.34), (sign * .46, 1.50, .04))
        art.detail(leg, "Spring-loaded haunch", (sign * .49, 1.10, .04), (.81, .96, .91), jade,
                   roll=sign * -16, material=FABRIC)
        art.detail(leg, "Bent green shin", (sign * .52, .59, -.09), (.57, .78, .75), skin, pitch=22, roll=sign * 11)
        art.detail(leg, "Soft ankle binding", (sign * .50, .41, -.20), (.15, .61, .73), cream,
                   shape=CYLINDER, pitch=12, roll=90 + sign * 11, material=FABRIC)
        art.detail(leg, "Webbed toe silhouette", (sign * .48, .13, -.41), (.83, .26, .82), foot,
                   yaw=sign * -8)
        for finger, z in ((-1, -.65), (0, -.67), (1, -.62)):
            art.detail(leg, "Rounded webbed toe", (sign * (.48 + finger * .22), .12, z), (.25, .24, .30), lip,
                       yaw=sign * (-8 - finger * 14))


def _build_otter(art):
    fur, russet, dark = "AC774F", "8C563A", "553E35"
    bone, cream, ice = "DEB082", "F4D6A8", "9ACDCC"
    navy, blue, teal, dark_blue = "24455F", "37688E", "53A4AB", "213748"
    ink, gold = "332B28", "D9A863"
    torso = art.group("Torso", (0, 2.32, -.035), (1.88, 2.17, 1.44))
    head = art.group("Head", (0, 3.918, -.255), (1.87, 1.36, 1.59), (0, 3.14, -.08))
    art.detail(torso, "Indigo river vest", (0, 2.48, .03), (1.72, 1.67, 1.22), navy, material=FABRIC)
    art.detail(torso, "Broad shoulder yoke", (0, 2.84, .045), (1.86, .72, 1.05), blue, material=FABRIC)
    art.detail(torso, "Ivory throat ruff", (0, 3.04, -.13), (.98, .68, .83), cream, pitch=12)
    art.detail(torso, "River apron", (0, 1.67, -.05), (1.45, .85, 1.10), dark_blue, material=FABRIC)
    art.detail(torso, "Crossing river sash", (0, 1.84, -.01), (1.67, .33, 1.25), teal, material=FABRIC)
    art.detail(torso, "Water-stitched piping", (0, 1.86, -.622), (1.33, .058, .11), ice)
    art.detail(torso, "Sash buckle", (.31, 1.84, -.66), (.11, .24, .36), gold, shape=CYLINDER, yaw=90)
    art.detail(torso, "Buckle bead", (.31, 1.84, -.722), (.13, .10, .05), teal)
    art.detail(torso, "Pebble pouch", (.60, 1.71, -.31), (.37, .52, .43), dark, roll=14, material=FABRIC)
    art.detail(torso, "Pebble pouch flap", (.64, 1.79, -.48), (.38, .22, .12), gold, roll=13, material=FABRIC)
    for sign in (-1, 1):
        art.detail(torso, "Layered river lapel", (sign * .29, 2.63, -.54), (.30, 1.01, .22), blue,
                   shape=BLOCK, yaw=sign * -15, roll=sign * -27, material=FABRIC)
        art.detail(torso, "Turquoise lapel edge", (sign * .345, 2.63, -.651), (.062, .993, .060), teal,
                   shape=BLOCK, yaw=sign * -15, roll=sign * -27)
    art.detail(torso, "Back water crest", (0, 2.69, .61), (.49, .51, .095), teal, roll=26)
    art.detail(torso, "Back water crest curl", (.073, 2.74, .66), (.32, .30, .035), navy, roll=26)

    art.detail(head, "Otter skull", (0, 3.94, -.08), (1.70, 1.29, 1.22), fur)
    art.detail(head, "Ivory lower jaw", (0, 3.53, -.32), (1.28, .56, .99), cream)
    art.detail(head, "Lower lip", (0, 3.48, -.78), (.42, .08, .105), russet)
    for sign in (-1, 1):
        art.detail(head, "Rounded otter ear", (sign * .72, 4.34, .06), (.40, .44, .55), dark, roll=sign * -29)
        art.detail(head, "Otter ear rim", (sign * .75, 4.35, -.14), (.32, .33, .23), fur, roll=sign * -29)
        art.detail(head, "Inset ear cup", (sign * .76, 4.36, -.23), (.20, .22, .115), bone, roll=sign * -29)
        art.detail(head, "Ivory whisker cheek", (sign * .31, 3.70, -.594), (.78, .57, .58), cream,
                   yaw=sign * -15, roll=sign * 8)
        art.detail(head, "Dark upper eyelid", (sign * .37, 4.06, -.552), (.41, .39, .28), dark,
                   yaw=sign * -19, roll=sign * 16)
        art.detail(head, "Eye white", (sign * .36, 4.04, -.651), (.321, .348, .15), "FFF4D4",
                   yaw=sign * -19, roll=sign * 16)
        art.detail(head, "Dark eye", (sign * .325, 4.045, -.720), (.161, .229, .10), ink)
        art.detail(head, "Catchlight", (sign * .325 + .032, 4.105, -.770), (.058, .067, .029), "FFFAE2")
        art.detail(head, "Tilted brow", (sign * .39, 4.24, -.59), (.44, .16, .19), russet,
                   yaw=sign * -19, roll=sign * 19)
        art.detail(head, "Upper whisker", (sign * .535, 3.744, -.830), (.29, .039, .050), russet,
                   yaw=sign * -25, roll=sign * 12)
        art.detail(head, "Lower whisker", (sign * .521, 3.691, -.836), (.25, .036, .045), russet,
                   yaw=sign * -24, roll=sign * -9)
    art.detail(head, "Round coal nose", (0, 3.818, -.899), (.43, .24, .28), ink)
    art.detail(head, "Nose sheen", (-.045, 3.89, -1.009), (.16, .052, .041), bone, roll=-10)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.05, 2.475, -.125), (.85, 1.48, 1.08), (sign * .82, 3.03, .02))
        art.detail(arm, "Ochre fur shoulder", (sign * .99, 2.76, .00), (.69, .90, .70), fur, roll=sign * 17)
        art.detail(arm, "River vest sleeve", (sign * .99, 2.87, .04), (.72, .66, .73), blue,
                   roll=sign * 17, material=FABRIC)
        art.detail(arm, "Blue hand wrap", (sign * 1.105, 2.26, -.18), (.59, .73, .64), teal,
                   roll=sign * 12, material=FABRIC)
        for y, z in ((2.36, -.145), (2.17, -.202)):
            art.detail(arm, "Folded wrap border", (sign * 1.10, y, z), (.09, .61, .635), ice,
                       shape=CYLINDER, roll=90 + sign * 13)
        art.detail(arm, "Palm and fingers", (sign * 1.15, 1.99, -.34), (.63, .48, .61), fur)
        art.detail(arm, "Ivory palm pad", (sign * 1.15, 1.91, -.475), (.50, .30, .36), cream)

        leg = art.group(f"{side} Leg", (sign * .50, .80, -.165), (.82, 1.60, 1.24), (sign * .47, 1.54, .03))
        art.detail(leg, "River-cloth thigh", (sign * .49, 1.08, .03), (.75, 1.02, .83), blue,
                   roll=sign * -12, material=FABRIC)
        art.detail(leg, "Otter shin", (sign * .53, .57, -.09), (.56, .82, .73), russet, pitch=19, roll=sign * 9)
        art.detail(leg, "Ankle sash", (sign * .52, .45, -.14), (.14, .59, .70), teal,
                   shape=CYLINDER, roll=90 + sign * 10, material=FABRIC)
        art.detail(leg, "Streamlined forefoot", (sign * .50, .143, -.35), (.74, .286, .85), fur, yaw=sign * -9)
        art.detail(leg, "Ivory toe pad", (sign * .50, .161, -.591), (.60, .236, .294), bone, yaw=sign * -9)

    tail = art.group("Tail", (0, 1.20, 1.46), (.72, 1.08, 2.34), (0, 1.46, .48))
    art.detail(tail, "Muscular tail root", (0, 1.36, .85), (.69, .69, 1.15), russet, pitch=18)
    art.detail(tail, "Tapering otter paddle", (0, 1.05, 1.57), (.61, .53, 1.55), fur, pitch=20)
    art.detail(tail, "Dark paddle tip", (.02, .86, 2.195), (.43, .36, .86), russet, pitch=10, yaw=4)


def build_expansion_visuals(visuals, *, item, part, prop, vector):
    """Emit native parts with anatomical pivots and bounded per-limb art."""
    adapters = dict(item=item, part=part, prop=prop, vector=vector)
    _build_frog(_FighterArt(visuals, "karate-frog", **adapters))
    _build_otter(_FighterArt(visuals, "river-otter", **adapters))
