#!/usr/bin/env python3
"""Controles técnicos y regeneración opcional. Solo escribe marcas/validation.json.

Con --rebuild regenera ambas carpetas autorizadas y contrasta todos sus hashes.
Nunca ejecuta el generador T504 ni Godot. No necesita paquetes salvo Pillow.
"""
import sys
sys.dont_write_bytecode=True
from pathlib import Path
import hashlib
import json
import subprocess
from PIL import Image
OUT=Path(__file__).resolve().parents[1]
ROOT=OUT.parents[2]
GLYPH=ROOT/'art/m80-muestras/glifo-h'


def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def snapshot(paths):
    return {str(p.relative_to(ROOT)):digest(p) for p in sorted(set(paths)) if p.is_file()}


def main():
    protected=list((ROOT/'art/m80-muestras/rocas').rglob('*'))
    protected+=list((ROOT/'assets/sprites/map/rendered').glob('*.png'))
    protected+=list((ROOT/'assets/tiles/rendered').glob('ground_*.png'))
    protected+=[ROOT/'data/ui/postes_campana.json',ROOT/'art/m79-muestras/nieve/snow_rock_01.png',ROOT/'art/m79-muestras/nieve/generate_samples.py']
    protected+=list(GLYPH.rglob('prompts.md'))+list(OUT.rglob('prompts.md'))
    for n in [12,13,14]:protected.extend([ROOT/f'data/levels/level_{n}.json',ROOT/f'art/m79-inventario/antes-nivel-{n}-1280x720.png'])
    before=snapshot(protected)
    def outputs():
        return snapshot([p for folder in [GLYPH,OUT] for p in folder.rglob('*') if p.is_file() and p.name!='validation.json'])
    initial=outputs()
    rebuilt='--rebuild' in sys.argv
    if rebuilt:
        for script in [GLYPH/'sources/generate_glifo.py',OUT/'sources/generate_marcas.py']:
            subprocess.run([sys.executable,str(script)],cwd=ROOT,check=True)
        assert initial==outputs(),'La regeneración cambió alguna salida.'
    assert before==snapshot(protected),'Cambió una referencia de solo lectura.'
    sprites=list(GLYPH.glob('g[123]_*.png'))+list(OUT.glob('marca_*.png'))
    assert len(sprites)==21,len(sprites)
    for p in sprites+list(OUT.glob('signal_level_*.png')):
        im=Image.open(p);assert im.size==(128,128) and im.mode=='RGBA',str(p)
        a=im.getchannel('A');box=a.getbbox()
        assert box and 0<box[0]<box[2]<128 and 0<box[1]<box[3]<128,(str(p),box)
        assert all(a.getpixel(pt)==0 for pt in [(0,0),(127,0),(0,127),(127,127)])
    for folder in [GLYPH,OUT]:
        records=json.loads((folder/'manifest.json').read_text())
        assert records==json.loads((folder/'sources/manifest.json').read_text())
        for r in records:assert digest(folder/r['archivo'])==r['sha256'],r['archivo']
    placements=json.loads((OUT/'composiciones.json').read_text())
    posts=json.loads((ROOT/'data/ui/postes_campana.json').read_text())['niveles']
    for n,c in placements.items():
        data=json.loads((ROOT/f'data/levels/level_{n}.json').read_text());used=set()
        found_signals=set()
        for entry in c['casillas']:
            x,y=entry['casilla'];ch=data['mapa'][y][x]
            assert (x,y) not in used and [x,y] not in posts[f'level_{n}'];used.add((x,y))
            if entry['tipo']=='roca grabada':
                assert data['leyenda'].get(ch,{}).get('dibujo') in ['roca_marcada','simbolo_ruina']
                found_signals.add((x,y))
            else:assert ch=='X' and ch not in data['leyenda']
            assert entry['glifo']==c['glifo_unico'] and entry['suelo_repintado']
        all_signals={(x,y) for y,row in enumerate(data['mapa']) for x,ch in enumerate(row) if data['leyenda'].get(ch,{}).get('dibujo') in ['roca_marcada','simbolo_ruina']}
        assert found_signals==all_signals
        assert len(c['casillas'])-len(found_signals)==4
        for suffix in ['', '_con_poste']:
            assert Image.open(OUT/f'comp_nivel_{n}{suffix}.png').size==(1280,720)
        # Fuera de las casillas registradas, el montaje conserva la captura exacta.
        source=Image.open(ROOT/c['captura']).convert('RGBA')
        base=Image.open(OUT/f'comp_nivel_{n}.png').convert('RGBA')
        allowed=set()
        for e in c['casillas']:
            l,t,r,b=e['rectangulo_px'];allowed.update((x,y) for y in range(t,b) for x in range(l,r))
        ox,oy=c['calibracion']['origen_px'];side=c['calibracion']['casilla_px']
        for x,y in c['postes_campana']:
            l,t,r,b=round(ox+x*side),round(oy+y*side),round(ox+(x+1)*side),round(oy+(y+1)*side)
            allowed.update((xx,yy) for yy in range(t,b) for xx in range(l,r))
        a=source.load();b=base.load()
        assert all(a[x,y]==b[x,y] for y in range(720) for x in range(1280) if (x,y) not in allowed)
    result={'resultado':'Controles correctos','piezas_principales':21,'rocas_auxiliares':3,'composiciones':6,'marcas_en_X_por_nivel':4,'señales_por_nivel':{n:sum(e['tipo']=='roca grabada' for e in c['casillas']) for n,c in placements.items()},'reproducibilidad_sha256':rebuilt,'referencias_sin_cambios':before,'limites':'No verifica aprobación artística, GPU, ejecución de Godot ni teléfono.'}
    (OUT/'validation.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('Correcto: 21 piezas + 3 rocas auxiliares, 6 composiciones, casillas, alfa, manifiestos y alcance de edición. Regeneración idéntica:',rebuilt)

if __name__=='__main__':main()
