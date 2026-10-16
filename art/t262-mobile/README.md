# T262 · Capturas y mediciones para el análisis mobile

Evidencia del informe [`specs/tareas/informes/T262-analisis-mobile.md`](../../specs/tareas/informes/T262-analisis-mobile.md). Todo se generó el 2026-10-16 **en escritorio** (Linux, GTX 1660 Super, Godot 4.7.2), no en un celular.

- `*_20x9.png`: la pantalla lógica de 1280 × 720 dentro del marco negro que agrega `stretch/aspect = keep` en un celular de 20:9 (1080 × 2400). `*_16x9.png`: la misma pantalla sin marco (16:9).
- `*_objetivos_*.png` y `partida_n07_infraestructura_*.png`: los controles medidos, con borde **rojo** si en el celular supuesto miden menos de 7,6 mm (48 dp) de lado y **verde** si llegan.
- `sizes_20x9.csv` (1080 × 2400, 405 ppi) y `sizes_16x9.csv` (720 × 1280, 294 ppi): un renglón por control visible con su tamaño virtual, en píxeles del celular y en mm.
- `probe_*.txt`: lo que imprimió `tools/mobile_probe.gd` (medidas y pruebas de toques A0 a G).
- `perf_*.txt`: las corridas de `tools/perf_levels.gd`, con `uptime` antes y después. `_20x9` es la primera tanda (ventana que eligió `DesktopWindow`, sin tope de torres) y `_b` la segunda (ventana de 1600 × 720 y 30 torres en los niveles 1 y 7).

Para regenerarlo, ver el §8 del informe. Los `.import` que crea Godot no se versionan (`.gitignore`).
