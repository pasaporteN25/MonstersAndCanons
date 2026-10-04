"""Generate the remaining 3D-style tower sprites and small HUD emblems.

SVG keeps every silhouette crisp in Godot's 2x import and makes the lighting
direction consistent with the approved cannon and bases.
"""

from pathlib import Path
import xml.etree.ElementTree as ET
from shutil import copyfile

ROOT = Path(__file__).resolve().parents[3]
TOWERS = ROOT / "assets/sprites/towers"
UI = ROOT / "assets/sprites/ui"
EFFECTS = ROOT / "assets/sprites/effects"
UI.mkdir(parents=True, exist_ok=True)


def save(folder: Path, name: str, body: str, defs: str = "", size: int = 64) -> None:
    if name.startswith("turret_"):
        description = "Torreta con volumen, vista superior y orientada a la derecha; fondo transparente."
    elif name.startswith("stat_"):
        description = "Icono con relieve para la barra superior; fondo transparente."
    else:
        description = "Llama de quemadura con facetas y nucleo brillante; fondo transparente."
    source = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 {size} {size}">
<!-- {description} -->
<defs>{defs}</defs><g stroke-linejoin="round" stroke-linecap="round">{body}</g></svg>\n'''
    ET.fromstring(source)
    (folder / name).write_text(source, encoding="utf-8")


def poly(pts: str, color: str, stroke: str = "#253442", width: float = 1.6) -> str:
    return f'<polygon points="{pts}" fill="{color}" stroke="{stroke}" stroke-width="{width}"/>'


def path(d: str, color: str, stroke: str = "#253442", width: float = 1.6) -> str:
    return f'<path d="{d}" fill="{color}" stroke="{stroke}" stroke-width="{width}"/>'


def circle(x: float, y: float, r: float, color: str, stroke: str = "#253442", width: float = 1.5) -> str:
    return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{color}" stroke="{stroke}" stroke-width="{width}"/>'


def line(d: str, color: str, width: float = 1.4) -> str:
    return path(d, "none", color, width)


METAL = '''<linearGradient id="metal" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#d9ded7"/><stop offset=".4" stop-color="#8495a0"/><stop offset="1" stop-color="#3b4a59"/></linearGradient>
<linearGradient id="gun" x1="0" y1="0" x2="0" y2="1"><stop stop-color="#e0e5dd"/><stop offset=".38" stop-color="#879aa4"/><stop offset="1" stop-color="#364754"/></linearGradient>
<linearGradient id="gold" x1="0" y1="0" x2=".4" y2="1"><stop stop-color="#fff1b5"/><stop offset=".52" stop-color="#d4a550"/><stop offset="1" stop-color="#835b32"/></linearGradient>'''


def shell(top: str, shade: str, rim: str = "#263745") -> str:
    """Raised octagonal housing: visible front wall, top plane, upper hatch."""
    return (poly("19,23 31,19 43,23 49,32 44,45 32,51 19,46 13,36", "#1c2936")
            + poly("16,29 21,38 31,43 41,39 46,29 49,33 44,44 32,49 19,44 13,35", rim)
            + poly("19,37 31,43 31,48 19,43", "#374a57", "none", 0)
            + poly("31,43 41,39 46,29 48,34 43,44 31,48", "#1b2b38", "none", 0)
            + poly("20,18 31,14 42,18 47,27 42,38 31,43 20,38 15,28", rim)
            + poly("21,19 31,15 41,19 45,27 40,36 31,40 21,35 17,28", top, rim, .8)
            + poly("21,19 31,15 40,19 42,23 32,22 23,25 18,28", shade, "none", 0)
            + poly("40,30 40,36 31,40 31,35 36,28", rim, "none", 0)
            + circle(31, 32, 9.4, rim, rim, 1)
            + path("M22 28 Q31 22 40 28 L40 33 Q31 28 22 33Z", "#526675", "none", 0)
            + circle(31, 28, 8.2, shade, rim, 1.4)
            + path("M25 25 Q30 21 35 24", "none", "#fff7df", 1.4)
            + circle(20, 29, 1.5, "url(#gold)", "#645747", .6)
            + circle(42, 29, 1.5, "url(#gold)", "#645747", .6))


def raised_barrel(y: float, color: str = "url(#gun)") -> str:
    """A small tube with an exposed lower wall and deep, dark muzzle."""
    return (poly(f"34,{y+2} 55,{y} 60,{y+2} 61,{y+11} 55,{y+13} 34,{y+11}", "#1b2a38")
            + poly(f"35,{y+2} 55,{y+1} 58,{y+3} 58,{y+7} 35,{y+8}", color)
            + poly(f"35,{y+8} 58,{y+7} 58,{y+11} 35,{y+10}", "#3b4c5b", "none", 0)
            + poly(f"38,{y+2} 53,{y+1} 56,{y+3} 54,{y+4} 38,{y+5}", "#e0e7df", "none", 0)
            + poly(f"55,{y+1} 60,{y+2} 61,{y+11} 55,{y+12}", "url(#gold)")
            + poly(f"57,{y+4} 61,{y+4} 61,{y+9} 57,{y+9}", "#172532", "none", 0))


# Twin-barrel starter tower: two separate lit steel tubes and a recessed mount.
basic = (poly("10,26 18,22 23,25 23,42 18,46 10,42", "#273a48")
         + poly("11,25 18,22 21,25 21,38 18,41 11,39", "url(#metal)")
         + poly("11,39 18,41 21,38 21,43 18,46 11,43", "#344858", "none", 0)
         + raised_barrel(18)
         + raised_barrel(32)
         + shell("url(#metal)", "#c6d4d2")
         + poly("26,24 32,21 38,24 39,30 32,36 25,33", "#536a79")
         + poly("27,24 32,22 37,24 33,27 27,27", "#e9ece1", "none", 0)
         + line("M27 33 32 36 37 32", "#314757"))
save(TOWERS, "turret_basic.svg", basic, METAL)


# Heavy cannon: the approved C silhouette, with a taller armored carriage and
# a clearly visible underside to the barrel and bronze muzzle.
cannon = (poly("14,27 21,22 25,26 25,40 19,46 14,41", "#354757")
          + poly("15,26 20,23 22,26 22,36 19,40 15,38", "url(#metal)")
          + poly("15,38 19,40 22,36 22,42 19,46 15,42", "#263848", "none", 0)
          + poly("31,25 51,22 56,19 61,21 63,43 56,47 51,42 31,42", "#182a39")
          + poly("34,24 52,22 55,24 55,34 34,36", "url(#gun)")
          + poly("35,35 55,33 55,41 34,41", "#344b5c", "none", 0)
          + poly("38,24 51,22 54,24 51,27 38,29", "#e4e9dd", "none", 0)
          + poly("51,22 56,19 61,21 63,43 56,47 51,42", "#9f7945")
          + poly("54,23 59,21 61,24 61,41 55,44", "url(#gold)", "#6a533b", .8)
          + poly("57,27 61,26 62,39 57,40", "#1b2c3a", "none", 0)
          + poly("58,29 61,28 61,37 58,38", "#34404b", "none", 0)
          + shell("url(#metal)", "#dce3da")
          + poly("23,25 29,21 36,22 41,27 39,33 31,38 23,34", "#34495a")
          + poly("24,25 30,22 36,23 39,27 31,29 24,29", "#e5eadd", "none", 0)
          + poly("31,29 39,27 38,33 31,37", "#576d7c", "none", 0)
          + line("M23 34 31 38 38 34", "#243848", 1.5))
save(TOWERS, "turret_cannon.svg", cannon, METAL)


# Frost projector: iced lance and angular coolant fins mounted on the same
# raised chassis; facets of the crystal show light, middle and underside.
frost_defs = METAL + '''<linearGradient id="ice_shell" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#e9ffff"/><stop offset=".45" stop-color="#75bed4"/><stop offset="1" stop-color="#315f85"/></linearGradient>
<linearGradient id="ice" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#ffffff"/><stop offset=".42" stop-color="#b9f4fa"/><stop offset="1" stop-color="#5ba9db"/></linearGradient>'''
frost = (poly("10,27 19,21 26,25 26,40 18,46 10,41", "#2a5470")
         + poly("12,26 19,22 23,26 23,37 19,41 12,39", "url(#ice_shell)")
         + poly("12,39 19,41 23,37 23,42 18,46 12,42", "#2c5269", "none", 0)
         + poly("31,25 47,9 51,12 46,28", "#2d7295")
         + poly("35,24 47,13 48,14 43,26", "#e3ffff", "none", 0)
         + poly("31,37 47,52 51,49 46,34", "#245b7e")
         + poly("36,37 47,47 46,41", "#91d7e4", "none", 0)
         + poly("36,25 55,27 63,31 63,34 55,39 36,40", "#245b79")
         + poly("39,25 56,28 62,31 39,31", "#e8ffff", "none", 0)
         + poly("39,31 62,31 60,34 39,34", "#93dcea", "none", 0)
         + poly("39,34 60,34 55,38 39,39", "#4c9fca", "none", 0)
         + shell("url(#ice_shell)", "#d8f9f7", "#26495e")
         + poly("22,25 31,19 40,24 42,31 33,38 24,34", "#356b8b")
         + poly("24,25 31,20 39,24 31,28 24,29", "url(#ice)", "none", 0)
         + poly("31,28 39,24 41,30 33,36 31,35", "#6ab8da", "none", 0)
         + poly("24,29 31,28 31,35 25,33", "#b3eef3", "none", 0)
         + line("M26 25 31 21 36 24", "#ffffff", 1.4))
save(TOWERS, "turret_frost.svg", frost, frost_defs)


# Long, narrow green rifle, scope and rear stock stay readable at 34 px in HUD.
green_defs = METAL + '''<linearGradient id="green" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#b4cba6"/><stop offset=".42" stop-color="#66856b"/><stop offset="1" stop-color="#314e4b"/></linearGradient>'''
sniper = (poly("10,26 21,22 24,27 24,38 19,42 10,38", "#345044")
          + poly("11,26 19,23 21,26 21,37 19,39 11,37", "url(#green)")
          + poly("31,27 56,24 61,27 62,37 56,39 31,37", "#233c40")
          + poly("34,27 56,25 58,27 58,31 34,33", "#8cae9e")
          + poly("34,33 58,31 58,37 34,36", "#355c56", "none", 0)
          + poly("36,27 54,25 56,27 36,29", "#dce6d1", "none", 0)
          + poly("56,24 61,26 62,37 56,39", "url(#gold)")
          + poly("59,29 62,29 62,35 59,35", "#14282f", "none", 0)
          + poly("27,19 43,17 48,21 46,27 30,28 27,25", "#253f43")
          + poly("30,19 43,18 46,20 45,23 30,24", "url(#green)")
          + poly("30,24 45,23 46,26 30,27", "#2c514d", "none", 0)
          + circle(36, 21, 2.6, "#8ac4c4", "#27444a", .8)
          + shell("url(#green)", "#bdd5b3", "#253e3b")
          + poly("25,25 31,21 37,25 35,33 27,34", "#425e55")
          + poly("26,25 31,22 35,25 31,28", "#dce5c7", "none", 0)
          + line("M22 37 31 41 38 36", "#405c52"))
save(TOWERS, "turret_sniper.svg", sniper, green_defs)


# Fire projector: rear copper tank, ridged heated nozzle, flame-shaped core.
fire_defs = METAL + '''<linearGradient id="copper" x1="0" y1="0" x2=".8" y2="1"><stop stop-color="#ffd18a"/><stop offset=".42" stop-color="#d9763d"/><stop offset="1" stop-color="#783b35"/></linearGradient>
<linearGradient id="ember" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#fff9ca"/><stop offset=".55" stop-color="#ffba42"/><stop offset="1" stop-color="#dc4b24"/></linearGradient>'''
fire = (poly("8,24 13,20 21,22 23,27 23,39 18,43 10,40 8,36", "#673b34")
        + poly("10,24 14,21 20,23 20,39 16,41 10,38", "url(#copper)")
        + poly("10,38 16,41 20,39 20,44 16,46 10,42", "#783b35", "none", 0)
        + line("M13 24 13 38 M17 23 17 39", "#ffe0a0", 1.2)
        + poly("33,25 51,23 56,19 61,22 62,44 56,47 51,42 33,40", "#3c4246")
        + poly("37,25 52,24 54,27 54,36 37,37", "url(#copper)")
        + poly("37,37 54,36 54,41 37,40", "#7d3f36", "none", 0)
        + poly("39,25 51,24 53,27 51,29 39,29", "#ffe1a3", "none", 0)
        + poly("51,23 56,19 61,22 62,44 56,47 51,42", "url(#gold)")
        + poly("56,25 61,24 61,42 56,44", "#412c2e")
        + poly("58,28 62,28 62,39 58,40", "#1f2730", "none", 0)
        + shell("url(#copper)", "#ffe0a0", "#563a38")
        + path("M31 22 C27 26 27 30 30 34 C28 29 33 28 33 23 C37 29 38 32 33 35 C40 32 40 26 31 22Z", "url(#ember)", "#8f412b", .9)
        + circle(32, 31, 2.5, "#fff9d4", "none", 0))
save(TOWERS, "turret_fire.svg", fire, fire_defs)


# Three offset barrels make the spread silhouette immediately distinct.
blue_defs = METAL + '''<linearGradient id="blue" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#d5d9f2"/><stop offset=".42" stop-color="#8197bd"/><stop offset="1" stop-color="#3d5279"/></linearGradient>'''
multi = poly("12,25 19,21 23,25 23,39 18,43 12,39", "url(#blue)")
for angle in (-24, 24):
    multi += f'<g transform="rotate({angle} 32 32)">' + raised_barrel(26, "url(#blue)") + '</g>'
multi += (raised_barrel(26, "url(#blue)")
          + shell("url(#blue)", "#dde2f3")
          + poly("26,24 31,21 37,24 39,29 34,35 27,33", "#4e6188")
          + poly("27,24 31,22 36,24 32,27 27,27", "#e8eeff", "none", 0))
save(TOWERS, "turret_multi.svg", multi, blue_defs)


# Radial burst: faceted metal darts around a raised crimson flywheel.
red_defs = METAL + '''<linearGradient id="red" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#ffc4b3"/><stop offset=".4" stop-color="#c86370"/><stop offset="1" stop-color="#692e4b"/></linearGradient>'''
burst = circle(32, 40, 18, "#272b39")
for angle in range(0, 360, 45):
    burst += f'<g transform="rotate({angle} 32 32)">' + poly("42,28 57,32 42,36 43,32", "#374453") + poly("43,28 56,32 43,31", "#e0c6aa", "none", 0) + '</g>'
burst += (circle(32, 36, 18, "#344051")
          + path("M14 34 A18 18 0 0 0 50 34 L50 39 A18 18 0 0 1 14 39Z", "#202d3d", "none", 0)
          + circle(32, 30, 17, "url(#metal)")
          + circle(32, 29, 13, "url(#red)", "#4c3245", 1.6)
          + path("M21 25 Q30 16 40 22", "none", "#ffe5d6", 1.7)
          + circle(32, 33, 8, "#732e49", "#442c42", 1.5)
          + circle(32, 29, 8, "#ac4c65", "#442c42", 1.1)
          + poly("29,24 35,24 38,29 34,34 29,34 26,29", "url(#gold)")
          + circle(32, 29, 2.8, "#fff0ba", "#7a563a", .8))
save(TOWERS, "turret_burst.svg", burst, red_defs)


# Tesla: dark insulated housing, copper coils, two prongs and luminous orb.
tesla_defs = METAL + '''<linearGradient id="coil" x1="0" y1="0" x2=".6" y2="1"><stop stop-color="#fff7bf"/><stop offset=".45" stop-color="#e6bd54"/><stop offset="1" stop-color="#986136"/></linearGradient>
<radialGradient id="plasma" cx=".35" cy=".28" r=".72"><stop stop-color="#ffffff"/><stop offset=".35" stop-color="#fff4ad"/><stop offset="1" stop-color="#e7a744"/></radialGradient>'''
tesla = (poly("34,24 51,17 57,21 57,26 39,31", "url(#metal)")
         + poly("34,40 51,47 57,43 57,38 39,33", "#455361")
         + poly("49,18 54,14 60,20 57,24", "url(#coil)")
         + poly("49,46 54,50 60,44 57,40", "url(#coil)")
         + shell("url(#metal)", "#bdc9ce")
         + circle(31, 33, 11, "#2b3848", "#263442", 1)
         + circle(31, 27, 11, "#384957", "#263442", 1)
         + circle(31, 27, 9, "none", "url(#coil)", 3)
         + circle(31, 27, 5, "url(#plasma)", "#775d42", 1)
         + circle(56, 37, 7, "#9a7447", "#263442", 1.3)
         + circle(56, 31, 7, "url(#plasma)", "#625a4b", 1.8)
         + circle(54, 29, 2.4, "#ffffff", "none", 0)
         + line("M45 28 49 31 46 33 51 37", "#fff4a7", 1.7))
save(TOWERS, "turret_tesla.svg", tesla, tesla_defs)


# Large mortar: sturdy circular turntable and a deep elliptical bore.
brown_defs = METAL + '''<linearGradient id="bronze" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#f2d4a0"/><stop offset=".45" stop-color="#aa8150"/><stop offset="1" stop-color="#534336"/></linearGradient>'''
mortar = (circle(32, 41, 23, "#242c38")
          + path("M9 33 A23 23 0 0 0 55 33 L55 41 A23 23 0 0 1 9 41Z", "#344657", "none", 0)
          + circle(32, 30, 23, "url(#metal)")
          + circle(32, 29, 19, "#4b5a61", "#283643", 1.4)
          + path("M16 21 Q32 11 48 20", "none", "#edf0de", 2)
          + poly("20,24 27,19 46,20 54,25 54,42 47,48 25,47 19,41", "#453e3b")
          + poly("21,23 28,19 45,20 53,25 53,36 46,41 26,40 21,36", "url(#bronze)")
          + poly("22,24 28,20 44,21 49,24 43,27 26,28", "#ffdea5", "none", 0)
          + poly("21,36 26,40 46,41 53,36 53,42 46,47 25,46 20,41", "#684a37", "none", 0)
          + poly("47,21 54,18 60,21 61,46 54,49 47,44", "url(#gold)")
          + poly("53,23 58,23 59,44 53,45", "#3a3233")
          + '<ellipse cx="58" cy="33" rx="3.2" ry="9.5" fill="#172630"/>'
          + '<ellipse cx="58.4" cy="33" rx="1.2" ry="6" fill="#39434b"/>'
          + circle(32, 31, 5, "url(#metal)", "#35434b", 1.3)
          + circle(16, 31, 1.8, "url(#gold)", "#34434b", .7)
          + circle(32, 13, 1.8, "url(#gold)", "#34434b", .7)
          + circle(32, 49, 1.8, "url(#gold)", "#34434b", .7))
save(TOWERS, "turret_mortar.svg", mortar, brown_defs)


# Four legible emblems for the 48 px top bar, all with the same dark edge and light.
gold = (path("M14 43 Q14 52 32 53 Q50 52 50 43 L50 35 14 35Z", "#986730")
        + '<ellipse cx="32" cy="36" rx="18" ry="8" fill="url(#gold)" stroke="#694c32" stroke-width="2"/>'
        + line("M16 43 Q32 51 48 43", "#ffe19a", 1.5)
        + path("M12 29 Q12 38 30 39 Q48 38 48 29 L48 22 12 22Z", "#ac7130")
        + '<ellipse cx="30" cy="23" rx="18" ry="8" fill="url(#gold)" stroke="#684632" stroke-width="2"/>'
        + '<ellipse cx="30" cy="22" rx="11" ry="4" fill="#ffeeb0" opacity=".55"/>'
        + line("M14 30 Q29 37 46 30", "#ffe6a0", 1.4))
save(UI, "stat_gold.svg", gold, METAL)

heart_defs = '''<linearGradient id="heart" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#ffc2aa"/><stop offset=".4" stop-color="#f36a72"/><stop offset="1" stop-color="#a32748"/></linearGradient>'''
heart = (path("M32 51 C20 42 10 35 10 24 C10 14 21 10 32 19 C43 10 54 14 54 24 C54 35 44 42 32 51Z", "#7c2d47")
         + path("M32 46 C21 38 13 31 13 23 C13 16 22 13 32 22 C42 13 51 16 51 23 C51 31 43 38 32 46Z", "url(#heart)")
         + path("M17 23 C18 17 24 17 28 21", "none", "#ffe7d2", 2.7)
         + path("M41 19 Q49 23 45 30", "none", "#b94154", 2))
save(UI, "stat_lives.svg", heart, heart_defs)

score_defs = METAL + '''<linearGradient id="gem" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#eefeff"/><stop offset=".42" stop-color="#86d4ed"/><stop offset="1" stop-color="#3982bb"/></linearGradient>'''
score = (poly("32,6 54,19 55,42 32,57 9,42 10,19", "#244e78")
         + poly("32,8 52,20 52,40 32,54 12,40 12,20", "url(#gem)")
         + poly("12,20 32,8 52,20 32,29", "#d7fbff", "none", 0)
         + poly("12,20 32,29 32,54 12,40", "#83cde5", "none", 0)
         + poly("52,20 32,29 32,54 52,40", "#428dbb", "none", 0)
         + poly("32,16 36,25 46,27 38,34 39,44 32,39 25,44 26,34 18,27 28,25", "#f5fdff", "#5c9cca", 1)
         + line("M16 20 31 11", "#ffffff", 1.6))
save(UI, "stat_points.svg", score, score_defs)

wave_defs = METAL + '''<linearGradient id="banner" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#ffffff"/><stop offset=".48" stop-color="#b5cbd4"/><stop offset="1" stop-color="#586d81"/></linearGradient>'''
wave = (poly("16,15 50,15 46,31 50,45 16,45 20,31", "#34485b")
        + poly("19,17 47,17 43,31 47,43 19,43 23,31", "url(#banner)")
        + poly("23,19 43,19 40,28 25,28", "#effcff", "none", 0)
        + poly("23,32 42,32 45,41 21,41", "#7996aa", "none", 0)
        + poly("7,15 15,11 15,50 7,54", "url(#gold)")
        + poly("5,10 18,10 20,15 4,15", "url(#gold)")
        + poly("4,49 20,49 18,54 5,54", "url(#gold)")
        + poly("29,22 39,31 29,39", "#e2a854", "#75614c", 1.1)
        + poly("30,23 37,30 30,29", "#fff2bc", "none", 0))
save(UI, "stat_wave.svg", wave, wave_defs)

flame_defs = '''<linearGradient id="outer" x1="0" y1="0" x2=".8" y2="1"><stop stop-color="#ffe38a"/><stop offset=".32" stop-color="#ff9938"/><stop offset="1" stop-color="#b83325"/></linearGradient>
<linearGradient id="inner" x1="0" y1="0" x2=".5" y2="1"><stop stop-color="#fffef2"/><stop offset=".55" stop-color="#ffe36c"/><stop offset="1" stop-color="#ffaf35"/></linearGradient>'''
flame = (path("M16 1 C12 7 11 11 9 14 C8 11 7 9 7 8 C4 17 5 24 9 28 C12 31 20 32 24 27 C28 22 26 15 21 10 C21 15 19 16 18 17 C20 11 19 6 16 1Z", "#8e2d24", "none", 0)
         + path("M16 3 C11 11 11 16 8 18 C7 16 7 14 7 12 C5 20 8 27 13 29 L16 30 C12 23 15 16 16 10 C18 15 18 17 17 20 C22 16 22 14 21 12 C26 21 23 28 17 30 C26 29 29 19 21 11 C21 17 18 18 18 18 C20 11 18 6 16 3Z", "url(#outer)", "none", 0)
         + path("M15 17 C11 22 11 26 14 29 C15 30 18 30 20 28 C22 25 19 22 18 20 C18 24 16 25 16 25 C17 22 16 19 15 17Z", "url(#inner)", "none", 0)
         + line("M12 19 C10 23 11 26 13 28", "#ffd376", 1.3)
         + path("M16 22 C14 25 14 27 16 29 C18 29 19 27 18 25 C17 26 16 26 16 22Z", "#fffef3", "none", 0))
save(EFFECTS, "flame.svg", flame, flame_defs, 32)

preview_sources = Path(__file__).resolve().parent
for source_name, target_name in (
    ("b_base_1.svg", "base_1.svg"),
    ("c_base_2.svg", "base_2.svg"),
    ("b_base_3.svg", "base_3.svg"),
):
    copyfile(preview_sources / source_name, TOWERS / target_name)

print("Tower, base, HUD and fire SVGs generated")
