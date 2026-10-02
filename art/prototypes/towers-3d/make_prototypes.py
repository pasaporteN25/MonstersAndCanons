"""Bocetos SVG de volumen para torres. No cambia los assets del juego."""

from pathlib import Path
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent
INK = '#20242f'


def save(name: str, description: str, shapes: str, defs: str = '') -> None:
    source = f'''<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
  <!-- Boceto {description}; vista superior, centro de giro (32, 32). -->
  <defs>{defs}</defs>
  <g stroke-linejoin="round" stroke-linecap="round">{shapes}</g>
</svg>
'''
    ET.fromstring(source)
    (HERE / f'{name}.svg').write_text(source, encoding='utf-8')


def poly(points: str, fill: str, stroke: str = INK, width: float = 2.2) -> str:
    return f'<polygon points="{points}" fill="{fill}" stroke="{stroke}" stroke-width="{width}"/>'


def path(d: str, fill: str, stroke: str = INK, width: float = 2.2) -> str:
    return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{width}"/>'


def circle(x: float, y: float, r: float, fill: str, stroke: str = INK, width: float = 2) -> str:
    return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{width}"/>'


def line(d: str, color: str, width: float = 1.5) -> str:
    return path(d, 'none', color, width)


OCT_TOP = '22,6 42,6 58,22 58,42 42,58 22,58 6,42 6,22'
OCT_INNER = '23,10 41,10 54,23 54,41 41,54 23,54 10,41 10,23'
OCT_FACE = '23,8 41,8 56,23 56,39 41,54 23,54 8,39 8,23'

# A: madera tallada. Facetas planas, bordes oscuros y luz desde arriba a la izquierda.
wood_a = (
    poly('22,10 42,10 59,27 59,44 42,61 22,61 5,44 5,27', '#4b3028')
    + poly(OCT_TOP, '#a66b3e')
    + poly('22,6 42,6 58,22 54,24 40,11 24,11 10,24 6,22', '#d89a5b', 'none', 0)
    + poly('58,22 58,42 42,58 22,58 6,42 10,39 23,53 41,53 53,40 53,23', '#68432f', 'none', 0)
    + poly(OCT_INNER, '#9b6037', '#533728', 1.4)
    + '<path d="M11 24 H53 M9 31 H55 M9 39 H55 M11 46 H53" stroke="#533928" stroke-width="2"/>'
    + line('M13 21 H50 M12 28 H52 M12 36 H51 M15 44 H48', '#e4aa68', 1.5)
    + poly('18,14 22,11 26,14 22,17', '#d5b37a', '#6a4b35', .8)
    + poly('42,47 46,43 50,47 46,51', '#d5b37a', '#6a4b35', .8)
)
save('a_base_1', 'A, base de madera facetada', wood_a)

# B: más redondeado. El sombreado continuo y el aro hacen parecer la plataforma elevada.
wood_b_defs = '''<linearGradient id="wood" x1="0" y1="0" x2="0.88" y2="1">
  <stop stop-color="#ebba76"/><stop offset=".49" stop-color="#ad7147"/><stop offset="1" stop-color="#714536"/>
  </linearGradient>
  <linearGradient id="bevel" x1="0" y1="0" x2=".3" y2="1">
  <stop stop-color="#f3cf91"/><stop offset=".56" stop-color="#ad7448"/><stop offset="1" stop-color="#563a32"/>
  </linearGradient>
  <clipPath id="top"><polygon points="23,11 41,11 53,23 53,41 41,53 23,53 11,41 11,23"/></clipPath>'''
wood_b = (
    poly('22,10 42,10 59,27 59,45 42,61 22,61 5,45 5,27', '#3d2c2c')
    + poly('22,7 42,7 58,23 58,43 42,58 22,58 6,43 6,23', 'url(#bevel)')
    + poly(OCT_FACE, '#78503a', '#553a33', 1.5)
    + poly('23,11 41,11 53,23 53,41 41,53 23,53 11,41 11,23', 'url(#wood)', '#5c3d30', 1.2)
    + '<g clip-path="url(#top)" stroke="#6f432f" stroke-width="2.4">'
    + '<path d="M5 21 H60 M5 30 H60 M5 40 H60 M5 49 H60"/></g>'
    + line('M16 19 H49 M13 28 H52 M13 38 H52 M16 47 H49', '#f3c188', 1.4)
    + poly('17,17 20,14 23,17 20,20', '#efc476', '#8b653a', 1)
    + poly('41,47 44,44 47,47 44,50', '#efc476', '#8b653a', 1)
)
save('b_base_1', 'B, base de madera con bisel suave', wood_b, wood_b_defs)


def stone_base(style: str, gold: bool) -> str:
    if style == 'a':
        body = (
            circle(32, 36, 28, '#303747')
            + circle(32, 31, 28, '#727d87')
            + path('M6 28 A27 27 0 0 1 58 28 L54 29 A23 23 0 0 0 10 29Z', '#c2cbd0', 'none', 0)
            + path('M58 31 A26 26 0 0 1 7 39 L11 38 A22 22 0 0 0 54 32Z', '#3c4757', 'none', 0)
            + circle(32, 31, 21, '#6c7783', '#353e4d', 1.6)
            + poly('15,17 29,10 40,13 30,24 17,24', '#b5c1c8', 'none', 0)
            + poly('40,13 49,19 53,30 45,36 38,27', '#586473', 'none', 0)
            + line('M17 42 27 36 37 41 M30 20 36 26 34 34', '#485664', 1.5)
        )
        if gold:
            body += circle(32, 31, 25, 'none', '#e7b750', 2.8)
            body += line('M12 22 A24 24 0 0 1 42 8', '#fff1b3', 1.6)
            for x, y in [(16,15),(48,15),(16,47),(48,47)]:
                body += circle(x,y,2.5,'#ffd477','#7c5536',1)
        else:
            for x,y in [(18,12),(46,12),(55,31),(46,49),(18,49),(9,31)]:
                body += poly(f'{x-2},{y} {x},{y-2} {x+2},{y} {x},{y+2}', '#434e5b', 'none', 0)
        return body
    defs = '''<linearGradient id="stone" x1="0" y1="0" x2=".8" y2="1"><stop stop-color="#d3d8d5"/><stop offset=".45" stop-color="#899397"/><stop offset="1" stop-color="#505c69"/></linearGradient>
      <linearGradient id="rim" x1="0" y1="0" x2=".25" y2="1"><stop stop-color="#f0eee1"/><stop offset=".46" stop-color="#8f999a"/><stop offset="1" stop-color="#43515d"/></linearGradient>'''
    body = (
        circle(32,37,28,'#343945')
        + circle(32,32,28,'url(#rim)')
        + circle(32,31,23,'#56616c','#37424e',1.2)
        + circle(32,29,20,'url(#stone)','#53606c',1.4)
        + path('M16 21 Q32 11 47 19 L45 22 Q31 16 18 25Z','#e6e7dc','none',0)
        + path('M17 36 Q28 33 31 45 M36 20 43 26 40 35','none','#606d76',1.4)
    )
    if gold:
        body += circle(32,31,25,'none','#d09b39',3.2)
        body += line('M12 20 A24 24 0 0 1 44 10','#ffe49a',1.8)
        for x,y in [(16,15),(48,15),(16,47),(48,47)]:
            body += circle(x,y,2.5,'#ffe59a','#815b32',1)
    else:
        for x,y in [(17,15),(47,15),(17,47),(47,47)]:
            body += circle(x,y,1.8,'#58636c','#3f4b55',.7)
    return defs, body


for stage in (2,3):
    save(f'a_base_{stage}', f'A, base de piedra nivel {stage}', stone_base('a', stage==3))
    defs, shapes = stone_base('b', stage==3)
    save(f'b_base_{stage}', f'B, base de piedra nivel {stage}', shapes, defs)

# La torreta mira a la derecha. Las piezas inferiores se dibujan primero para que el
# centro parezca apoyado encima del cañón, y la luz sea coherente al girarlo.
cannon_a = (
    path('M33 25 54 25 59 22 62 25 62 42 57 44 53 39 33 39Z','#252a36')
    + poly('36,25 54,25 54,38 36,38','#4b5665')
    + poly('36,25 54,25 50,29 38,29','#8295a1','none',0)
    + poly('54,24 60,22 62,25 62,41 59,43 54,40','#46505e')
    + poly('56,26 60,25 60,38 56,39','#1c2532','none',0)
    + poly('19,20 32,17 44,23 48,32 43,43 31,47 19,43 15,32','#333b4a')
    + poly('19,19 32,16 44,22 47,31 42,40 31,44 20,40 16,31','url(#metal)')
    + poly('20,22 32,18 42,23 45,30 33,27 23,30','#b4bdba','none',0)
    + poly('43,32 42,39 32,43 31,37 38,32','#495363','none',0)
    + circle(31,31,8,'#414e5e','#252c38',1.5)
    + poly('27,26 33,24 37,28 31,30','#97aab3','none',0)
    + line('M18 33 21 39 27 42','#bbc1bb',1.4)
    + circle(21,31,1.5,'#d6ba7a','#544738',.7)
    + circle(40,31,1.5,'#d6ba7a','#544738',.7)
)
save('a_turret_cannon','A, cañón de acero facetado',cannon_a,
     '<linearGradient id="metal" x1="0" y1="0" x2=".8" y2="1"><stop stop-color="#9ba9b0"/><stop offset=".5" stop-color="#687580"/><stop offset="1" stop-color="#394557"/></linearGradient>')

cannon_b_defs = '''<linearGradient id="barrel" x1="0" y1="0" x2="0" y2="1"><stop stop-color="#b2c3c9"/><stop offset=".28" stop-color="#748591"/><stop offset=".68" stop-color="#4c5968"/><stop offset="1" stop-color="#2d3747"/></linearGradient>
  <radialGradient id="dome" cx=".32" cy=".25" r=".85"><stop stop-color="#c6d1ce"/><stop offset=".43" stop-color="#8698a1"/><stop offset="1" stop-color="#394658"/></radialGradient>'''
cannon_b = (
    path('M31 24 Q43 22 56 24 L60 22 62 25 62 40 58 42 54 39 31 40Z','#272f3d')
    + path('M34 25 H56 V38 H34Z','url(#barrel)')
    + path('M35 27 H53','none','#d7dcd4',1.4)
    + path('M53 25 59 23 61 26 61 39 58 41 53 39Z','#55616c')
    + path('M56 26 H59 V38 H56Z','#24303e','none',0)
    + circle(31,32,16,'#303a49')
    + circle(31,29,15,'url(#dome)')
    + circle(31,28,9,'#5c6b78','#394657',1.4)
    + circle(31,27,5,'#a5b8bb','#4f5d68',1)
    + path('M19 23 A14 14 0 0 1 34 16','none','#dbe3dc',2)
    + path('M43 32 A13 13 0 0 1 32 42','none','#293747',2)
    + circle(18,30,1.5,'#d6ba7a','#4d4d4c',.8)
    + circle(43,30,1.5,'#d6ba7a','#4d4d4c',.8)
)
save('b_turret_cannon','B, cañón de metal con luces suaves',cannon_b,cannon_b_defs)

# C: cañón más reconocible como artillería. Tres planos del tubo, boca profunda,
# armazón angular y herrajes dorados dan altura sin perder la vista superior.
cannon_c_defs = '''<linearGradient id="gun" x1="0" y1="0" x2=".65" y2="1"><stop stop-color="#dae0d8"/><stop offset=".35" stop-color="#82969f"/><stop offset="1" stop-color="#334354"/></linearGradient>
  <linearGradient id="body" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="#c0c8c4"/><stop offset=".45" stop-color="#70818b"/><stop offset="1" stop-color="#354657"/></linearGradient>
  <linearGradient id="brass" x1="0" y1="0" x2=".4" y2="1"><stop stop-color="#ffe49a"/><stop offset=".5" stop-color="#d4a64e"/><stop offset="1" stop-color="#785638"/></linearGradient>'''
cannon_c = (
    circle(31,34,16,'#253342')
    + circle(31,29,15,'#596a76','#273645',1.7)
    + path('M19 24 Q30 15 42 23','none','#c8d2cb',1.7)
    + poly('32,25 51,23 55,20 60,22 61,42 55,44 51,40 32,38','#273342')
    + poly('36,25 53,24 55,26 55,38 52,39 36,37','url(#gun)','#263544',1.5)
    + poly('38,25 51,24 54,26 52,29 38,30','#d6ddd5','none',0)
    + poly('38,34 53,34 54,39 36,37','#485867','none',0)
    + poly('51,23 55,20 61,22 62,42 55,44 51,40','#a27943')
    + poly('54,24 59,23 60,39 54,40','url(#brass)','#534c46',1)
    + poly('56,27 60,27 60,37 56,37','#202c38','none',0)
    + line('M55 25 59 24','#fff2b9',1.1)
    + poly('20,21 31,17 42,21 47,30 42,41 31,45 20,40 15,31','#293848')
    + poly('21,20 31,16 42,20 46,29 41,39 31,43 21,38 17,29','url(#body)')
    + poly('21,21 31,17 40,20 43,25 33,24 23,27 18,29','#e1e4d9','none',0)
    + poly('42,30 41,38 32,42 32,38 38,31','#3b5362','none',0)
    + poly('20,29 25,24 36,24 40,28 38,35 30,39 23,36','#344859','#1c2d3c',1.3)
    + poly('22,29 26,25 35,25 39,29 37,34 30,38 24,34','url(#gun)','#4d6270',.8)
    + poly('24,28 28,26 34,26 37,29 29,29','#dce5dd','none',0)
    + line('M24 35 30 38 36 35','#293b49',1.5)
    + circle(20,30,1.7,'#f6d783','#705438',.8)
    + circle(42,30,1.7,'#f6d783','#705438',.8)
)
save('c_turret_cannon','C, cañón elevado con armazón y boca profunda',cannon_c,cannon_c_defs)

frost_a = (
    poly('30,26 44,10 46,28','#51839f')
    + poly('31,39 44,54 46,36','#457996')
    + poly('37,27 61,31 47,36','#86d6eb')
    + poly('45,29 59,31 46,32','#f3ffff','none',0)
    + poly('19,21 30,17 41,21 46,31 41,42 30,46 19,41 15,31','#2c617d')
    + poly('20,20 32,17 43,22 46,31 40,40 30,44 19,39 16,30','#65bad9')
    + poly('20,22 32,18 40,23 32,29 19,29','#c0eff5','none',0)
    + poly('32,29 43,23 45,31 40,39 31,43','#318db9','none',0)
    + poly('21,31 29,25 38,29 35,38 27,40','#e1fdff','#327e9e',1.4)
    + line('M24 31 29 28 34 30','#ffffff',1.4)
)
save('a_turret_frost','A, torreta de hielo con cristales facetados',frost_a)

frost_b_defs = '''<radialGradient id="ice" cx=".35" cy=".2" r=".9"><stop stop-color="#efffff"/><stop offset=".45" stop-color="#85d9e9"/><stop offset="1" stop-color="#347aab"/></radialGradient>'''
frost_b = (
    poly('31,26 45,12 47,29','#4a8ab4')
    + poly('31,38 45,52 47,35','#3c7fab')
    + poly('37,27 62,31 46,36','#afebf3')
    + line('M42 30 57 31','#ffffff',1.5)
    + circle(30,33,16,'#2b668a')
    + circle(30,29,15,'url(#ice)')
    + poly('30,17 40,26 37,38 29,44 18,36 19,24','#69bbd8','#397fa8',1.6)
    + poly('30,17 40,26 30,29 19,24','#e0ffff','none',0)
    + poly('30,29 40,26 37,38 29,44','#4e9ec8','none',0)
    + poly('30,29 29,44 18,36 19,24','#9ee5ef','none',0)
    + line('M20 22 30 18 36 22','#ffffff',1.4)
)
save('b_turret_frost','B, torreta de hielo con brillo suave',frost_b,frost_b_defs)

# C: segunda lectura del hielo. El cristal sale hacia el objetivo en vez de
# parecer una gema grande sobre la base; se ve mejor la plataforma debajo.
stone_c_defs = '''<linearGradient id="rim" x1="0" y1="0" x2=".3" y2="1"><stop stop-color="#dfe4df"/><stop offset=".48" stop-color="#8d9b9f"/><stop offset="1" stop-color="#435260"/></linearGradient>
  <linearGradient id="deck" x1="0" y1="0" x2=".75" y2="1"><stop stop-color="#b8c3c2"/><stop offset=".5" stop-color="#869198"/><stop offset="1" stop-color="#536473"/></linearGradient>'''
stone_c = (
    circle(32,37,28,'#2c3543')
    + circle(32,32,28,'url(#rim)')
    + circle(32,31,24,'#445360','#273545',1.1)
    + circle(32,29,20,'url(#deck)','#576977',1.5)
    + path('M14 20 Q32 12 49 20','none','#eef2e9',2)
    + path('M52 35 Q48 49 34 51','none','#394957',2)
    + line('M17 20 22 25 29 23 M41 23 46 28 45 35 M19 38 27 36 32 42','#687781',1.4)
    + circle(32,29,12,'#647580','#374959',1.3)
    + circle(32,28,8,'#394f60','#a6b4b8',1.1)
    + circle(13,31,2,'#c4d0ca','#42505b',.8)
    + circle(51,31,2,'#c4d0ca','#42505b',.8)
)
save('c_base_2','C, base de piedra con zócalo profundo',stone_c,stone_c_defs)

frost_c_defs = '''<linearGradient id="shell" x1="0" y1="0" x2=".8" y2="1"><stop stop-color="#aed2dc"/><stop offset=".5" stop-color="#5c8da8"/><stop offset="1" stop-color="#31516d"/></linearGradient>
  <linearGradient id="ice" x1="0" y1="0" x2=".8" y2="1"><stop stop-color="#ffffff"/><stop offset=".4" stop-color="#b5f1f9"/><stop offset="1" stop-color="#4ca9dc"/></linearGradient>'''
frost_c = (
    # Thin rear condenser, clearly a machine rather than a large shield.
    poly('13,26 19,20 29,22 29,42 19,44 13,38','#39627a')
    + line('M17 26 17 38 M21 25 21 39','#a0c9d4',1.5)
    # Two opposed cooling fins create an arrow-shaped silhouette.
    + poly('31,26 46,11 50,13 44,28','#5b9fbd')
    + poly('34,25 46,15 44,27','#d1f4ee','none',0)
    + poly('31,37 46,52 50,50 44,35','#417a9b')
    + poly('34,38 46,48 44,37','#8bcad7','none',0)
    # Foreground nozzle with a long faceted ice lance.
    + poly('39,26 58,29 63,32 58,35 39,38','#3b6580')
    + poly('42,27 60,31 61,32 42,31','#e8ffff','none',0)
    + poly('42,32 61,32 57,35 42,37','#68bfdf','none',0)
    + poly('22,22 32,19 41,23 47,31 42,40 32,44 22,40 17,31','#2d506b')
    + poly('22,21 32,18 41,22 46,30 41,38 32,42 22,38 18,30','url(#shell)')
    + poly('22,22 32,19 40,23 42,27 33,26 24,28 19,30','#d1eef0','none',0)
    + poly('24,29 31,24 38,29 35,36 27,37','#315e7d','#254259',1.1)
    + poly('25,29 31,24 37,29 34,35 27,35','url(#ice)','#6dbbd3',.8)
    + line('M28 28 31 26 34 28','#ffffff',1.2)
)
save('c_turret_frost','C, proyector de hielo con lanza y aletas',frost_c,frost_c_defs)

print('13 prototipos SVG válidos guardados en', HERE)
