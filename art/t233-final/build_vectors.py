"""Produce la decoración provisional de T233; conserva la fuente completa de la central."""
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets/sprites/map'
SRC = ROOT / 'art/t233-final/sources'
PALETTE = {'stone': ('#e0d8c6','#a99f8b','#625d53'), 'wood': ('#c4955f','#87603e','#4d392f'), 'metal': ('#b9c6c7','#73858a','#3d484f'), 'copper': ('#dbba87','#a4774b','#604536')}
def defs(size=64):
    return '<defs>'+''.join(f'<linearGradient id="{name}" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="{size*.25}" y2="{size}"><stop stop-color="{a}"/><stop offset=".52" stop-color="{b}"/><stop offset="1" stop-color="{c}"/></linearGradient>' for name,(a,b,c) in PALETTE.items())+'</defs>'
def svg(body, caption, size=64, offset=None):
    group = body if offset is None else f'<g transform="translate({-offset[0]} {-offset[1]})">{body}</g>'
    return f'<!-- {caption}; vista lateral hacia la derecha; fondo transparente. -->\n<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 {size} {size}">\n{defs(128 if offset is not None else size)}\n{group}\n</svg>\n'
def path(d, fill, width=2):
    return f'<path d="{d}" fill="{fill}" stroke="#2b2233" stroke-width="{width}" stroke-linecap="round" stroke-linejoin="round"/>'
def light(d):
    return f'<path d="{d}" fill="none" stroke="#f2e3c4" stroke-width="1.5" stroke-linecap="round"/>'
def shadow(cx=32,cy=56,rx=24):
    return f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="4" fill="#2b2233" opacity=".20"/>'
central = '<ellipse cx="64" cy="115" rx="57" ry="7" fill="#2b2233" opacity=".20"/>'
central += path('M12 108V55L21 43H85L98 57V108Z','url(#stone)')
central += path('M20 44V17H36V45','url(#metal)')+path('M17 17V12H39V17Z','url(#copper)')
central += path('M8 57 23 34H81L101 57Z','url(#copper)')+light('M17 51 27 39H78')
central += path('M81 35 101 57H88L72 35Z','#80573c',1)
central += path('M13 100H97V111H13Z','url(#stone)')+light('M17 104H88')
central += path('M22 88V66H40V88Z','#e5c58a')+path('M27 69V85H36V69Z','#f3e5b4',1)
central += path('M22 92H41','none')+light('M18 63V94')
central += path('M48 98V64L56 59H80L87 68V98Z','url(#metal)')
central += path('M53 68H81V76H53Z','url(#copper)')+light('M55 70H77')
central += path('M54 83H82M54 88H82M54 93H82','none',2)
central += path('M98 93H108V74H119V108H98Z','url(#metal)')+light('M103 98H112V78')
central += path('M105 73H122V81H105Z','url(#copper)')
central += path('M90 105V63','none')
SRC.mkdir(parents=True,exist_ok=True); OUT.mkdir(parents=True,exist_ok=True)
(SRC/'central_master.svg').write_text(svg(central,'Central completa de piedra, hierro y cobre, generador protegido y tubería de salida',128))
for i,(x,y) in enumerate([(0,0),(64,0),(0,64),(64,64)],1):
    text=svg(central,f'Cuarto {i} de la central provisional; orden noroeste, noreste, suroeste, sureste',offset=(x,y))
    (OUT/f'central_{i}.svg').write_text(text); (SRC/f'central_{i}.svg').write_text(text)
pieces = {}
pieces['supply_depot'] = shadow()+path('M9 53V30L18 23H45L54 31V53Z','url(#stone)')+path('M6 32 19 17H44L58 32Z','url(#copper)')+light('M13 28 22 21H42')+path('M23 52V34H42V52Z','url(#wood)')+path('M26 38H39M26 44H39','none',1)+light('M12 36V48')
pieces['supply_line_pole'] = shadow(rx=18)+path('M29 55 28 14H35L37 55Z','url(#wood)')+light('M31 19V47')+path('M12 19V13H53V19Z','url(#metal)')+light('M15 15H46')+path('M18 13V7H24V13M42 13V7H48V13','url(#stone)')+path('M3 7Q20 17 21 8M45 8Q54 16 61 11','none',1.5)
pieces['supply_cart'] = shadow()+path('M7 53H57M11 57H54','none',1.5)+path('M12 28 18 45H49L55 28Z','url(#metal)')+path('M12 28 23 20H47L55 28Z','url(#stone)')+light('M17 30H49')+path('M22 39H47','none',1)+path('M18 49H48','none',3)
for x in [22,45]:
    pieces['supply_cart']+=f'<circle cx="{x}" cy="49" r="5" fill="url(#copper)" stroke="#2b2233" stroke-width="2"/><circle cx="{x}" cy="49" r="1.5" fill="#2b2233"/>'
pieces['supply_conveyor'] = shadow()+path('M11 53V42H18V53M46 53V35H53V53','url(#wood)')+path('M7 37 51 25 58 36 14 48Z','url(#metal)')+path('M12 38 51 28 54 34 15 44Z','#485258',1)+light('M13 38 50 29')+path('M24 36 26 42M35 33 37 39M45 31 47 36','none',1.5)+path('M29 30 34 23 42 25 45 29 34 32Z','url(#stone)',1.5)
pieces['hito'] = shadow(rx=22)
for d in ['M10 51 9 42 16 35 37 33 52 41 54 50 39 55 21 54Z','M17 35 16 28 24 21 42 24 48 31 41 38 23 38Z','M24 22 23 16 29 10 38 11 42 18 37 25 29 25Z']:
    pieces['hito']+=path(d,'url(#stone)')
pieces['hito']+=light('M14 43 20 38 36 37')+light('M21 29 27 25 39 27')+light('M28 17 31 14H36')
for name,body in pieces.items():
    text=svg(body, 'Hito de límite, pila de tres piedras facetadas sin marca de demolición' if name=='hito' else 'Decoración permanente de abastecimiento: '+{'supply_depot':'depósito de piedra con portón de madera','supply_line_pole':'poste con aisladores y cable','supply_cart':'vagoneta cargada sobre dos rieles','supply_conveyor':'cinta inclinada con mineral'}[name])
    (OUT/f'{name}.svg').write_text(text); (SRC/f'{name}.svg').write_text(text)
print('T233: cuatro cuartos y cinco piezas vectoriales producidos.')
