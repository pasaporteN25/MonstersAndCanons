"""Asigna el arte M23 a los datos sin modificar valores de balance."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
NAMES = 'basic cannon frost sniper fire multi burst tesla mortar'.split()
for name in NAMES:
    path = ROOT / 'data/towers' / f'{name}.tres'
    source = path.read_text(encoding='utf-8')
    source = source.replace(f'assets/sprites/towers/turret_{name}.svg', f'assets/sprites/towers/rendered/turret_{name}.png')
    for level in range(1, 4):
        source = source.replace(f'assets/sprites/towers/base_{level}.svg', f'assets/sprites/towers/rendered/base_{level}.png')
    if 'id="rendered_atlas"' not in source:
        resource = f'[ext_resource type="Texture2D" path="res://assets/sprites/towers/rendered/{name}_atlas.png" id="rendered_atlas"]\n\n'
        source = source.replace('[sub_resource', resource + '[sub_resource', 1)
        source = re.sub(r'(turret_texture = ExtResource\([^\n]+\))', r'\1\nturret_atlas = ExtResource("rendered_atlas")', source)
    if (ROOT / 'assets/sprites/projectiles/rendered' / f'{name}.png').exists():
        source = source.replace(f'assets/sprites/projectiles/{name}.svg', f'assets/sprites/projectiles/rendered/{name}.png')
    path.write_text(source, encoding='utf-8')
print('9 datos actualizados; balance intacto')
