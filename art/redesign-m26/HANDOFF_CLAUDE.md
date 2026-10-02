# Fondos y diseños aprobados · entrega de Codex

Lucas aprobó las cinco criaturas de M25 y autorizó el rediseño de fondos sin otra ronda previa de selección. Este paquete deja recursos y capturas listos para integrar; no modifica el juego de producción.

## Fondos

- `textures/ground_pradera.png`, `ground_desierto.png`, `ground_nieve.png`, `ground_volcan.png`, `ground_bosque.png`, `ground_pantano.png`, `ground_ruinas.png`: siete suelos opacos de 256×256. Pintar cada casilla a 64×64, conservando los IDs y atributos del TileSet.
- `textures/path.png`: tierra compactada y piedritas, un material de camino común opaco de 256×256. Su borde se resuelve según vecinos de camino, no está horneado en cada tile.
- `props/rock_a.png`, `rock_b.png`, `tree.png`, `bush.png`, `gate.png`: RGBA de 128×128, centrados, suelo en (64,116). Dibujar al tamaño de casilla actual, con filtro lineal y mipmaps. No agrandar árboles sobre casillas construibles vecinas.

Las texturas tienen lados opuestos con colores idénticos; el empaquetador suaviza una franja de 16 px en los bordes conservando el centro. Las fuentes originales quedan intactas. La repetición visual se revisó en mosaico de 4×4 y en un mapa real.

Al integrar en LevelDecor, usar las texturas para suelo y camino en vez de taparlas con `fill_grass`/`fill_path` de la paleta o sumar todas las marcas geométricas anteriores. Mantener señales de bordes y la grilla de construcción como capas opcionales. En `MapThemes.BLOCKED`, sustituir las cinco constantes correspondientes por los PNG; conservar la elección determinista por hash de casilla y los demás objetos temáticos existentes.

El catálogo de objetos especiales de desierto, nieve, volcán, pantano y ruinas no se rediseñó completo. Cactus, pinos, huesos, columnas, etc. conservan su arte anterior hasta otra tanda. Las cuatro superficies de leyenda (agua, hielo, lava y barro) también conservan sus reglas y arte actuales. Las rocas/árbol/arbusto nuevos cubren la pradera y los lugares donde esos objetos se reutilizan, especialmente bosque.

Puerta: reemplazar solo la representación de salida interior existente; conservar sus casillas y orientación lógica. La fuente tiene el hueco del arco con transparencia, sin puerta cerrada ni energía de portal.

## Monstruos aprobados

`monsters/armored.png`, `troll.png`, `flyer.png`, `spider.png`, `spiderling.png`: copias RGBA 256×256 obtenidas de los conceptos aprobados de M25 mediante `tools/prepare_monster_sprites.gd`. Cuerpo máximo al 63,4 %, pies al 74,55 %. Mantener sus IDs, cifras y habilidades, incluyendo aparición de crías y condición aérea.

Son una sola vista con luz propia. No reflejarlos al caminar; respetar el campo `flip_when_walking_left = false` ya agregado en M24 hasta que reciban cuadros por dirección. No confundirlos con los atlas de locomoción de Normal/Rápido/Tanque, entregados en `art/redesign-m25/atlases/`.

## Escenas de revisión

`capture_backgrounds.tscn` prepara instancias temporales del Game y MainMenu reales: conserva la grilla, rutas, botones e interfaz; cambia solamente el dibujado local del fondo. Guarda `before.png`, `map_preview.png` y `menu_preview.png`. Los tres monstruos del mapa son retratos estáticos para comparar contraste; no es una corrida de combate.

`preview_decor.gd` es referencia visual, no reemplazo terminado de LevelDecor: solo muestra la pradera y no cubre leyendas, todas las puertas ni decoraciones específicas de cada tema. Integrar desde el sistema actual y probar partida, editor de mapas y fondo del menú. No copiar este script encima del de producción.

`textures/`, `props/`, `monsters/` y `sources/` llevan `.gdignore`: copiar los recursos seleccionados a `assets/`, importarlos y después cambiar referencias. No usar rutas de `art/` en datos de producción o exportaciones.
