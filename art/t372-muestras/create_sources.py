"""Dibuja las fuentes vectoriales de la primera muestra; no escribe fuera de esta carpeta."""
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
# Banda periódica: 8 módulos de 160 px; primera/última columna idénticas.
band='<rect width="1280" height="160" fill="url(#iron)" stroke="none"/><path d="M0 5h1280M0 155h1280" stroke="#b17c43" stroke-width="6"/><path d="M0 10h1280" stroke="#edca8b" stroke-width="1"/>'
for x in range(80,1280,160):
    band+=f'<circle cx="{x}" cy="20" r="4" fill="url(#bronze)"/><circle cx="{x}" cy="140" r="4" fill="url(#bronze)"/>'
    band+=f'<g stroke="#657078" opacity=".22" fill="none"><circle cx="{x}" cy="80" r="22"/><circle cx="{x}" cy="80" r="10"/><path d="M{x-34} 80h12m44 0h12m-34-34v12m0 44v12"/></g>'
svg('news_header_plain.svg',1280,160,band)
(ROOT/'.gdignore').write_text('')
