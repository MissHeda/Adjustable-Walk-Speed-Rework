"""Draws the six autorun indicator frames: a soldier running with a rifle, side on.

Flat white silhouette on transparency, the way Arma's own HUD figures are drawn. Rendered at 4x
and downsampled, which is what gives the edges their anti-aliasing - a .paa carries no vector
data, so the smoothing has to be baked in.
"""
import math
from PIL import Image, ImageDraw

SS = 4                 # supersample factor
SIZE = 512
W = SIZE * SS
WHITE = (255, 255, 255, 255)

HIP = (250.0, 288.0)
LEAN = 14.0            # the whole upper body pitches into the run


def rot(p, origin, deg):
    a = math.radians(deg)
    dx, dy = p[0] - origin[0], p[1] - origin[1]
    return (origin[0] + dx * math.cos(a) - dy * math.sin(a),
            origin[1] + dx * math.sin(a) + dy * math.cos(a))


def limb(d, p0, p1, r0, r1):
    """A tapered capsule: two circles and the quad between them."""
    dx, dy = p1[0] - p0[0], p1[1] - p0[1]
    ln = math.hypot(dx, dy) or 1
    nx, ny = -dy / ln, dx / ln
    d.polygon([(p0[0] + nx * r0, p0[1] + ny * r0),
               (p1[0] + nx * r1, p1[1] + ny * r1),
               (p1[0] - nx * r1, p1[1] - ny * r1),
               (p0[0] - nx * r0, p0[1] - ny * r0)], fill=WHITE)
    d.ellipse([p0[0] - r0, p0[1] - r0, p0[0] + r0, p0[1] + r0], fill=WHITE)
    d.ellipse([p1[0] - r1, p1[1] - r1, p1[0] + r1, p1[1] + r1], fill=WHITE)


def joint(d, p, r):
    d.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=WHITE)


# One run cycle. Per frame, per leg: thigh angle from straight down (positive swings forward)
# and how far the knee is folded. A run is symmetric, so the second half is the first with the
# legs swapped rather than three more poses to keep in step.
HALF = [
    ((  42,  22), ( -34,  26)),   # contact: front foot reaching, back leg trailing straight
    ((   8,  14), ( -22, 104)),   # support: passing under the body, trailing knee folding up
    (( -30,  24), (  52,  96)),   # drive: pushing off behind, the other knee coming through
]
CYCLE = HALF + [(b, a) for (a, b) in HALF]

# Lowest at contact, highest in the drive - the head should not sit on a rail.
BOB = [8, 0, -10, 8, 0, -10]

THIGH, SHIN, FOOT = 96.0, 92.0, 38.0


def draw_frame(i):
    img = Image.new("RGBA", (int(W * 1.5), int(W * 1.5)), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = W / 512.0
    ox = 0.0

    def P(x, y):                      # a point in the pelvis frame
        return (ox + x * s, (y + BOB[i]) * s)

    def U(x, y):                      # a point on the leaning upper body
        return P(*rot((x, y), HIP, LEAN))

    hip = P(*HIP)

    # --- legs, far one first so the near leg reads in front ----------------
    for (thigh, bend), thick in zip(CYCLE[i][::-1], (24, 27)):
        knee = rot((hip[0], hip[1] + THIGH * s), hip, thigh)
        ankle = rot((knee[0], knee[1] + SHIN * s), knee, thigh - bend)
        toe = rot((ankle[0], ankle[1] + FOOT * s), ankle, thigh - bend + 82)

        limb(d, hip, knee, thick * s, (thick - 5) * s)
        limb(d, knee, ankle, (thick - 6) * s, (thick - 12) * s)
        limb(d, ankle, toe, (thick - 13) * s, (thick - 17) * s)

    # --- pack, behind the torso -------------------------------------------
    d.polygon([U(226, 186), U(244, 180), U(240, 268), U(196, 256), U(200, 200)], fill=WHITE)

    # --- torso -------------------------------------------------------------
    d.polygon([U(220, 294), U(280, 292), U(296, 200), U(288, 156),
               U(226, 154), U(212, 202)], fill=WHITE)
    joint(d, U(250, 288), 30 * s)
    joint(d, U(256, 176), 40 * s)
    joint(d, U(250, 268), 34 * s)

    # --- head and helmet ---------------------------------------------------
    joint(d, U(262, 116), 32 * s)
    d.pieslice([U(226, 68)[0], U(226, 68)[1], U(302, 130)[0], U(302, 130)[1]], 180, 360, fill=WHITE)
    d.polygon([U(230, 98), U(300, 98), U(300, 112), U(228, 114)], fill=WHITE)
    limb(d, U(254, 158), U(262, 128), 21 * s, 24 * s)

    # --- rifle, carried across the body ------------------------------------
    d.polygon([U(226, 250), U(352, 210), U(359, 232), U(231, 266)], fill=WHITE)   # body + barrel
    d.polygon([U(286, 232), U(304, 226), U(297, 268), U(281, 262)], fill=WHITE)   # magazine
    d.polygon([U(226, 244), U(248, 238), U(252, 258), U(230, 266)], fill=WHITE)   # stock

    # --- arms: far arm forward on the handguard, near arm on the grip -------
    limb(d, U(250, 184), U(244, 240), 19 * s, 16 * s)
    limb(d, U(244, 240), U(318, 224), 16 * s, 13 * s)
    limb(d, U(262, 180), U(252, 236), 22 * s, 18 * s)
    limb(d, U(252, 236), U(286, 244), 18 * s, 14 * s)

    return img


if __name__ == "__main__":
    import sys
    out = sys.argv[1] if len(sys.argv) > 1 else "."
    raw = [draw_frame(i) for i in range(6)]

    # One transform for all six, from the union of their outlines, so the figure keeps its
    # place in the frame instead of jumping about as the pose changes.
    boxes = [f.getbbox() for f in raw]
    x0 = min(b[0] for b in boxes); y0 = min(b[1] for b in boxes)
    x1 = max(b[2] for b in boxes); y1 = max(b[3] for b in boxes)

    margin = 0.06
    span = max(x1 - x0, y1 - y0) / (1 - 2 * margin)
    cx, cy = (x0 + x1) / 2.0, (y0 + y1) / 2.0
    box = (cx - span / 2, cy - span / 2, cx + span / 2, cy + span / 2)

    frames = [f.resize((SIZE, SIZE), Image.LANCZOS, box) for f in raw]
    for i, f in enumerate(frames):
        f.save("%s/run_%02d.png" % (out, i + 1))

    sheet = Image.new("RGBA", (SIZE * 6, SIZE), (30, 30, 34, 255))
    for i, f in enumerate(frames):
        sheet.alpha_composite(f, (i * SIZE, 0))
    sheet.resize((SIZE * 3, SIZE // 2), Image.LANCZOS).convert("RGB").save("%s/sheet_new.png" % out)
    print("wrote 6 frames")
