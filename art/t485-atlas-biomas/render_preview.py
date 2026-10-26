#!/usr/bin/env python3
"""Dibuja un atlas conceptual y sus máscaras de descubrimiento; no modifica el juego."""
from pathlib import Path
import copy
import importlib.util
import json
import math
import random
import re
import sys
import xml.etree.ElementTree as ET
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[2]
ART=Path(__file__).resolve().parent
OUT=ROOT/'Capturas'
NS='http://www.w3.org/2000/svg'
ET.register_namespace('',NS)
POINTS=json.loads((ROOT/'art/t484-tramo-sur/option_b/route_points.json').read_text())
# T502 (D-212): el nodo 13 se corre 6 unidades al este para separarlo del 12 (la ruta B aprobada lo tenía en 1000,287).
POINTS['nodes'][12]=[1006,287]
COAST='M108 318 C108 292 129 282 142 261 L153 235 C164 213 189 209 207 194 L226 169 C243 157 265 162 284 153 C302 146 317 129 337 136 L358 144 C375 145 388 129 408 133 L438 149 C462 162 483 154 501 174 C518 192 519 214 542 218 C565 220 574 197 597 195 L618 200 C640 199 641 178 660 176 C684 174 689 192 713 189 L734 183 C751 185 758 204 781 206 C812 209 818 226 841 227 C861 228 874 211 891 217 L910 224 C927 230 937 214 948 208 L964 190 C980 182 991 203 1008 206 L1026 201 C1041 204 1041 225 1057 233 L1070 248 C1082 262 1086 279 1100 284 C1118 287 1128 306 1142 317 C1156 329 1162 348 1153 368 L1142 385 C1132 400 1105 403 1095 425 L1070 448 C1056 460 1035 455 1017 465 L998 478 C982 488 967 470 946 473 C922 477 918 495 897 491 L869 477 C851 470 842 488 819 484 C794 480 779 462 759 467 L736 473 C715 472 710 452 688 452 L665 460 C643 461 635 439 615 436 L594 444 C580 443 570 421 549 419 L526 425 C503 423 500 404 481 410 C458 416 453 427 429 420 L406 405 C387 400 380 420 360 414 L335 394 C316 388 304 407 283 399 C269 392 261 379 243 384 L223 389 C208 389 202 371 183 370 L164 375 C145 374 148 350 129 350 C118 350 116 332 108 318Z'
SNOW='M959 90 H1060 L1052 267 C1041 276 1048 307 1025 321 C1010 338 987 330 974 321 L961 298 C957 277 961 264 954 248 L945 230Z'
ZONE_1='M0 0 H660 C641 150 615 180 605 205 C584 226 551 227 549 255 C545 280 513 290 525 316 C539 334 514 357 520 380 C523 400 486 412 500 437 C515 463 560 459 570 490 L580 600 H0Z'
ZONE_2='M0 0 H955 C956 167 948 211 920 239 C904 250 884 253 887 276 C891 294 866 299 861 322 C856 342 886 355 880 374 C868 397 885 411 905 426 C925 447 889 459 902 483 L962 600 H0Z'


def elem(tag,attrs=None,parent=None):
    e=ET.Element('{'+NS+'}'+tag,attrs or {})
    if parent is not None:parent.append(e)
    return e


def path(parent,d,fill='none',stroke=None,width=None,opacity=None):
    attrs={'d':d,'fill':fill}
    if stroke:attrs['stroke']=stroke
    if width:attrs['stroke-width']=str(width)
    if opacity:attrs['opacity']=str(opacity)
    return elem('path',attrs,parent)


def gray(hexcolor):
    v=[int(hexcolor[i:i+2],16) for i in (1,3,5)]
    y=sum(a*b for a,b in zip(v,[.2126,.7152,.0722]))
    y=35+y*.48
    return '#'+''.join(f'{int(y+c):02x}' for c in [-3,1,1])


def fade_tree(tree,gradient_ids):
    for e in tree.iter():
        for key in ('fill','stroke','stop-color'):
            value=e.attrib.get(key,'')
            if re.fullmatch('#[0-9a-fA-F]{6}',value):e.set(key,gray(value))
            elif value.startswith('url(#'):
                old=value[5:-1]
                if old in gradient_ids:e.set(key,'url(#gray-'+old+')')


def gradient(defs,name,colors):
    e=elem('linearGradient',{'id':name,'x1':'0','y1':'0','x2':'.3','y2':'1'},defs)
    for offset,color in zip(['0','.5','1'],colors):elem('stop',{'offset':offset,'stop-color':color},e)
    return e


def make_terrain(defs):
    gradients=[]
    for name,colors in [('ground',['#7c885e','#586b49','#384d3e']),('snow',['#d5ded2','#b7cdc2','#83a5a0'])]:
        gradients.append(gradient(defs,name,colors))
    # Lavados de color sin contornos cerrados: textura y relieve definen las transiciones.
    for name,color,cx,cy,rx,ry,alpha in [
        ('sand-wash','#b8a470',884,298,326,330,.88),
        ('forest-wash','#355b39',590,365,115,210,.73),
        ('ruins-wash','#999d86',720,366,127,218,.70),
        ('east-grass-wash','#688b4e',1140,410,105,170,.97),
        ('east-ruins-wash','#9c9f8c',1068,314,80,130,.78)]:
        g=elem('radialGradient',{'id':name,'gradientUnits':'userSpaceOnUse','cx':'0','cy':'0','r':'1',
            'gradientTransform':f'matrix({rx} 0 0 {ry} {cx} {cy})'},defs)
        for offset,opacity in [('0',alpha),('.45',alpha),('.72',alpha*.65),('1',0)]:
            elem('stop',{'offset':offset,'stop-color':color,'stop-opacity':str(opacity)},g)
        gradients.append(g)
    for g in gradients:
        q=copy.deepcopy(g);q.set('id','gray-'+g.attrib['id']);fade_tree(q,set());defs.append(q)
    group=elem('g',{'id':'terrain','clip-path':'url(#land-clip)'})
    path(group,COAST,'url(#ground)')
    for name in ['sand-wash','forest-wash','ruins-wash']:
        path(group,COAST,'url(#'+name+')')
    path(group,SNOW,'url(#snow)')
    for name in ['east-ruins-wash','east-grass-wash']:
        path(group,COAST,'url(#'+name+')')
    # Relieve único, discontinuo y subordinado a la ruta.
    for d in [
      'M171 278 C194 246 225 245 242 259 S271 284 294 273',
      'M197 294 C220 264 234 274 257 284 S286 296 309 283',
      'M295 211 C319 192 334 201 350 198 S382 184 408 202',
      'M287 222 C318 204 337 214 353 211 S384 196 404 213',
      'M343 340 C369 322 386 336 403 348 S434 367 451 355',
      'M348 354 C376 337 389 351 405 361 S434 379 447 368',
      'M498 211 C510 235 493 246 500 264',
      'M543 268 C570 255 593 268 604 279 S627 292 638 283',
      'M556 282 C581 271 590 285 607 291',
      'M545 401 C571 416 584 416 595 428',
      'M656 341 C684 328 707 344 721 335 S746 314 765 321',
      'M662 354 C685 340 707 358 721 348',
      'M704 425 C724 410 742 419 758 407 S783 396 794 403',
      'M755 215 C788 223 804 249 833 247 S865 231 887 241',
      'M769 227 C796 235 806 259 835 258 S867 244 887 253',
      'M822 287 C843 272 863 279 882 267 S912 250 934 260',
      'M827 299 C853 285 867 294 888 281 S913 267 936 272',
      'M850 373 C872 360 901 370 925 356',
      'M860 384 C886 372 901 383 927 366',
      'M913 433 C939 409 961 426 981 414 S1008 408 1017 412',
      'M1067 376 C1077 363 1094 376 1106 362',
      'M1063 390 C1080 374 1099 390 1117 372']:
        path(group,d,stroke='#dac894',width='1.1',opacity='.23')
    # Hachuras y pliegues amplios: no forman un patrón repetido.
    for d in ['M283 203 302 183 316 195 335 173 352 194 372 179 391 202',
              'M645 233 661 215 677 238 689 229 706 247',
              'M961 265 975 246 987 261 1006 238 1018 257 1033 252 1041 271']:
        path(group,d,stroke='#d1c99d',width='1.8',opacity='.58')
    for d in ['M302 183 306 204M335 173 343 202M372 179 380 208',
              'M661 215 667 242M689 229 695 253',
              'M975 246 981 274M1006 238 1015 271M1033 252 1039 278']:
        path(group,d,stroke='#2e443c',width='1.2',opacity='.55')
    # Sector nevado localizado en torno al nivel 13; no se extiende al desierto 12.
    path(group,'M963 263 975 246 986 260 978 256 973 263 971 257Z','#e3e8dc')
    path(group,'M990 258 1006 238 1018 257 1009 252 1003 257 1001 251Z','#edf0e4')
    path(group,'M986 276 C995 265 1006 270 1017 280 M979 286 C994 274 1006 281 1017 289',stroke='#6d9998',width='1.1',opacity='.7')
    # Ríos y cauces conectados a la costa; no crean puentes jugables.
    for d in ['M449 193 C466 214 468 235 460 252 S482 279 475 304 S494 334 479 365 S490 393 481 410',
              'M664 225 C675 242 689 261 677 287 S701 326 705 352 S704 389 716 413 L727 449',
              'M1009 248 C1020 273 1003 291 1009 310 S1030 336 1017 369 S1036 421 1017 465']:
        path(group,d,stroke='#84a7a1',width='2.5',opacity='.72')
    # Manchas de bosque construidas como masas irregulares pequeñas, sin óvalos.
    rng=random.Random(485)
    for cx,cy in [(548,292),(588,312),(623,328),(560,374),(631,417),(583,438),(665,406)]:
        for _ in range(6):
            x=cx+rng.uniform(-17,17);y=cy+rng.uniform(-12,12);s=rng.uniform(3.5,6)
            if any(math.dist((x,y),q)<30 for q in POINTS['nodes']):continue
            d=f'M{x:.1f} {y-s*2:.1f} l{-s:.1f} {s*1.3:.1f} h{s*.5:.1f} l{-s*.8:.1f} {s*1.2:.1f} h{s*2.6:.1f} l{-s*.8:.1f} {-s*1.2:.1f} h{s*.5:.1f} Z'
            path(group,d,'#284938',opacity='.6')
    # Restos cartográficos discretos en 8–9, transición del 10 y sector del 14.
    for x,y in [(658,406),(704,361),(738,376),(789,303),(815,350),(1044,312),(1078,295),(1086,333),(1059,348),(1094,316)]:
        g=elem('g',{'transform':f'translate({x} {y})','opacity':'.76'},group)
        path(g,'M-9 5V-6h5V3h8V-4h4V8H-8Z','#596153','#c6c3a0','1')
        path(g,'M-12 11h26M-5-9h5M4-7h6',stroke='#d1c7a6',width='1')
    # Duna/ribera seca: líneas finas y largas en lugar de círculos de color.
    for d in ['M817 261 C831 250 852 252 862 257M866 247 C881 240 893 246 899 249',
              'M892 353 C907 343 927 347 939 341M907 364 C924 351 943 359 954 350',
              'M924 234 C936 229 945 235 951 239']:
        path(group,d,stroke='#e4ca91',width='1.3',opacity='.42')
    return group


def base_route():
    root=ET.parse(ROOT/'art/t484-tramo-sur/option_b/route.svg').getroot()
    original=next(x.attrib['d'] for x in root if x.tag.endswith('path') and x.attrib.get('clip-path')=='url(#unchanged-route)')
    central=next(x.attrib['d'] for x in root if x.attrib.get('id')=='central-route')
    prefix,rest=original.split(' C467 274',1);_,suffix=rest.split(' C858 319',1)
    route=prefix+' '+central.removeprefix('M443 262 ')+' C858 319'+suffix
    # T502: el tramo 12->13 termina en 1006,287 y el 13->14 arranca con su primer control corrido igual (tangentes intactas).
    old='C968 284 984 280 1000 287 C1023 293 1044 299 1065 312'
    assert old in route
    return route.replace(old,'C968 284 990 280 1006 287 C1029 293 1044 299 1065 312')


def make_svg(stage:int):
    original=ET.parse(ROOT/'assets/ui/campaign_map_background.svg').getroot()
    root=elem('svg',dict(original.attrib));defs=copy.deepcopy(original[0]);root.append(defs)
    for name,d in [('land-clip',COAST),('zone-1',ZONE_1),('zone-2',ZONE_2)]:
        clip=elem('clipPath',{'id':name},defs);path(clip,d,'#fff')
    for zone,d in [(1,ZONE_1),(2,ZONE_2)]:
        mask=elem('mask',{'id':f'zone-mask-{zone}','maskUnits':'userSpaceOnUse',
            'x':'20','y':'90','width':'1240','height':'472'},defs)
        elem('rect',{'x':'20','y':'90','width':'1240','height':'472','fill':'#000'},mask)
        for width,alpha in [(26,.12),(18,.20),(10,.35)]:
            path(mask,d,'none','#fff',str(width),str(alpha))
        path(mask,d,'#fff')
    terrain=make_terrain(defs)
    elem('rect',{'x':'20','y':'90','width':'1240','height':'472','rx':'15','fill':'url(#sea)','stroke':'#3b3329','stroke-width':'2'},root)
    # Detalles de agua desiguales, separados de la silueta continental.
    for d in ['M128 238 C161 194 181 190 213 172M246 145 C272 143 294 127 316 125',
              'M373 118 C404 116 423 136 445 137M525 189 C547 209 566 187 581 184',
              'M807 200 C829 222 849 207 862 203M1037 250 C1051 262 1064 279 1084 278',
              'M1138 405 C1113 418 1114 437 1083 462M998 491 C982 503 967 484 947 487',
              'M842 497 C818 510 795 491 775 487M586 460 C568 455 562 437 540 439',
              'M373 431 C352 435 341 410 321 412M212 407 C194 400 191 390 173 392']:
        path(root,d,stroke='#577d7e',width='1',opacity='.38')
    gray_terrain=copy.deepcopy(terrain);gray_terrain.set('id','terrain-gray');fade_tree(gray_terrain,{'ground','snow','sand-wash','forest-wash','ruins-wash','east-grass-wash','east-ruins-wash'});root.append(gray_terrain)
    if stage<2:
        reveal=elem('g',{'mask':f'url(#zone-mask-{stage+1})'},root);reveal.append(terrain)
    else:root.append(terrain)
    path(root,COAST,stroke='#2b2233',width='2.6')
    path(root,COAST,stroke='#b0b48d',width='.7',opacity='.23')
    # Misma geometría B aprobada; el descubrimiento no cambia la secuencia de niveles.
    route=base_route();path(root,route,stroke='#d2be7e',width='2.4',opacity='.61').set('stroke-dasharray','4 10')
    selected=[3,6,11][stage]
    chunks=route.split(' C');active=chunks[0]+' C'+' C'.join(chunks[1:selected+1])
    path(root,active,stroke='#e9c66f',width='2.6').set('stroke-dasharray','4 9')
    g=elem('g',{'transform':'translate(177 310)'},root)
    elem('circle',{'r':'25','fill':'#263133','stroke':'#dfbb67','stroke-width':'2'},g)
    elem('use',{'href':'#lander','transform':'scale(1.14)'},g)
    for n,(x,y) in enumerate(POINTS['nodes'],1):
        g=elem('g',{'transform':f'translate({x} {y})','id':f'level-{n}'},root)
        if n<selected:
            elem('circle',{'r':'22','fill':'#a98039','stroke':'#dfbf78','stroke-width':'2'},g)
            elem('circle',{'r':'17','fill':'none','stroke':'#d5b46c','stroke-width':'1'},g)
            stars=2 if stage==0 and n==2 else 3
            for dx,dy in ([(-7,-34),(7,-34)] if stars==2 else [(-12,-32),(0,-36),(12,-32)]):
                elem('use',{'href':'#star','transform':f'translate({dx} {dy}) scale(.56)','fill':'#e4c16b'},g)
        elif n==selected:
            elem('circle',{'r':'29','fill':'none','stroke':'#efd482','stroke-width':'1.3'},g)
            elem('circle',{'r':'24','fill':'#c78c35','stroke':'#f6e2a1','stroke-width':'3'},g)
            elem('circle',{'r':'18','fill':'none','stroke':'#8e622a','stroke-width':'1.2'},g)
        else:
            elem('circle',{'r':'20','fill':'#3e4c4b','stroke':'#202a2b','stroke-width':'2'},g)
            elem('circle',{'r':'15','fill':'none','stroke':'#717c72','stroke-opacity':'.38'},g)
            elem('use',{'href':'#lock','transform':'translate(15 -15) scale(.57)'},g)
    ET.indent(root,space='  ')
    return root


def font(size,bold=False):
    return ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans'+('-Bold' if bold else '')+'.ttf',size)


def rasterize(svg):
    sys.dont_write_bytecode=True
    spec=importlib.util.spec_from_file_location('t483_preview',ROOT/'art/t483-mapa-organico/render_preview.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    module.ART=svg.parent
    return module.rasterize()


def compose(map_image,stage):
    canvas=Image.new('RGB',(1280,720),'#1d2427');canvas.paste(map_image,(20,105));draw=ImageDraw.Draw(canvas)
    draw.text((26,20),'Campaña · Atlas de Cántaro',font=font(29,True),fill='#e7cc83')
    subtitle=['Primer bloque · cartografía 1–5','N6 desbloqueado · cartografía 1–10','N11 desbloqueado · cartografía 1–15'][stage]
    draw.text((28,65),subtitle,font=font(16),fill='#c7cebf')
    draw.text((34,117),'ATLAS MERIDIANO · CÁNTARO',font=font(11),fill='#d7d9c2')
    for n,(x,y) in enumerate(POINTS['nodes'],1):
        draw.text((x,y+15),str(n),font=font(18 if n<10 else 16,True),fill='#f9edd1' if n<=[3,6,11][stage] else '#d1d7c9',anchor='mm')
    selected=[3,6,11][stage];names={3:'Encrucijada',6:'Nido',11:'Puesto seco'}
    sx,sy=POINTS['nodes'][selected-1]
    draw.text((sx,sy+15+35),f'{selected} · {names[selected]}',font=font(11),fill='#efd58d',anchor='mt',stroke_width=1,stroke_fill='#364739')
    draw.text((177,353),'ATERRIZAJE',font=font(10),fill='#e2ce99',anchor='mt',stroke_width=1,stroke_fill='#364739')
    draw.rectangle((1037,114,1250,233),fill='#222b2d',outline='#795e3c',width=1)
    for y,c,label in [(133,'#6a7857','Cartografía descubierta'),(158,'#555e5d','Sin descubrir'),(183,'#a98039','Conquista: estrellas'),(208,'#3e4c4b','Acceso: candados')]:
        draw.ellipse((1049,y-6,1061,y+6),fill=c,outline='#b6bda7',width=1);draw.text((1070,y-7),label,font=font(11),fill='#dce1d0')
    draw.rounded_rectangle((20,598,1260,683),radius=7,fill='#202629',outline='#8a663b',width=2)
    draw.text((38,611),f'{selected} · {names[selected]}',font=font(27),fill='#eee8d9')
    draw.text((40,650),'Disponible · sin victorias todavía',font=font(14),fill='#c6cdbc')
    draw.rounded_rectangle((1076,615,1240,667),radius=5,fill='#242729',outline='#a47e43',width=2)
    draw.text((1158,641),'Jugar',font=font(23),fill='#eee8d9',anchor='mm')
    return canvas


def main():
    for stage,slug in enumerate(['inicio','nivel-6','nivel-11']):
        target=ART/slug;target.mkdir(exist_ok=True)
        svg=target/'route.svg';svg.write_text('<!-- Atlas conceptual T485: biomas leídos de niveles; descubrimiento propuesto, sin runtime. -->\n'+ET.tostring(make_svg(stage),encoding='unicode')+'\n')
        compose(rasterize(svg),stage).save(OUT/f'T485-atlas-{slug}.png',optimize=True)
    (ART/'route_points.json').write_text(json.dumps(POINTS,indent=2)+'\n')
    (ART/'level_themes.json').write_text(json.dumps([{'level':n,'name':json.loads((ROOT/f'data/levels/level_{n:02}.json').read_text())['nombre'],'theme':json.loads((ROOT/f'data/levels/level_{n:02}.json').read_text())['tema']} for n in range(1,16)],ensure_ascii=False,indent=2)+'\n')


if __name__=='__main__':main()
