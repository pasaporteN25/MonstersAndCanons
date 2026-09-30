---
paths:
  - "data/**"
---

# Reglas para los archivos de datos (`data/`)

- **Los números del juego viven acá** (constitución P2): vida, velocidad, daño, costos, oro, tiempos, porcentajes. Si un número aparece en el código, moverlo a un dato.
- **Enemigos y torres:** un `.tres` por cada uno (`EnemyData`, `TowerData` con sus 3 niveles). El `id` es **igual al nombre del archivo**, en minúsculas y sin espacios. Lo que se agrega a `data/enemies/` o `data/towers/` aparece solo en la Wiki. Ver `CONTENIDO.md`.
- **Niveles:** un `.json` por nivel en `data/levels/`, con las claves en castellano (`spec §7.8`). El id del nivel es el nombre del archivo. Se suma a `data/campaign.json`. Revisarlo con `godot --headless --path . -s tools/check_level.gd -- data/levels/level_XX.json` y balancearlo con el bot (`tools/balance_sim.gd`).
- **Artículos de la Wiki:** `data/wiki/*.json`; **no repiten números** que ya viven en otro dato (explican la regla y mandan a la entrada).
- **Los límites de RF-223** (oleadas, grupos, cantidades, tamaño del mapa…) valen para todos los niveles, oficiales o no.
- Un dato nuevo se **prueba**: `tests/test_content.gd` revisa todos los enemigos y torres; los niveles tienen tests de forma y de recorridos.
