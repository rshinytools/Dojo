"""Warm paving from the plaza through the fourth Lantern Relay gate."""

from math import ceil, hypot


# Keep the runner west of the event board and join the centers of the bends.
# Taper the far end to keep both borders on the existing sandstone tiles.
RELAY_RUNNER = (
    (-37.60, 41.35, 3.47), (-39.05, 36.20, 3.47), (-38.30, 31.30, 3.47),
    (-42.00, 22.00, 3.47), (-43.56, 14.20, 3.47), (-45.00, 7.00, 3.47),
    (-46.52, 5.80, 3.47), (-59.00, -4.00, 3.18), (-63.00, -20.00, 2.80),
    (-62.51, -22.20, 2.80),
)


def interpolate(a, b, fraction):
    return tuple(u+(v-u)*fraction for u,v in zip(a,b))


def build_relay_runner(parent, *, item, prop, triangle, path_edge, slate, limestone,
                       stone_variant, slate_variant, variant_field):
    runner=item(parent,"Model","Lantern Relay sandstone runner")
    prop(runner,"token","ModelStreamingMode",1)
    prop(runner,"token","LevelOfDetail",4)

    def plate(a,b,c,d,label,tint,material,variant):
        first=len(runner)
        for face in ((a,b,c),(a,c,d)):
            triangle(runner,*face,tint,name=label,material=material,thickness=.050,shadow=False)
        for wedge in runner[first:]:
            prop(wedge,"string",variant_field,variant)

    path=[(x,.165,z) for x,z,_ in RELAY_RUNNER]
    west,east=([
        interpolate(center,edge,half_width)
        for center,edge,(_,_,half_width) in zip(path,path_edge(path,side),RELAY_RUNNER)
    ] for side in (-1,1))
    rose=("B99582","C7A08A","BE9783","CAA590","B69387","C19B88")
    row_index=0
    for index,(left,following_left,right,following_right) in enumerate(zip(west,west[1:],east,east[1:])):
        start,finish=path[index:index+2]
        rows=ceil(hypot(finish[0]-start[0],finish[2]-start[2])/2.50)

        def point(t,across):
            return interpolate(interpolate(left,following_left,t),
                               interpolate(right,following_right,t),across)

        for lower,upper in ((0,.053),(.947,1)):
            plate(point(0,lower),point(1,lower),point(1,upper),point(0,upper),
                  "Relay runner slate border","8E746D",slate,slate_variant)
        for row in range(rows):
            front,back=(row+.008)/rows,(row+.992)/rows
            joints=(.058,.345,.642,.942) if row_index%2==0 else (.058,.238,.531,.814,.942)
            for column,(lower,upper) in enumerate(zip(joints,joints[1:])):
                a,b=lower+.002,upper-.002
                tint=rose[(row_index*3+column*2)%len(rose)]
                plate(point(front,a),point(back,a),point(back,b),point(front,b),
                      "Warm Relay sandstone flagstone",tint,limestone,stone_variant)
            row_index+=1
