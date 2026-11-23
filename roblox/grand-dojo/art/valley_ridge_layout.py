"""Shared front-facing valley relief for the native place and the baked mesh."""
from math import hypot, pi, sin
from random import Random


VALLEY_RIDGES = (
    # The high range breaks into irregular summits above the Hall and Ring.
    # Its long saddle above Reedfall leaves room for the setting sun.
    (60.68, -754, 1801.36, 188,
     (9, 26, 42, 61, 87, 116, 159, 205, 249, 282, 321, 283, 302, 351, 384, 359, 311, 285,
      327, 302, 247, 199, 161, 135, 118, 106, 108, 126, 151, 188, 225, 253, 286, 306,
      350, 326, 307, 285, 319, 303, 282, 220, 119, 9),
     "79637F", "A4839B", "D5A0B0"),
    # A closer, cooler range shows below the far rim as the player nears the plaza.
    (-10.32, -443, 1127.36, 101,
     (5, 14, 23, 35, 53, 68, 88, 108, 126, 147, 142, 173, 194, 161, 135, 145, 167, 144, 121,
      115, 132, 153, 132, 104, 88, 76, 65, 48, 53, 59, 81, 101, 123, 129, 146, 132, 172,
      156, 189, 159, 128, 65, 4),
     "534865", "88758F", "B38FA2"),
    (-150, -338, 242, 44,
     (0, 8, 15, 25, 35, 46, 58, 73, 63, 76, 93, 78, 64, 49, 56, 47, 33, 18, 0),
     "4F4464", "7D6387", "9A7A98"),
    (130, -328, 231, 41,
     (0, 6, 12, 22, 28, 34, 32, 38, 44, 52, 47, 40, 51, 66, 77, 60, 43, 24, 0),
     "584567", "886387", "A77F99"),
)

SLOPE_BANDS = ((0, 1), (.20, .87), (.45, .65), (.72, .33), (1, 0))
DISTANT_BANDS = ((0, 1), (.26, .84), (.59, .49), (1, 0))


def rgb(tint):
    return tuple(int(tint[i:i+2], 16) for i in (0, 2, 4))


def cool_ridge_tone(tint, depth):
    """Keep the distant silhouette mauve as the plaza catches warm sun."""
    if depth < -600:
        factors = (.88, .93, 1.03)
    elif depth < -400:
        factors = (.91, .96, 1.04)
    else:
        factors = (.94, 1.05, 1.00)
    return tuple(min(255, round(channel * factor)) for channel, factor in zip(tint, factors))


def sun_on(face):
    a,b = (tuple(p-q for p,q in zip(end,face[0])) for end in face[1:])
    nx,ny,nz = (a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
    length = hypot(nx,ny,nz)
    return (.81*nx+.38*ny+.45*nz)*(-1 if nz<0 else 1)/max(.001, length)


def ridge_facets(x, z, width, depth, profile, shadow, sunlight, haze, *, lower_detail=False):
    """Yield triangles, strip UVs and time-of-day color for one ridge."""
    source = Random(int(x-z))
    steps = len(profile)-1
    spacing = width/steps
    summit = max(profile)
    distant = z < -400
    crest_depth = .075 if z < -600 else .145
    crest = [
        (x+(i-steps/2)*spacing+source.uniform(-.12,.12)*spacing, height,
         z+source.uniform(-crest_depth,crest_depth)*depth)
        for i, height in enumerate(profile)
    ]
    # Neighboring ribs share broad shoulders with smaller gullies between them.
    folds = [(source.uniform(-.19,.19)*spacing,
              .14*sin(i*.88+.42)+.074*sin(i*1.91+1.1)+source.uniform(-.054,.054),
              (.16*sin(i*.91+.27)+source.uniform(-.065,.065))*depth)
             for i in range(len(crest))]
    contours = []
    bands = DISTANT_BANDS if distant else SLOPE_BANDS
    if lower_detail:
        bands = (bands[0],bands[-1]) if distant else bands[::2]
    for progress, incline in bands:
        relief = sin(pi*progress)
        contours.append([
            (px+shift*progress+relief*.16*spacing*sin(i*.98+progress*5.1),
             py*incline*(1+fold*relief)-4.5*progress,
             pz+progress*(depth+reach)+fold*relief*depth*1.18)
            for i,((px,py,pz),(shift,fold,reach)) in enumerate(zip(crest,folds))
        ])

    dark, light, mist = map(rgb, (shadow, sunlight, haze))
    sunset = rgb("ECAFAB")
    distance = min(1, max(0, (-z-275)/480))
    for band,(upper,lower) in enumerate(zip(contours,contours[1:])):
        for i in range(steps):
            quad = upper[i],lower[i],lower[i+1],upper[i+1]
            first,last = bands[band][0],bands[band+1][0]
            uv = ((i/steps,first),(i/steps,last),((i+1)/steps,last),((i+1)/steps,first))
            triangles = ((0,1,2),(0,2,3)) if (i+band)%2 else ((0,1,3),(1,2,3))
            faces = [tuple(quad[j] for j in indices) for indices in triangles]
            illuminance = [sun_on(face) for face in faces]
            average = sum(illuminance)*.5
            height = max(0, sum(point[1] for point in quad)/(4*summit))
            sunward = max(0, min(1, (sum(point[0] for point in quad)/4-35)/260))
            haze_tint = tuple(a+(b-a)*.60*sunward for a,b in zip(mist,sunset))
            mist_weight = .09+.44*distance+.24*last*(1-height)+.08*sunward
            for indices,face,sun in zip(triangles,faces,illuminance):
                lit = .85*average+.15*sun
                light_weight = max(.07, min(.87, .25+.43*lit+.26*height))
                color = tuple(round((a+(b-a)*light_weight)*(1-mist_weight)+c*mist_weight)
                              for a,b,c in zip(dark,light,haze_tint))
                yield face,tuple(uv[j] for j in indices),cool_ridge_tone(color,z)
