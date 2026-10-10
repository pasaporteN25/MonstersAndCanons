#!/usr/bin/env python3
"""Fuentes vectoriales provisionales: anatomía y apoyos propios por dirección."""
from pathlib import Path
ROOT = Path(__file__).resolve().parent
PALETTES = {'ratero': ['#f6c3a9','#c98269','#76453f'], 'cargador': ['#dca58f','#a5614c','#583c36']}

def source(kind, row, phase):
    colors = PALETTES[kind]
    parts = []
    def path(d, fill='skin', width=2):
        color = f'url(#{fill})' if fill in ('skin','bag') else fill
        parts.append(f'<path d="{d}" fill="{color}" stroke="#202330" stroke-width="{width}"/>')
    def light(d):
        parts.append(f'<path d="{d}" fill="none" stroke="{colors[0]}" stroke-width="1.4"/>')
    step = [0, 4, 0, -4][phase]
    lift = [0, 0, 2, 0][phase]
    # Los apoyos intercambian extensión; las fases de cruce tienen rodillas distintas.
    if row in (0,2):
        # La vista izquierda se redibuja en coordenadas; la luz conserva arriba/izquierda.
        def side(d):
            if row == 0: return d
            import re
            # Pares x,y; estas piezas no contienen radios ni órdenes horizontales.
            out=[]; x=True
            for token in re.findall(r'[MLQCZ]|-?\d+(?:\.\d+)?', d):
                if token.isalpha(): out.append(token)
                else:
                    out.append(str(64-float(token)) if x else token); x=not x
            return ' '.join(out)
        def p(d, f='skin'): path(side(d),f)
        if kind == 'ratero':
            p(f'M 22 40 L {18-step} 49 L {13-step} 56 L {24-step} 56 L {27-step} {49-lift} L 33 41')
            p('M 20 39 Q 10 31 5 39 Q 6 44 17 47 L 28 45')
            p('M 16 34 Q 24 28 36 33 L 43 39 L 35 48 Q 21 49 16 42 Z')
            p('M 34 34 L 34 22 L 40 30 L 45 23 L 46 33 L 55 36 L 59 40 L 50 43 L 42 42 L 37 39 Z')
            p(f'M 33 43 L {36+step} {50-lift} L {43+step} 56 L {32+step} 56 L {28+step} 50 L 27 45')
            p(f'M 40 40 L {46-step} 46 L {51-step} 47 L {48-step} 50 L {42-step} 49 L 35 42')
            p('M 46 34 L 51 35 L 47 37 Z','#ffe19a')
            p('M 53 41 L 51 45 L 49 42 Z','#fff0ce')
            light('M 19 35 Q 26 32 32 35' if row==0 else 'M 31 35 Q 37 32 43 35')
        else:
            p(f'M 35 43 L {32-step/2} 56 L {42-step/2} 56 L 44 44')
            p('M 9 22 Q 4 10 19 8 Q 34 4 39 18 L 41 37 Q 40 45 20 46 Q 6 43 9 22 Z','bag')
            p('M 17 9 L 13 5 L 23 6 L 27 3 L 29 9 Z','bag')
            p('M 31 31 Q 40 27 49 35 L 52 45 Q 46 51 31 47 L 26 39 Z')
            p('M 41 31 L 41 22 L 46 26 L 51 25 L 55 32 L 60 36 L 56 40 L 46 39 Z')
            p(f'M 44 44 L {45+step/2} {51-lift} L {51+step/2} 56 L {39+step/2} 56 L 37 48')
            p(f'M 36 33 L {28-step/2} 37 L 27 27 L 22 27 L 22 41 L 30 45 L 40 40')
            p('M 49 30 L 54 32 L 50 34 Z','#ffe19a')
            light('M 12 19 Q 13 12 22 12' if row==0 else 'M 26 14 Q 35 11 39 17')
            light('M 33 33 L 39 31' if row==0 else 'M 16 35 L 23 32')
    else:
        front = row == 1
        if kind == 'ratero':
            path(f'M 23 43 L {19-step/2} {51-lift} L {17-step/2} 56 L {27-step/2} 56 L 29 43')
            path(f'M 35 43 L {35+step/2} {51+lift/2} L {40+step/2} 56 L {30+step/2} 56 L 30 44')
            path('M 24 38 Q 13 32 12 24 Q 18 27 22 30 L 31 34')
            path('M 22 32 Q 31 27 40 33 L 42 44 Q 32 49 21 44 Z')
            path(f'M 24 39 L {18-step/2} 46 L 14 47 L 18 50 L 23 47 L 29 40')
            path(f'M 37 39 L {44+step/2} 46 L 48 47 L 44 50 L 39 47 L 33 40')
            path('M 22 31 L 20 20 L 27 26 L 37 26 L 44 20 L 42 33 L 38 39 L 27 39 Z')
            if front:
                path('M 25 31 L 29 32 L 26 34 Z','#ffe19a')
                path('M 35 32 L 39 31 L 38 34 Z','#ffe19a')
                path('M 29 37 L 32 35 L 35 37 L 32 40 Z','#76453f')
            light('M 25 28 L 29 27')
        else:
            path(f'M 21 42 L {19-step/2} 56 L {30-step/2} 56 L 31 43')
            path(f'M 34 42 L {35+step/2} {52-lift} L {34+step/2} 56 L {45+step/2} 56 L 42 43')
            def sack():
                path('M 13 17 Q 8 6 31 7 Q 50 5 51 20 L 51 38 Q 47 47 17 44 Q 9 41 13 17 Z','bag')
                path('M 27 8 L 22 3 L 32 5 L 37 3 L 38 9 Z','bag')
                light('M 17 18 Q 18 12 27 11')
            if front: sack()
            path('M 19 31 Q 32 26 44 31 L 48 45 Q 32 51 17 44 Z')
            path(f'M 20 31 L {12-step/2} 38 L 13 43 L 20 41 L 25 35')
            path(f'M 43 31 L {52+step/2} 38 L 51 43 L 44 41 L 39 35')
            path('M 24 30 L 23 22 L 28 25 L 36 25 L 42 22 L 41 32 L 36 39 L 28 39 Z')
            if front:
                path('M 26 30 L 30 31 L 27 33 Z','#ffe19a')
                path('M 35 31 L 39 30 L 38 33 Z','#ffe19a')
                path('M 29 36 L 32 34 L 35 36 L 32 39 Z','#583c36')
            else: sack()
    gradients = ''
    for name, stops in [('skin',colors),('bag',['#ded1ab','#b2a079','#6e6048'])]:
        gradients += f'<linearGradient id="{name}" x2="0.25" y2="1">' + ''.join(f'<stop offset="{i/2}" stop-color="{c}"/>' for i,c in enumerate(stops)) + '</linearGradient>'
    return f'<!-- {"Ratero bajo y veloz" if kind=="ratero" else "Cargador ancho con bolsa dominante"}; dirección {row}, fase {phase}; fondo transparente. -->\n<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64"><defs>{gradients}</defs><g transform="translate(6.4 2.15) scale(0.8)" stroke-linejoin="round" stroke-linecap="round">'+''.join(parts)+'</g></svg>\n'

if __name__ == '__main__':
    for kind in PALETTES:
        for row in range(4):
            for phase in range(4):
                (ROOT/'sources'/f'{kind}_{row}_{phase}.svg').write_text(source(kind,row,phase))
