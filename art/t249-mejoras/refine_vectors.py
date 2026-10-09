"""Retoques reproducibles de SVG existentes; las fuentes previas quedan intactas."""
from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[2]
BEFORE=ROOT/'art/t249-mejoras/sources/before'
MAP=ROOT/'assets/sprites/map'
def source(name,folder='map'):
 return (BEFORE/f'assets/sprites/{folder}/{name}.svg').read_text()
def save(name,s,folder='map'):
 # Un único contorno común para mapa e íconos; sombra de mapa sin contorno.
 for ink in ['#202330','#253442','#24313f']:
  s=s.replace(ink,'#2b2233')
 (ROOT/f'assets/sprites/{folder}/{name}.svg').write_text(s)
def replace_body(s,body):
 return s[:s.index('</defs>')+7]+'\n'+body+'\n</svg>\n'
def a_mark(s):
 # La misma A geométrica en piedra marcada y ruinas; hendidura ancha, bisel inferior.
 s=re.sub(r'<path d="m(?:24 42|25 40).*?/>','',s)
 s=re.sub(r'<path d="m(?:25 41|26 39).*?/>','',s)
 return s.replace('</svg>','<path d="M23 43 32 25 41 43M27 36h10" fill="none" stroke="#e2d3b4" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>\n<path d="M23 42 32 24 41 42M27 35h10" fill="none" stroke="#4b4037" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>\n</svg>')
for name in ['roca_marcada','simbolo_ruina','escombro']:
 s=a_mark(source(name))
 if name=='escombro':
  s=s.replace('m47 31 7-4 1 8-7 3Z','M45 30 55 26 57 38 47 41Z')
  s=s.replace('stroke-width="1.2"','stroke-width="2"')
 save(name,s)
# Ruina en trabajo: la marca se conserva; las grietas y la cuña ganan separación.
s=a_mark(source('escombro_trabajo')).replace('stroke-width="1.5"','stroke-width="2"')
s=s.replace('</svg>','<path d="M44 43 53 40 56 46 47 49Z" fill="url(#amber)" stroke="#2b2233" stroke-width="2"/>\n</svg>')
save('escombro_trabajo',s)
# El sendero conserva tres pasos bajos, pero los huecos y los cantos se leen a 34 px.
s=source('sendero').replace('M6 43q8-5 16-2l3 5q-10 5-19 1Z','M5 43 10 37 19 37 23 42 21 48 7 49Z').replace('M23 37q8-5 17-1l2 6q-10 4-19 0Z','M25 34 30 28 38 29 42 34 40 40 26 41Z').replace('M42 43q7-4 15 0l1 5q-8 4-16 0Z','M44 43 48 37 56 39 59 45 55 50 44 49Z')
s=re.sub(r'<path d="m9 43.*?/>','<path d="M9 40h10M29 32h8M48 41l7 1" fill="none" stroke="#eee2cb" stroke-width="1.5" stroke-linecap="round"/>',s)
save('sendero',s)
# Cabeza más amplia y atadura legible, manteniendo el mango y su apoyo.
s=source('herramienta').replace('m41 19 5-6 10 1-3 12-6 2Z','M39 19 44 10 57 12 54 28 46 30Z')
s=s.replace('</svg>','<path d="M42 23 48 28M44 20 50 25" stroke="#4d392f" stroke-width="2" stroke-linecap="round"/>\n</svg>')
save('herramienta',s)
# Cintas desiguales, gastadas, con huecos: dejan de parecer dos banderines simétricos.
s=source('poste_cintas').replace('M32 19 18 15 16 29 29 24Z','M32 19 17 14 13 35 20 31 24 34 29 24Z').replace('M35 18 48 13 50 27 37 23Z','M35 18 49 12 53 28 47 24 44 29 37 23Z')
s=s.replace('m20 17 8 4m20-5-8 4','M19 18 28 21M47 16 40 20')
save('poste_cintas',s)
# Lona claramente vencida y fogón separado; no una tienda habitable.
s=source('campamento_vacio')
s=replace_body(s,'''<ellipse cx="32" cy="56" rx="25" ry="3.5" fill="#2b2233" opacity=".18"/>
<path d="M11 46 19 28 30 34 45 39 53 48 41 50 29 42 18 50Z" fill="url(#cloth)" stroke="#2b2233" stroke-width="2" stroke-linejoin="round"/>
<path d="M19 29 23 37 38 41" fill="none" stroke="#e2a28a" stroke-width="1.5" stroke-linecap="round"/>
<path d="M18 50 22 35 29 42 26 49Z" fill="#493c38" stroke="#2b2233" stroke-width="1.5"/>
<path d="M11 50 17 31M47 48 49 34" stroke="#2b2233" stroke-width="3" stroke-linecap="round"/>
<ellipse cx="37" cy="53" rx="8" ry="4" fill="#4b4542" stroke="#2b2233" stroke-width="1.5"/>
<path d="M29 52 33 49 39 49 44 52 41 55 34 56Z" fill="none" stroke="#aaa08b" stroke-width="3" stroke-linejoin="round"/>
<path d="M34 52 39 54M34 54 40 51" stroke="#2b2233" stroke-width="2" stroke-linecap="round"/>''')
save('campamento_vacio',s)
# Árbol removible con copa ramificada, sin puntas de estrella ni carita.
for name in ['arbol_removible','arbol_removible_trabajo']:
 s=source(name).replace('M10 37 17 25 15 18 27 21 31 9 38 20 50 15 48 27 57 36 48 44 19 45Z','M8 35 13 24 22 22 24 12 35 8 44 16 43 23 52 25 57 36 50 44 17 45Z')
 s=s.replace('M18 27 28 15l8 7 11-4','M14 27 23 25M28 15l6-3 6 6')
 if name=='arbol_removible':
  s=s.replace('M25 35 40 36 38 43 24 42Z','M23 36 42 37 40 45 23 44Z').replace('M27 36 31 41m4-5-4 6','M26 39 38 40')
 else:
  s=s.replace('</svg>','<path d="M23 36 39 37 38 41 23 40Z" fill="url(#amber)" stroke="#2b2233" stroke-width="1.5"/>\n</svg>')
 save(name,s)
for name in ['roca_removible','roca_removible_trabajo']:
 s=source(name).replace('M47 28 52 19l4 2-5 10Z', 'M44 29 51 17 57 20 50 34Z').replace('m49 27 3-4', 'M48 27 53 20')
 # La banda sigue la cara derecha, suficientemente ancha para persistir al reducir.
 s=re.sub(r'<path d="m47 31.*?/>','<path d="M44 30 54 26 57 38 47 42Z" fill="url(#amber)" stroke="#2b2233" stroke-width="2"/>',s)
 if name.endswith('trabajo'):
  s=s.replace('</svg>','<path d="M46 43 55 40 57 46 49 49Z" fill="url(#amber)" stroke="#2b2233" stroke-width="2"/>\n</svg>')
 save(name,s)
# Despejados: restos bajos, sin isla con borde que parezca bloquear la casilla.
for name in ['despejado_pradera','despejado_bosque','despejado_ruinas','despejado_desierto']:
 s=source(name)
 s=s.replace('stroke="#2b2233" stroke-width="1.5"','stroke="none" opacity=".65"')
 s=s.replace('opacity=".20"','opacity=".12"')
 save(name,s)
# Minas: fachada facetada, madera rellena y contorno sólido (antes tenían trazos degradados).
for name in ['mina','mina_activa','mina_agotada']:
 s=source(name)
 extra='''<path d="M8 35 17 18 24 18 17 35 16 51 8 52Z" fill="#b4ab96" opacity=".65"/>
<path d="M47 18 56 35V52L49 51 47 35 40 18Z" fill="#514e49" opacity=".5"/>
<path d="M16 33 22 23h20l6 10" fill="none" stroke="#eee2cb" stroke-width="1.5" stroke-linecap="round"/>'''
 # Facetas se insertan antes de la boca, para no tapar vagoneta ni cierre.
 at=s.index('<path d="M',s.index('</defs>'))
 end=s.index('/>',at)+2
 s=s[:end]+extra+s[end:]
 s=s.replace('stroke="url(#wood)"','stroke="#a67948"')
 if name=='mina':
  s=s.replace('stroke-width="5"','stroke-width="6"')
 if name=='mina_activa':
  s=s.replace('#f6f4c4','#dcebff').replace('#9fd7ce','#a0b6ce').replace('#4e8795','#506782')
 save(name,s)
# Bosque: copas separadas, distinto de un solo árbol removible; aserrado activo más grueso.
for name in ['bosque_explotable','bosque_explotable_activo','bosque_explotable_agotado']:
 s=source(name).replace('stroke="url(#wood)"','stroke="#a67948"')
 if name=='bosque_explotable':
  s=s.replace('M15 43 24 44 23 49 14 48Zm25-2 9 1-1 5-9-1Z','M13 43 26 44 25 51 13 50ZM38 42 51 43 50 50 38 49Z')
  s=s.replace('M16 44h6m21-1h6','M16 46h7M41 45h7')
  s=s.replace('</svg>','<path d="M14 29 18 28M25 20 28 18M39 16 42 19" fill="none" stroke="#c6d995" stroke-width="1.5" stroke-linecap="round"/>\n</svg>')
 if name=='bosque_explotable_activo':
  s=s.replace('stroke-width="8"','stroke-width="10"').replace('stroke-width="5.5"','stroke-width="7"')
 if name=='bosque_explotable_agotado':
  s=s.replace('stroke-width=".8"','stroke-width="1.2"')
 save(name,s)
# Íconos: siluetas simples y materiales; colección abandona las órbitas de átomo.
s=source('coleccion_disruptor','ui')
s=replace_body(s,'''<circle cx="32" cy="32" r="26" fill="#36434c" stroke="#2b2233" stroke-width="2"/>
<circle cx="32" cy="32" r="22" fill="url(#silver)" stroke="#2b2233" stroke-width="2"/>
<circle cx="32" cy="32" r="15" fill="#a67948" stroke="#2b2233" stroke-width="2"/>
<circle cx="32" cy="32" r="10" fill="url(#core)" stroke="#2b2233" stroke-width="2"/>
<path d="M28 9h8v8h-8ZM47 28h8v8h-8ZM28 47h8v8h-8ZM9 28h8v8H9Z" fill="#64737d" stroke="#2b2233" stroke-width="2" stroke-linejoin="round"/>
<path d="M19 17 25 13" stroke="#fffdf0" stroke-width="2" stroke-linecap="round"/>
<circle cx="32" cy="32" r="4" fill="#dcebff"/>''').replace('#d9f6ff','#dcebff').replace('#6aaec2','#a0b6ce').replace('#31516b','#506782')
save('coleccion_disruptor',s,'ui')
s=source('stat_resources','ui')
s=s.replace('<path d="m14 34 32-5m-24 1 32-4" fill="none" stroke="#8c6541" stroke-width="2.2"/>','')
s=s.replace('m18 39 25-4m-22 9 18-3','M13 40 24 42M29 18h20')
save('stat_resources',s,'ui')
s=source('demoledora','ui')
# Ariete a la derecha como la vista del resto del equipo; no parece otro cañón en la barra.
s=s.replace('<g stroke=', '<g transform="translate(64 0) scale(-1 1)" stroke=')
s=s.replace('M10 25h35l5 4H12Z','M8 23h36l6 7H10Z').replace('M8 22 3 27l5 6 6-4v-4Z','M7 20 2 27l5 9 8-5V24Z')
save('demoledora',s,'ui')
print('SVG refinados: 25; ids, lienzos y nombres conservados.')
