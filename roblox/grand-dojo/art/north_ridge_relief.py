"""Contour relief for the four mountains on the north side of Grand Dojo."""
from bisect import bisect_right
from math import pi, sin

if __package__:
    from .valley_ridge_layout import cool_ridge_tone, rgb, ridge_facets, sun_on
else:
    from valley_ridge_layout import cool_ridge_tone, rgb, ridge_facets, sun_on


def _mix(a, b, weight):
    return tuple(v + weight * (w - v) for v, w in zip(a, b))


def _bracket(values, position):
    index = min(bisect_right(values, position) - 1, len(values) - 2)
    low, high = values[index:index + 2]
    return low, high, (position - low) / (high - low)


def _stitch(upper, lower):
    """Triangulate adjacent contours with different sample densities."""
    i = j = 0
    while i < len(upper) - 1 or j < len(lower) - 1:
        next_upper = upper[i + 1][1][0] if i < len(upper) - 1 else float('inf')
        next_lower = lower[j + 1][1][0] if j < len(lower) - 1 else float('inf')
        if next_upper < next_lower:
            yield upper[i], lower[j], upper[i + 1]
            i += 1
        else:
            yield upper[i], lower[j], lower[j + 1]
            j += 1


def north_ridge_facets(x, z, width, depth, profile, shadow, sunlight, haze, *, lower_detail=False):
    """Yield native or baked relief with continuous UVs and conserved summits."""
    original = {
        uv: point
        for face, uvs, _ in ridge_facets(x, z, width, depth, profile, shadow, sunlight, haze)
        for uv, point in zip(uvs, face)
    }
    row_axis = sorted({v for _, v in original})
    crest_axis = sorted(u for u, v in original if v == 0)
    summit = max(profile)
    distance = min(1, max(0, (-z - 275) / 480))
    near = z > -400
    bounds = [(min(axis), max(axis)) for axis in zip(*original.values())]
    toe_knots = {crest_axis[0], crest_axis[-1]}
    for coordinate in (0, 2):
        for pick in (min, max):
            toe_knots.add(pick(crest_axis, key=lambda u: original[u, 1][coordinate]))

    def ridge_height(u, v):
        left, right, span = _bracket(crest_axis, u)
        top, toe, fall = _bracket(row_axis, v)
        return _mix(_mix(original[left, top], original[right, top], span),
                    _mix(original[left, toe], original[right, toe], span), fall)

    def rolled_point(u, v, fold):
        px, py, pz = ridge_height(u, v)
        amplitude = sin(pi * v) * sin(pi * u) * min(1, max(0, py / 22))
        py += amplitude * summit * .049 * fold
        pz += amplitude * depth * .22 * fold
        return tuple(min(maximum, max(minimum, value))
                     for value, (minimum, maximum) in zip((px, py, pz), bounds))

    if lower_detail:
        bands = [(0, crest_axis), (1, crest_axis)]
        if near:
            bands.insert(1, (.44, crest_axis))
    else:
        edges = crest_axis[:-1]
        crest_kinks = [
            u + (.39 if i % 2 else .64) * (crest_axis[i + 1] - u)
            for i, u in enumerate(edges) if i % 3 != 0 and
            max(profile[i], profile[i + 1]) > .36 * summit
        ]
        shoulder_kinks = [
            u + (.29 if i % 2 else .61) * (crest_axis[i + 1] - u)
            for i, u in enumerate(edges) if i % 3 == 1
        ]
        bands = [
            (0, sorted(crest_axis + crest_kinks)),
            (.17 if near else .14, sorted(crest_axis + shoulder_kinks)),
            (.39, crest_axis),
            (.70, sorted(set(crest_axis[::2]) | {1.0})),
            (1, sorted(set(crest_axis[::3]) | toe_knots)),
        ]

    contours = []
    phase = x * .034 + z * .014
    for v, knots in bands:
        contour = []
        for u in knots:
            bend = .64 * sin(u * 39 + v * 6 + phase) + .36 * sin(u * 84 - v * 7 - phase)
            px, py, pz = rolled_point(u, v, bend)
            if v == 0 and u not in crest_axis:
                # A sawtooth edge at a few visible rock breaks, held by the old crest anchors.
                py = max(bounds[1][0], py - summit * (.010 + .008 * (1 + bend)))
            contour.append(((px, py, pz), (u, v)))
        contours.append(contour)

    dark, light, mist = map(rgb, (shadow, sunlight, haze))
    sunset = rgb("ECAFAB")
    for upper, lower in zip(contours, contours[1:]):
        for tri in _stitch(upper, lower):
            face, uvs = zip(*tri)
            u, v = (sum(axis) / 3 for axis in zip(*uvs))
            height = max(0, sum(p[1] for p in face) / (3 * summit))
            sunward = min(1, max(0, (sum(p[0] for p in face) / 3 - 35) / 260))
            strata = sin(38 * u + 21 * v + phase + 1.8 * sin(29 * u - 6 * v))
            light_weight = min(.86, max(.08, .29 + .31 * sun_on(face)
                                       + .22 * height + .066 * strata))
            mist_weight = .10 + .38 * distance + .25 * v * (1 - height) + .076 * sunward
            color = _mix(_mix(dark, light, light_weight), _mix(mist, sunset, .57 * sunward), mist_weight)
            yield face, uvs, cool_ridge_tone(tuple(round(channel) for channel in color), z)
