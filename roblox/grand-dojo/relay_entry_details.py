"""Cedar millwork behind the Lantern Relay entrance marquee."""

from math import atan2, degrees, hypot


def build_relay_entry_depth(parent, *, center, profile, item, part, prop, beam,
                            roof_panel, wood, slate, metal):
    """Extend the gate overhead while keeping the entrance sightline open."""
    canopy = item(parent, "Model", "Relay gate rear eave")
    return_profile = profile[1:-1]

    # Follow the front arch over the two supporting posts. The title remains
    # the front face, with the stone-colored sill and cedar visible below it.
    courses = (
        ("Curved cedar soffit", -1.16, 29.62, .36, 2.48, "784435", wood),
        ("Deep lacquered eave fascia", -.49, 28.28, 1.08, .38, "8B4A38", wood),
        ("Smoked cedar eave return", .75, 29.15, 1.56, 1.94, "663C37", wood),
        ("Slate eave shadow course", 1.48, 28.26, .25, .44, "464457", slate),
        ("Brass rear fascia bead", -1.02, 28.05, .095, .11, "B78149", metal),
    )
    for (left, low), (right, high) in zip(return_profile, return_profile[1:]):
        width = hypot(right - left, high - low)
        slope = degrees(atan2(high - low, right - left))
        x = center + (left + right) / 2
        y = (low + high) / 2
        for name, rise, z, height, depth, tint, material in courses:
            part(canopy, name, (x, y + rise, z), (width + .045, height, depth), tint,
                 roll=slope, material=material, collide=False)
        roof_panel(canopy, "Indigo rear roof return", (x, y + 1.79, 29.27),
                   (width + .08, .34, 2.34), "3B4F7C", pitch=-10, roll=slope)

    # Set the exposed purlin ends back under the coping. They leave a clear
    # path through the portal and frame the smaller rounded gates beyond.
    for (left, low), (right, high) in zip(return_profile[::2], return_profile[1::2]):
        x = center + (left + right) / 2
        y = (low + high) / 2
        for direction in (-1, 1):
            px = x + direction * .40
            part(canopy, "Exposed cedar purlin end", (px, y - .83, 28.39),
                 (.24, .29, .71), "9E5D42", material=wood, collide=False)

    for side in (-1, 1):
        post = center + side * 9.41
        part(canopy, "Relay eave bearing block", (post, 10.36, 30.11),
             (1.17, .55, 1.51), "824733", material=wood, collide=False)
        part(canopy, "Stepped cedar bracket head", (center + side * 8.61, 10.97, 29.33),
             (1.40, .43, 1.56), "A35C3D", material=wood, collide=False)
        beam(canopy, "Diagonal cedar eave bracket", (post, 9.56, 30.60),
             (center + side * 7.71, 11.48, 28.52), .57, "8C513C", collide=False)
        part(canopy, "Aged bronze bracket pin", (center + side * 9.05, 10.39, 29.33),
             (.21, .19, .18), "B48049", material=metal, collide=False)

    for piece in canopy.findall("Item"):
        prop(piece, "bool", "CastShadow", False)


def build_relay_lantern_canopy(parent, *, center, item, part, prop, beam,
                              festival_lantern, wood, metal):
    """Show two receding rows of paper lanterns through the plaza gate."""
    canopy = item(parent,"Model","Relay entrance lantern canopy")
    prop(canopy,"token","LevelOfDetail",4)
    # Both cedar bars sit behind the marquee between its lit front fixtures
    # and the first checkpoint. The second bar hangs from short purlins.
    for x_shift,z,bar_y,width,lamps in (
        (-.48,28.51,10.28,13.84,((-5.23,.57),(-2.64,.64),(0,.80),(2.64,.64),(5.23,.57))),
        (-1.58,26.24,9.92,11.64,((-3.95,.50),(0,.62),(3.95,.50))),
    ):
        x = center + x_shift
        part(canopy,"Cedar lantern canopy tie",(x,bar_y,z),(width,.28,.32),"845044",
             material=wood,collide=False)
        for offset in (-width*.46,width*.46):
            part(canopy,"Bronze canopy tie sleeve",(x+offset,bar_y,z),(.26,.35,.42),"AF8055",
                 material=metal,collide=False)
            beam(canopy,"Cedar lantern purlin",(x+offset,bar_y,z),(x+offset+.31,11.46,28.61),
                 .19,"83513F",collide=False)
        for index,(offset,scale) in enumerate(lamps):
            lantern_y = bar_y - 1.04 - (.16 if offset==0 else 0)
            beam(canopy,"Braided lantern hanger",(x+offset,bar_y-.13,z),
                 (x+offset,lantern_y+scale*.98,z),.066,"A47045",collide=False)
            festival_lantern(canopy,x+offset,lantern_y,z,scale,light=False,
                             tint=("FFC47E","FFCC89","FFD294","FFCC89","FFC47E")[index])
    for piece in canopy.findall("Item"):
        shadow=piece.find("Properties/bool[@name='CastShadow']")
        if shadow is None:
            prop(piece,"bool","CastShadow",False)
