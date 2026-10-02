"""Torretas con cilindros, mecanismos visibles y siluetas propias."""
from pathlib import Path
from shutil import copy2
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / 'assets/sprites/towers'
BACKUP = ROOT / 'art/prototypes/full-pass/previous-v2'
BACKUP.mkdir(exist_ok=True)
EDGE = '#2b2233'

def p(d, fill, stroke=EDGE, w=1.2):
    return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{w}"/>'

def e(x, y, rx, ry, fill, stroke=EDGE, w=1.2):
    return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{fill}" stroke="{stroke}" stroke-width="{w}"/>'

def l(d, color='#f7efdc', w=1):
    return p(d, 'none', color, w)

def gradient(name, colors, radial=False):
    tag = 'radialGradient' if radial else 'linearGradient'
    coords = 'cx=".32" cy=".25" r=".75"' if radial else 'x1="0" y1="0" x2=".15" y2="1"'
    return f'<{tag} id="{name}" {coords}>' + ''.join(f'<stop offset="{pos}" stop-color="{c}"/>' for pos,c in zip(('0','.42','1'),colors)) + f'</{tag}>'

DEFS = gradient('steel', ('#edf2ec','#8da6b3','#354c61')) + gradient('dark', ('#788b9a','#3c5366','#1b2e40')) + gradient('brass', ('#fff0ac','#d5a257','#755036')) + gradient('green', ('#d4dfbd','#79958a','#344f51')) + gradient('copper', ('#ffe0a6','#d27b4b','#743d3d')) + gradient('blue', ('#e0e5ff','#8299c8','#3f4f7b')) + gradient('red', ('#ffcdb4','#be657b','#65394e')) + gradient('ice', ('#ffffff','#a1e5f1','#418bc0')) + gradient('energy', ('#ffffff','#bdf6ff','#4c9ed6'), True)

def pedestal(color='steel', rx=15):
    # Lower bearing wall and lit upper disk: smaller than the weapon itself.
    return (p(f'M{32-rx} 35 A{rx} 8 0 0 0 {32+rx} 35 L{32+rx} 41 A{rx} 8 0 0 1 {32-rx} 41Z', 'url(#dark)')
            + e(32,35,rx,8,f'url(#{color})')
            + e(32,34,rx-3,5,'url(#dark)',EDGE,.8)
            + l(f'M{34-rx} 34 Q32 26 {30+rx} 33')
            + e(24,40,1.3,1.1,'url(#brass)',EDGE,.5)
            + e(40,40,1.3,1.1,'url(#brass)',EDGE,.5))

def tube(x, end, y, r, color='steel', collar='brass'):
    # A horizontal cylinder has a continuous curved highlight and elliptical end.
    return (p(f'M{x} {y-r} L{end} {y-r} A{r*.43} {r} 0 0 1 {end} {y+r} L{x} {y+r} Q{x-4} {y} {x} {y-r}Z', f'url(#{color})')
            + l(f'M{x+2} {y-r+1.6} L{end-3} {y-r+1.6}', '#eef7ee',.9)
            + p(f'M{end-4} {y-r-1} L{end} {y-r-1} A{r*.46} {r+1} 0 0 1 {end} {y+r+1} L{end-4} {y+r+1} A{r*.46} {r+1} 0 0 0 {end-4} {y-r-1}Z',f'url(#{collar})',EDGE,.9)
            + e(end,y,r*.46,r+1,f'url(#{collar})',EDGE,1)
            + e(end+.2,y+.4,r*.29,r*.73,'#17232e',EDGE,.6)
            + p(f'M{end-.8} {y-r*.5} Q{end+1.4} {y} {end-.8} {y+r*.55}', 'none','#496172',.6))

def receiver(color='steel', long=False):
    return (p('M17 27 Q18 19 28 18 L35 22 Q40 29 35 37 L25 40 17 35Z',f'url(#{color})')
            + p('M17 31 Q25 36 35 30 L35 37 25 40 17 35Z','url(#dark)',EDGE,.7)
            + l('M20 24 Q24 19 29 21')
            + e(27,30,5.3,6,'url(#dark)',EDGE,.8)
            + e(27,29,3.2,3.8,f'url(#{color})',EDGE,.7)
            + e(26,27,1,1,'#f0f1de','none',0))

def save(name, body):
    dest=OUT/f'turret_{name}.svg'
    old=BACKUP/dest.name
    if not old.exists(): copy2(dest,old)
    source=f'<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">\n<!-- Torreta con volumen y mecanismo propio, orientada a la derecha; fondo transparente. -->\n<defs>{DEFS}</defs><g stroke-linejoin="round" stroke-linecap="round">{body}</g></svg>\n'
    ET.fromstring(source)
    dest.write_text(source,encoding='utf-8')

# Basic: compact double gun, the two muzzles extend well beyond its breech.
save('basic',pedestal()+tube(28,58,34,4.5)+receiver()+tube(29,56,23,4.3)+p('M22 21 L29 18 36 21 35 25 28 27 22 25Z','url(#steel)')+l('M25 21 29 20 33 21'))

# Cannon: rounded breech, thick gun tube, machined rings and deep bore.
save('cannon',pedestal(rx=16)+receiver()+tube(28,58,28,8)+p('M34 20 L38 20 Q41 28 38 36 L34 36 Q37 28 34 20Z','url(#brass)',EDGE,.8)+p('M20 33 L24 29 28 30 30 38 24 42 20 39Z','url(#dark)')+e(25,35,3,3.7,'url(#brass)',EDGE,.8))

# Sniper: stock, narrow long tube, elevated telescopic sight.
save('sniper',pedestal('green',13)+p('M14 25 L22 22 31 26 31 33 21 36 14 32Z','url(#green)')+tube(26,60,29,3,'green','steel')+p('M26 25 L39 24 40 33 27 35 22 31Z','url(#green)')+p('M27 23 L27 18 33 18 33 24Z','url(#dark)')+tube(24,41,18,3.6,'dark','brass')+e(41.5,18,1.1,2.4,'url(#energy)',EDGE,.6)+l('M17 26 21 25 25 27'))

# Flame thrower: copper reservoir with straps, curved feed pipe and hot nozzle.
save('fire',pedestal('copper')+p('M18 24 C10 24 9 37 19 38 L28 32','none','#2b2233',4)+p('M18 24 C10 24 9 37 19 38 L28 32','none','#b8794b',2)+tube(13,23,25,9,'copper','dark')+p('M15 17 L18 17 18 33 15 33Z','url(#brass)',EDGE,.7)+receiver('copper')+tube(29,58,29,6,'dark','copper')+p('M42 23 L45 23 45 35 42 35Z','url(#copper)',EDGE,.7)+e(58.5,29,1.3,3.5,'#ffbd4d',EDGE,.5)+e(59,29,0.6,2,'#fff3bf','none',0))

# Frost: condenser fins and a directional crystal with broad reflective faces.
frost=pedestal('steel')+p('M17 23 L23 18 30 22 30 37 23 41 17 36Z','url(#ice)')
for y in (23,27,31,35): frost+=p(f'M15 {y} L24 {y-2} 27 {y} 18 {y+3}Z','url(#steel)',EDGE,.65)
frost+=receiver('steel')+tube(30,44,28,7,'steel','brass')+p('M40 20 L52 22 62 28 52 36 40 36 43 28Z','#4896bf')+p('M40 20 L52 22 62 28 49 27 43 28Z','url(#ice)',EDGE,.7)+p('M43 28 L49 27 62 28 51 32 40 36Z','#86d5ed',EDGE,.7)+l('M43 22 51 24 57 27')
save('frost',frost)

# Multi: three cylinders on a wide horizontal yoke, distinct from twin basic.
multi=pedestal('blue')+p('M24 18 L33 16 42 23 42 39 33 45 24 39Z','url(#blue)')
for y,end in ((21,53),(38,53),(29.5,60)): multi+=tube(32,end,y,3.6,'steel','brass')
multi+=p('M25 21 Q32 18 36 23 L36 37 29 41 24 35Z','url(#blue)')+l('M27 23 Q30 20 33 23')
save('multi',multi)

# Burst: radial launcher with short circular ports around a raised red rotor.
burst=pedestal('dark',18)
for angle in range(0,360,60):
    burst+=f'<g transform="rotate({angle} 32 31)">'+tube(43,55,31,3.1,'dark','steel')+'</g>'
burst+=e(32,34,14,12,'url(#dark)')+e(32,28,14,11,'url(#red)')+e(32,28,10,7,'url(#brass)',EDGE,.8)+e(32,28,7.5,5.5,'url(#red)',EDGE,.8)+e(32,26,3.5,3,'url(#steel)',EDGE,.8)+l('M22 25 Q28 19 36 22')
save('burst',burst)

# Tesla: stacked copper coils and a large dielectric sphere; no generic gun body.
tesla=pedestal('dark',16)+p('M21 33 L21 20 38 20 41 35Z','url(#dark)')
for y in (32,27,22):
    tesla+=p(f'M19 {y} A12 5 0 0 0 43 {y} L43 {y+2} A12 5 0 0 1 19 {y+2}Z','url(#copper)',EDGE,.8)+e(31,y,12,4.5,'url(#brass)',EDGE,.8)+e(31,y,7,2.6,'url(#dark)',EDGE,.5)
tesla+=p('M29 20 L29 11 34 11 34 20Z','url(#steel)')+e(31,12,7.5,7.5,'url(#energy)')+p('M39 29 L51 29 51 33 39 33Z','url(#steel)')+e(53,30,6,6,'url(#energy)')+l('M27 9 Q30 6 33 8')
save('tesla',tesla)

# Mortar: wide short barrel elevated above side trunnions, elliptical thick lip.
mortar=pedestal('steel',18)+p('M18 39 L22 26 29 25 34 41Z','url(#dark)')+p('M33 39 L37 24 43 25 48 40Z','url(#dark)')+tube(24,53,25,12,'green','brass')+e(53,25,5.6,13,'url(#brass)')+e(54,25,3.5,9.4,'#17232e',EDGE,.8)+e(54.6,26,1.9,6.6,'#344b5c','none',0)+e(29,37,5,5,'url(#steel)')+e(29,37,2,2,'url(#brass)',EDGE,.5)+l('M28 15 L43 15')
save('mortar',mortar)
print('9 torretas rediseñadas; versión anterior preservada.')
