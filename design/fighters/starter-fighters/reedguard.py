"""Reuse the original Reedguard festival shell as the alpha guard fighter."""


def build(p):
    pivots = dict(p.PIVOTS)
    p.make_fighter()
    return pivots
