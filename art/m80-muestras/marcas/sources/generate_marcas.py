#!/usr/bin/env python3
"""T505: marcas y montajes sobre capturas reales. Solo escribe en marcas/.

Las coordenadas son de índice cero. Cada X se repinta antes del único ítem.
No ejecuta Godot, no altera mapas, no superpone marcas sobre decoración anterior.
"""
import sys
sys.dont_write_bytecode=True
from pathlib import Path
import json
import hashlib
from PIL import Image, ImageDraw
OUT=Path(__file__).resolve().parents[1]
ROOT=OUT.parents[2]
sys.path.insert(0,str(ROOT/'art/m80-muestras/glifo-h/sources'))
import generate_glifo as G

# Separadas entre sí y de postes/caminos; se comprueban de nuevo contra los JSON.
PLACEMENTS={
  12:{'banderin':(9,1),'tablilla':(16,4),'hito':(23,6),'cinta':(5,9)},
  13:{'banderin':(3,1),'tablilla':(13,4),'hito':(5,8),'cinta':(17,10)},
  14:{'banderin':(11,1),'tablilla':(1,5),'hito':(18,7),'cinta':(7,10)},
}


def campaign_row(assets):
    post=Image.open(ROOT/'assets/sprites/map/rendered/banner_post_enemy.png').convert('RGBA')
    for key in G.GLYPHS: assets[('poste',key)]=post


def sheets(assets,size):
    # Referencia en una fila propia y al lado de cada marca, a escala idéntica.
    cw=530 if size==220 else 350;ch=282 if size==220 else 220
    rows=[('banderin','pradera','Banderín'),('tablilla','desierto','Tablilla'),('hito','ruinas','Hito de cinco piedras'),('cinta','nieve','Cinta larga'),('poste','pradera','Referencia: poste de campaña')]
    im=Image.new('RGBA',(3*cw,82+len(rows)*ch),'#2a302b');d=ImageDraw.Draw(im)
    d.text((16,13),f'T505 · tipos de marca · {size} px · cada ítem ocupa una sola casilla',font=G.font(24),fill='white')
    d.text((16,49),'Columnas g1 / g2 / g3. Poste enemigo a la derecha de cada muestra; última fila: referencia intacta.',font=G.font(17),fill='#dcd8c1')
    post=assets[('poste','g1')]
    for j,(kind,biome,label) in enumerate(rows):
        for i,key in enumerate(G.GLYPHS):
            x=i*cw;y=82+j*ch
            ground=Image.open(ROOT/f'assets/tiles/rendered/ground_{biome}.png').convert('RGBA').resize((cw,ch),G.LANCZOS)
            im.alpha_composite(ground,(x,y));d.rectangle((x,y,x+cw,y+28),fill='#29302a')
            d.text((x+7,y+4),f'{key} · {label}',font=G.font(17),fill='white')
            sprite=assets[(kind,key)]
            if size==220:
                im.alpha_composite(sprite.resize((220,220),G.LANCZOS),(x+18,y+34))
                if kind!='poste':im.alpha_composite(post.resize((220,220),G.LANCZOS),(x+282,y+34))
                d.text((x+310,y+258),'Campaña · 220 px',font=G.font(14),fill='white',stroke_width=1,stroke_fill='#252b24')
            else:
                small=G.ROCKS.map_filter(sprite,34);pp=G.ROCKS.map_filter(post,34)
                im.alpha_composite(small,(x+12,y+76));im.alpha_composite(small.resize((136,136),Image.Resampling.NEAREST),(x+85,y+38))
                if kind!='poste':im.alpha_composite(pp,(x+285,y+76))
                d.text((x+10,y+187),'34 px · x4                        campaña',font=G.font(14),fill='white',stroke_width=1,stroke_fill='#252b24')
    G.save(im,f'marcas_hoja_{size:03}.png',OUT)


def compose(assets):
    base_cal=json.loads((ROOT/'art/m80-muestras/rocas/calibracion.json').read_text())
    posts=json.loads((ROOT/'data/ui/postes_campana.json').read_text())['niveles']
    compositions={}
    for number in [12,13,14]:
        data=json.loads((ROOT/f'data/levels/level_{number}.json').read_text());rows=data['mapa'];cols=max(map(len,rows))
        # Misma banda y método de T504; se agrega el límite por ancho de Rules.map_zoom.
        side=min(64,1280/cols,576/len(rows));ox=(1280-cols*side)/2;oy=48+(576-len(rows)*side)/2
        if str(number) in base_cal:
            cal=base_cal[str(number)]
            assert abs(side-cal['casilla_px'])<1e-6
            assert all(abs(a-b)<1e-6 for a,b in zip((ox,oy),cal['origen_px']))
        screenshot=ROOT/f'art/m79-inventario/antes-nivel-{number}-1280x720.png'
        before=Image.open(screenshot).convert('RGBA');after=before.copy();assert after.size==(1280,720)
        campaign=[tuple(p) for p in posts[f'level_{number}']]
        signals=[(x,y) for y,row in enumerate(rows) for x,ch in enumerate(row) if data['leyenda'].get(ch,{}).get('dibujo') in ['roca_marcada','simbolo_ruina']]
        # Retira los postes ya presentes en la captura para comparar sin/con poste.
        for x,y in campaign:
            l=round(ox+x*side);t=round(oy+y*side);r=round(ox+(x+1)*side);b=round(oy+(y+1)*side)
            ground=Image.open(ROOT/f"assets/tiles/rendered/ground_{data['tema']}.png").convert('RGBA')
            after.alpha_composite(ground.resize((r-l,b-t),Image.Resampling.BILINEAR),(l,t))
        used=set();entries=[]
        def place(cell,sprite,kind,key,signal=False,source=None):
            x,y=cell;assert 0<=y<len(rows) and 0<=x<len(rows[y])
            ch=rows[y][x];legend=data['leyenda'].get(ch,{})
            assert cell not in used and cell not in campaign,(number,kind,cell)
            if signal:
                assert legend.get('dibujo') in ['roca_marcada','simbolo_ruina']
            else:
                assert ch=='X' and ch not in data['leyenda'] and not legend,(number,kind,cell,ch)
            used.add(cell)
            box=(round(ox+x*side),round(oy+y*side),round(ox+(x+1)*side),round(oy+(y+1)*side))
            l,t,r,b=box;ground=Image.open(ROOT/f"assets/tiles/rendered/ground_{data['tema']}.png").convert('RGBA')
            after.alpha_composite(ground.resize((r-l,b-t),Image.Resampling.BILINEAR),(l,t))
            after.alpha_composite(G.ROCKS.map_filter(sprite,r-l).resize((r-l,b-t),Image.Resampling.BILINEAR),(l,t))
            entries.append({'tipo':kind,'glifo':key,'casilla':[x,y],'caracter_anterior':ch,'suelo_repintado':True,'rectangulo_px':list(box),'fuente':source})
        # Un mismo signo en todo el nivel; las tres composiciones permiten comparar g1/g2/g3.
        key=f'g{number-11}'
        for i,cell in enumerate(signals):
            snow=number==13
            sprite=G.engraved(key,color={12:'arenisca',13:'caliza',14:'oscura'}[number],snow=snow)
            source='art/m79-muestras/nieve/snow_rock_01.png' if snow else f"art/m80-muestras/rocas/roca_a_{'arenisca' if number==12 else 'oscura'}.png; cara receptora remapeada desde su fuente"
            if i==0: G.save(sprite,f'signal_level_{number}_{key}.png',OUT)
            place(cell,sprite,'roca grabada',key,True,source)
        for kind,cell in PLACEMENTS[number].items():
            sprite=assets[(kind,key)]
            # Nieve: el hito conserva piedras T504 y añade una capa blanca procedural.
            if number==13 and kind=='hito':sprite=G.cairn(key,snow=True)
            place(cell,sprite,kind,key,source=f'marca_{kind}_{key}.png'+(' + nieve procedural' if number==13 and kind=='hito' else ''))
        G.save(after,f'comp_nivel_{number}.png',OUT)
        with_posts=after.copy()
        for x,y in campaign:
            # El poste también reemplaza su X, no se apila sobre la decoración de la captura.
            assert (x,y) not in used and rows[y][x]=='X' and rows[y][x] not in data['leyenda']
            l=round(ox+x*side);t=round(oy+y*side);r=round(ox+(x+1)*side);b=round(oy+(y+1)*side)
            ground=Image.open(ROOT/f"assets/tiles/rendered/ground_{data['tema']}.png").convert('RGBA')
            with_posts.alpha_composite(ground.resize((r-l,b-t),Image.Resampling.BILINEAR),(l,t))
            with_posts.alpha_composite(G.ROCKS.map_filter(assets[('poste','g1')],r-l).resize((r-l,b-t),Image.Resampling.BILINEAR),(l,t))
        G.save(with_posts,f'comp_nivel_{number}_con_poste.png',OUT)
        compositions[str(number)]={'captura':str(screenshot.relative_to(ROOT)),'suelo':data['tema'],'glifo_unico':key,'calibracion':{'origen_px':[ox,oy],'casilla_px':side,'columnas':cols,'filas':len(rows),'metodo':'T504: banda 48..624 y casillas centradas; límite por ancho de Rules.map_zoom en nivel 12. Nivel 14 cotejado exactamente con calibracion.json.'},'casillas':entries,'postes_campana':[list(c) for c in campaign],'verificaciones':'X sin leyenda; exclusión de camino/entrada/salida/construible/removible/extracción/dibujo/poste; sin duplicados; un reemplazo por casilla.'}
        # Cada ítem, ampliado sin interpolar, más sus vecinos reales.
        detail=Image.new('RGBA',(1200,90+((len(entries)+3)//4)*265),'#2b302b');d=ImageDraw.Draw(detail)
        d.text((15,15),f'Nivel {number} · casillas exactas y vecinos · ampliación x2',font=G.font(23),fill='white')
        for i,e in enumerate(entries):
            l,t,r,b=e['rectangulo_px'];m=round(side*.6);box=(max(0,l-m),max(48,t-m),min(1280,r+m),min(624,b+m))
            crop=with_posts.crop(box);crop=crop.resize((crop.width*2,crop.height*2),Image.Resampling.NEAREST)
            x=(i%4)*300+8;y=(i//4)*265+65
            detail.alpha_composite(crop,(x,y))
            d.text((x,y+225),f"{e['casilla']} · {e['tipo']} · {key}",font=G.font(15),fill='white')
        G.save(detail,f'comp_nivel_{number}_detalle.png',OUT)
    G.dump(OUT/'composiciones.json',compositions)


def main():
    assets={};files={}
    for kind,fn in G.BUILDERS.items():
        for key in G.GLYPHS:
            sprite=fn(key);name=f'marca_{kind}_{key}.png';G.save(sprite,name,OUT)
            assets[(kind,key)]=sprite;files[name]=(kind,key)
    G.review(assets,OUT);campaign_row(assets)
    for side in [220,34]:sheets(assets,side)
    compose(assets)
    signals=Image.new('RGBA',(1260,460),'#c9c7b6');sd=ImageDraw.Draw(signals)
    for i,number in enumerate([12,13,14]):
        key=f'g{number-11}';sprite=Image.open(OUT/f'signal_level_{number}_{key}.png').convert('RGBA')
        signals.alpha_composite(sprite.resize((384,384),Image.Resampling.NEAREST),(i*420+8,32))
        signals.alpha_composite(G.ROCKS.map_filter(sprite,34),(i*420+376,400))
        sd.text((i*420+10,8),f'Nivel {number} · {key} · x3 y 34 px',font=G.font(18),fill='#252a21')
    G.save(signals,'signal_review_x3.png',OUT)
    (OUT/'procedencia.md').write_text(G.PROVENANCE+'''

## Composiciones y alcance
Las doce marcas son dibujos procedurales originales. El hito usa cinco bloques de
la fuente T504. El poste de campaña se reutiliza intacto solo como comparación.
Los montajes son ediciones sobre capturas reales previas; no son capturas de una
integración nueva. Cada casilla alterada se repinta antes de colocar un único ítem.
Nivel 12 usa g1 y arenisca; 13 usa g2 y snow_rock_01; 14 usa g3 y roca oscura.
No se mezclan variantes del signo dentro de un mismo nivel.
En nieve, snow_rock_01 es la excepción explícita solicitada a la familia T504.
Los JSON y postes se leen y se validan con assert. Se extiende la calibración T504
al ancho limitante del nivel 12 según scripts/logic/rules.gd. Los orígenes y tamaños
exactos, señales, cuatro X por nivel y postes están en composiciones.json.
La captura original ya trae postes: la versión base los retira repintando sus X.
La versión _con_poste los vuelve a dibujar a escala documentada en sus casillas.
''',encoding='utf-8')
    for number in [12,13,14]:
        key=f'g{number-11}';name=f'signal_level_{number}_{key}.png';files[name]=('roca grabada de composición',key)
    (OUT/'sources/procedencia.md').write_text((OUT/'procedencia.md').read_text(),encoding='utf-8')
    (OUT/'revision.md').write_text(G.REVIEW,encoding='utf-8')
    G.manifest(OUT,files)
    print('Marcas: doce piezas, hojas, seis composiciones y tres recortes; aserciones de casillas y alfa correctas.')

if __name__=='__main__':main()
