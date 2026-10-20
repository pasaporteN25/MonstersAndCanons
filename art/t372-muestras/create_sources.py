"""Dibuja las fuentes vectoriales de las muestras; no escribe fuera de esta carpeta."""
from pathlib import Path
import math
ROOT=Path(__file__).resolve().parent
DEFS='''<defs><linearGradient id="iron" x2=".25" y2="1"><stop stop-color="#657078"/><stop offset=".5" stop-color="#343b42"/><stop offset="1" stop-color="#191c23"/></linearGradient><linearGradient id="bronze" x2=".25" y2="1"><stop stop-color="#edca8b"/><stop offset=".5" stop-color="#b17c43"/><stop offset="1" stop-color="#67462e"/></linearGradient><linearGradient id="paper" x2=".25" y2="1"><stop stop-color="#f4ecd8"/><stop offset=".5" stop-color="#d7c8a5"/><stop offset="1" stop-color="#998665"/></linearGradient></defs>'''
def svg(name,w,h,body):
    defs=DEFS.replace('x2=".25"', 'x2="0"') if w==1280 else DEFS
    (ROOT/'sources'/name).write_text(f'<!-- Muestra T372 de hierro y bronce, luz arriba a la izquierda; sin texto. -->\n<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{defs}<g stroke="#2b2233" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">{body}</g></svg>')
medal='<circle cx="48" cy="48" r="45" fill="url(#bronze)"/><circle cx="48" cy="48" r="37" fill="url(#iron)"/><path d="M16 29 A38 38 0 0 1 48 10" fill="none" stroke="#f4ecd8" stroke-width="1.4"/>'
for x,y in [(48,7),(89,48),(48,89),(7,48)]:medal+=f'<circle cx="{x}" cy="{y}" r="2.5" fill="url(#iron)"/>'
map_body='''<path d="m24 27 16-5 16 6 16-4v46l-16 4-16-6-16 5Z" fill="url(#paper)"/><path d="M40 23v44m16-38v43" opacity=".6" fill="none"/><path d="M29 57c17 1 7-21 24-20 10 1 4 15 11 16" fill="none" stroke="#67462e" stroke-width="3"/><path d="m59 57 9-9m-9 0 9 9" fill="none" stroke="#b17c43" stroke-width="3"/><path d="m28 30 9-3" stroke="#f4ecd8" fill="none"/>'''
tower_body='''<path d="M23 67h50l-5 8H28Z" fill="url(#bronze)"/><path d="m33 65 4-20h21l8 20Z" fill="url(#iron)"/><path d="m30 34 31-6 8 15-34 7Z" fill="url(#iron)"/><ellipse cx="65" cy="35" rx="7" ry="10" transform="rotate(-22 65 35)" fill="url(#bronze)"/><ellipse cx="65" cy="35" rx="3" ry="6" transform="rotate(-22 65 35)" fill="url(#iron)"/><circle cx="46" cy="50" r="6" fill="url(#bronze)"/><path d="m32 35 25-5" stroke="#f4ecd8" fill="none"/><path d="M34 70v3m13-3v3m13-3v3" stroke="#f4ecd8" stroke-width="3"/>'''
svg('news_icon_map.svg',96,96,medal+map_body)
svg('news_icon_tower.svg',96,96,medal+tower_body)
# Se conserva el medallón aprobado, sin variaciones entre los ocho íconos.
new_bodies = {
    'monster': '''<path d="M32 44Q20 37 24 23l15 11 13-2Q56 22 69 22l-7 19 9 9-4 14-15 10-22-9 3-12-8-6Z" fill="url(#bronze)"/><path d="m48 45 9-2-4 7Z" fill="url(#paper)"/><path d="m61 55 8 1-6 7-13 1" fill="url(#iron)"/><path d="m58 57 2 5 3-5" fill="url(#paper)"/><path d="m32 39 8-3 10-1" stroke="#f4ecd8" fill="none"/>''',
    'siege': '''<path d="M33 69V30h8v8h9v-8h8v8h9v-8h7v39Z" fill="url(#paper)"/><path d="M34 51h39M48 39v12m12 0v18" fill="none"/><path d="M24 68 53 43l6 7-29 25Z" fill="url(#bronze)"/><path d="m45 43 19-6-5 19Z" fill="url(#bronze)"/><path d="m27 67 23-20" stroke="#f4ecd8" fill="none"/><path d="m65 46 6-3m-6 11 7 3" stroke="#edca8b" fill="none"/>''',
    'editor': '''<rect x="24" y="25" width="46" height="46" rx="2" fill="url(#paper)"/><path d="M39 26v44m15-44v44M25 40h44M25 55h44" fill="none"/><path d="M40 41h13v13H40Z" fill="url(#bronze)"/><path d="m40 58 25-30 5 4-25 30Z" fill="url(#bronze)"/><path d="m38 52 14 12-8 10-12-1-2-11Z" fill="url(#iron)"/><path d="m45 53 19-23" stroke="#f4ecd8" fill="none"/>''',
    'mobile': '''<path d="M40 58h11l3 10H37Z" fill="url(#bronze)"/><rect x="22" y="27" width="48" height="33" rx="3" fill="url(#bronze)"/><path d="M27 32h38v22H27Z" fill="url(#iron)"/><path d="M33 69h26" stroke="#edca8b" stroke-width="4"/><rect x="55" y="40" width="21" height="36" rx="4" fill="url(#bronze)"/><path d="M59 46h13v21H59Z" fill="url(#paper)"/><path d="M28 33h29" stroke="#f4ecd8" fill="none"/><path d="M64 71h3" stroke="#f4ecd8" fill="none"/>''',
    'book': '''<path d="M21 32q14-6 27 1 13-7 27-1v38q-14-5-27 1-13-6-27-1Z" fill="url(#bronze)"/><path d="M24 28q12-5 24 3 12-8 24-3v36q-12-4-24 3-12-7-24-3Z" fill="url(#paper)"/><path d="M48 31v36" fill="none"/><path d="m28 34 11 1m17 7 10-2m-10 9 10-2m-37-2 10 2m-10 5 10 2" stroke="#998665" fill="none"/><path d="m27 30 12 1" stroke="#f4ecd8" fill="none"/>''',
    'upgrade': '''<path d="m48 54 5 9 12-4-6 10 8 5-14 1-5 6-5-6-14-1 8-5-6-10 12 4Z" fill="url(#bronze)"/><path d="M39 62V43H27l21-22 21 22H57v19Z" fill="url(#paper)"/><path d="m35 40 13-14 11 12" stroke="#f4ecd8" fill="none"/>''',
}
for name, body in new_bodies.items():
    svg('news_icon_' + name + '.svg', 96, 96, medal + body)
# Banda periódica: 8 módulos de 160 px; primera/última columna idénticas.
band='<rect width="1280" height="160" fill="url(#iron)" stroke="none"/><path d="M0 5h1280M0 155h1280" stroke="#b17c43" stroke-width="6"/><path d="M0 10h1280" stroke="#edca8b" stroke-width="1"/>'
for x in range(80,1280,160):
    band+=f'<circle cx="{x}" cy="20" r="4" fill="url(#bronze)"/><circle cx="{x}" cy="140" r="4" fill="url(#bronze)"/>'
    band+=f'<g stroke="#657078" opacity=".22" fill="none"><circle cx="{x}" cy="80" r="22"/><circle cx="{x}" cy="80" r="10"/><path d="M{x-34} 80h12m44 0h12m-34-34v12m0 44v12"/></g>'
svg('news_header_plain.svg',1280,160,band)
(ROOT/'.gdignore').write_text('')
