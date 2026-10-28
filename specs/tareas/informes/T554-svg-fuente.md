# T554 · SVG fuente heredados: documento para decidir su borrado (D5)

**Fecha:** 2026-10-28. **Pedido por:** Lucas («un documento mostrando qué assets son, probablemente los borremos»). **Refs:** T538 (H3, H4, D5), T551 (`KNOWN_UNUSED`). **Alcance:** solo documentos; **no se borró ni se movió ningún archivo**.

La versión visual, con miniaturas, la imagen vigente de cada uno, filtros y casillas de decisión, está en `art/t554-svg-fuente/revision.html` (autocontenida, se abre en el navegador de PC o celular).

## Método

- Lista: los 50 SVG de la sección «SVG fuente heredados» de `KNOWN_UNUSED` en `tests/test_resource_audit.gd`.
- Por cada uno se buscó en todos los archivos de texto versionados (código, `data/`, escenas, tests, `tools/`, `art/`, documentos): su ruta `res://` o relativa completa, su nombre de archivo y su `uid`. Ningún SVG tiene `uid` citado en ningún lado.
- Se leyó `MapDrawings` y `MapThemes` para saber con qué dibujo vigente se asocia hoy cada clave de la leyenda (`tronco`, `estatua`, etc.): las claves siguen en uso, pero apuntan a PNG renderizados, no al SVG.
- Las miniaturas se renderizaron con Godot (`Image.load_svg_from_string`) y se embebieron como data URI.
- Recomendación: **BORRAR** = reemplazado y nadie lo lee; **MOVER A art/** = fuente de algo vivo; **REVISAR** = lo lee un script de `art/` o no se verificó el reemplazo. Se fue conservador.

## Totales por recomendación

| Recomendación | Archivos | Bytes |
|---|---:|---:|
| BORRAR | 44 | 57.403 |
| MOVER | 0 | 0 |
| REVISAR | 6 | 12.588 |
| **Total** | **50** | **69.991** |

Los 50 `.import` de acompañamiento se irían con ellos. Ahorro en el `.pck`: despreciable (unos 68 KB de fuente); el motivo de borrarlos es la claridad, no el tamaño.

## Hallazgos generales

1. **Ningún código del juego los usa.** Ninguno figura en `scripts/`, `scenes/`, `data/`, `tools/` ni `tests/` (salvo la lista `KNOWN_UNUSED`). Las claves de la leyenda de mapas que comparten nombre (`tronco`, `columna`, `estatua`, `mina`…) apuntan a PNG renderizados.
2. **Ningún PNG vigente sale de estos SVG.** Los PNG de enemigos, torres y proyectiles vienen de hojas generadas (`art/redesign-m23/sources`, T171, M43…) y `tools/prepare_tower_sprites.gd` recorta esas hojas, no estos SVG. Por eso no se recomienda MOVER ninguno.
3. **Lectores históricos en `art/`.** `art/prototypes/full-pass/render.gd` lee 11 de ellos (torres y `flame.svg`); `art/t261-ground/refine_vectors.py` lee `flores.svg`; `art/t249-mejoras/asset_paths.json` (que leen `render_contact.gd` y `context_gallery.gd`) lista `bosque_explotable`, `mina`, `campamento_vacio`, `poste_cintas` y `demoledora`. Los manifiestos de T260 registran 13 con sus hashes antes/después. Borrarlos no rompe el juego, pero esas herramientas históricas dejarían de correr.
4. **Documentos que los nombran:** `CONTENIDO.md` usa `troll.svg` como ejemplo de textura en la tabla de enemigos (conviene cambiarlo a un PNG); `specs/05-guia-de-arte.md` §8 dice que los SVG de `enemies/` son «fuentes editables de algunos rediseños» (habría que ajustarlo); `CHANGELOG.md`, `specs/01-spec.md`, `02-plan-tecnico.md` y `04-decisiones.md` los nombran como historia.
5. **Falso positivo evitado:** `tools/make_icon.gd` precarga `turret_cannon.svg`, `base_3.svg` y `boss.svg` (no están en esta lista); la búsqueda por nombre «cannon.svg» lo confundía con `projectiles/cannon.svg`, que no se usa.
6. **`demoledora.svg`:** no se pudo asociar con certeza a su reemplazo (el botón móvil de demoler usa `assets/ui/mobile_demolish.svg`); por eso va a REVISAR.
7. Si se borran, hay que sacarlos de `KNOWN_UNUSED` y ajustar `test_known_unused_svg_sources_are_listed`, que exige más de 40 SVG listados (borrar 44 lo haría fallar).

## Tabla completa

| Categoría | Archivo | Bytes | Recomendación | Reemplazo vigente | Lo cita todavía |
|---|---|---:|---|---|---|
| Enemigos | `enemies/armored.svg` | 2.729 | BORRAR | PNG renderizado (`armored.png`, más su atlas `armored_walk.png`), declarado en `data/enemies/armored.tres`. | 9 registros de validación |
| Enemigos | `enemies/fast.svg` | 2.455 | BORRAR | PNG renderizado (`fast.png`, más su atlas `fast_walk.png`), declarado en `data/enemies/fast.tres`. | 9 registros de validación |
| Enemigos | `enemies/guardian.svg` | 2.255 | BORRAR | PNG renderizado (`guardian.png`, más su atlas `guardian_walk.png`), declarado en `data/enemies/guardian.tres`. | `specs/03-tareas.md`; 9 registros de validación |
| Enemigos | `enemies/healer.svg` | 2.164 | BORRAR | PNG renderizado (`healer_m43.png`, más su atlas `healer_m43_walk.png`), declarado en `data/enemies/healer.tres`. | `specs/03-tareas.md`; 9 registros de validación |
| Enemigos | `enemies/mirror.svg` | 1.885 | BORRAR | PNG renderizado (`mirror.png`, más su atlas `mirror_walk.png`), declarado en `data/enemies/mirror.tres`. | `specs/03-tareas.md`; 9 registros de validación |
| Enemigos | `enemies/normal.svg` | 2.608 | BORRAR | PNG renderizado (`normal.png`, más su atlas `normal_walk.png`), declarado en `data/enemies/normal.tres`. | 9 registros de validación |
| Enemigos | `enemies/shaman.svg` | 2.172 | BORRAR | PNG renderizado (`shaman.png`, más su atlas `shaman_walk.png`), declarado en `data/enemies/shaman.tres`. | `specs/03-tareas.md`; 9 registros de validación |
| Enemigos | `enemies/spider.svg` | 2.528 | BORRAR | PNG renderizado (`spider.png`, más su atlas `spider_walk.png`), declarado en `data/enemies/spider.tres`. | 9 registros de validación |
| Enemigos | `enemies/spiderling.svg` | 2.327 | BORRAR | PNG renderizado (`spiderling.png`, más su atlas `spiderling_walk.png`), declarado en `data/enemies/spiderling.tres`. | 9 registros de validación |
| Enemigos | `enemies/tank.svg` | 2.575 | BORRAR | PNG renderizado (`tank.png`, más su atlas `tank_walk.png`), declarado en `data/enemies/tank.tres`. | 9 registros de validación |
| Enemigos | `enemies/thief.svg` | 614 | BORRAR | PNG renderizado (`thief_m43.png`, más su atlas `thief_m43_walk.png`), declarado en `data/enemies/thief.tres`. | 9 registros de validación |
| Enemigos | `enemies/troll.svg` | 2.690 | BORRAR | PNG renderizado (`troll.png`, más su atlas `troll_walk.png`), declarado en `data/enemies/troll.tres`. | `CONTENIDO.md`; 9 registros de validación |
| Torres | `towers/base_1.svg` | 1.009 | BORRAR | PNG renderizado `towers/rendered/base_1.png`, declarado en `data/towers/*.tres`. | lee: `art/prototypes/full-pass/render.gd`; `art/prototypes/towers-3d/README.md`, `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Torres | `towers/base_2.svg` | 1.060 | BORRAR | PNG renderizado `towers/rendered/base_2.png`, declarado en `data/towers/*.tres`. | lee: `art/prototypes/full-pass/render.gd`; `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Torres | `towers/mechanical_standard.svg` | 1.210 | BORRAR | PNG renderizado `mechanical_standard_m43.png`. | 9 registros de validación |
| Torres | `towers/turret_basic.svg` | 918 | BORRAR | PNG renderizado `towers/rendered/turret_basic.png`, declarado en `data/towers/*.tres`. | lee: `art/prototypes/full-pass/render.gd`; `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Torres | `towers/turret_burst.svg` | 1.339 | BORRAR | PNG renderizado `towers/rendered/turret_burst.png`, declarado en `data/towers/*.tres`. | lee: `art/prototypes/full-pass/render.gd`; `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Torres | `towers/turret_fire.svg` | 1.125 | BORRAR | PNG renderizado `towers/rendered/turret_fire.png`, declarado en `data/towers/*.tres`. | lee: `art/prototypes/full-pass/render.gd`; `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Torres | `towers/turret_frost.svg` | 829 | BORRAR | PNG renderizado `towers/rendered/turret_frost.png`, declarado en `data/towers/*.tres`. | lee: `art/prototypes/full-pass/render.gd`; `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Torres | `towers/turret_mortar.svg` | 1.187 | BORRAR | PNG renderizado `towers/rendered/turret_mortar.png`, declarado en `data/towers/*.tres`. | lee: `art/prototypes/full-pass/render.gd`; `art/prototypes/towers-3d/make_full_set.py`, `specs/02-plan-tecnico.md`, `specs/03-tareas.md`; 9 registros de validación |
| Torres | `towers/turret_multi.svg` | 1.297 | BORRAR | PNG renderizado `towers/rendered/turret_multi.png`, declarado en `data/towers/*.tres`. | lee: `art/prototypes/full-pass/render.gd`; `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Torres | `towers/turret_sniper.svg` | 972 | BORRAR | PNG renderizado `towers/rendered/turret_sniper.png`, declarado en `data/towers/*.tres`. | lee: `art/prototypes/full-pass/render.gd`; `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Torres | `towers/turret_tesla.svg` | 1.101 | BORRAR | PNG renderizado `towers/rendered/turret_tesla.png`, declarado en `data/towers/*.tres`. | lee: `art/prototypes/full-pass/render.gd`; `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Proyectiles | `projectiles/basic.svg` | 621 | BORRAR | PNG renderizado `projectiles/rendered/basic.png`, declarado en `data/towers/*.tres`. | `art/prototypes/full-pass/render.gd`, `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Proyectiles | `projectiles/burst.svg` | 396 | BORRAR | PNG renderizado `projectiles/rendered/burst.png`, declarado en `data/towers/*.tres`. | `art/prototypes/full-pass/render.gd`, `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Proyectiles | `projectiles/cannon.svg` | 252 | BORRAR | PNG renderizado `projectiles/rendered/cannon.png`, declarado en `data/towers/*.tres`. | `art/prototypes/full-pass/render.gd`, `art/prototypes/towers-3d/README.md`, `art/prototypes/towers-3d/make_full_set.py`, `specs/03-tareas.md`; 9 registros de validación |
| Proyectiles | `projectiles/fire.svg` | 652 | BORRAR | PNG renderizado `projectiles/rendered/fire.png`, declarado en `data/towers/*.tres`. | `art/prototypes/full-pass/render.gd`, `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Proyectiles | `projectiles/frost.svg` | 419 | BORRAR | PNG renderizado `projectiles/rendered/frost.png`, declarado en `data/towers/*.tres`. | `art/prototypes/full-pass/render.gd`, `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Proyectiles | `projectiles/mortar.svg` | 549 | BORRAR | PNG renderizado `projectiles/rendered/mortar.png`, declarado en `data/towers/*.tres`. | `art/prototypes/full-pass/render.gd`, `art/prototypes/towers-3d/make_full_set.py`, `specs/02-plan-tecnico.md`, `specs/03-tareas.md`; 9 registros de validación |
| Proyectiles | `projectiles/multi.svg` | 493 | BORRAR | PNG renderizado `projectiles/rendered/multi.png`, declarado en `data/towers/*.tres`. | `art/prototypes/full-pass/render.gd`, `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Proyectiles | `projectiles/sniper.svg` | 558 | BORRAR | PNG renderizado `projectiles/rendered/sniper.png`, declarado en `data/towers/*.tres`. | `art/prototypes/full-pass/render.gd`, `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Proyectiles | `projectiles/tesla.svg` | 447 | BORRAR | PNG renderizado `projectiles/rendered/tesla.png`, declarado en `data/towers/*.tres`. | `art/prototypes/full-pass/render.gd`, `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Mapa | `map/bloque.svg` | 1.105 | BORRAR | PNG renderizado: bloque por `MapThemes.BLOCK` (`m79/block_01/02.png`). | `art/m79-inventario/inventario.md`, `art/t260-decoration/manifest.json`; 12 registros de validación |
| Mapa | `map/bosque_explotable.svg` | 1.669 | REVISAR | PNG renderizado: clave `bosque_explotable` en `MapDrawings` (`forest_idle/active/depleted.png`). | `art/t220-extraccion/manifest.json`, `art/t220-extraccion/prompts.md`, `art/t249-mejoras/asset_paths.json`, `art/t249-mejoras/manifest.json`, `art/t267a/manifest.json`, `art/t267a/sample_decor.gd` (+2); 11 registros de validación |
| Mapa | `map/bush.svg` | 935 | BORRAR | PNG renderizado: `MapThemes.BUSH` (`rendered/bush.png`). | `art/t260-decoration/manifest.json`; 11 registros de validación |
| Mapa | `map/cactus.svg` | 1.641 | BORRAR | PNG renderizado: `MapThemes.CACTUS` (`m79/cactus_02.png`). | `art/m79-inventario/inventario.md`, `art/t260-decoration/manifest.json`, `specs/01-spec.md`, `specs/tareas/informes/T267a-propuesta-assets.md`; 12 registros de validación |
| Mapa | `map/campamento_vacio.svg` | 1.956 | REVISAR | PNG renderizado: clave `campamento_vacio` (`m79/empty_camp_02.png`, T524). | `art/m79-inventario/inventario.md`, `art/t218-senales/REPORTE.md`, `art/t218-senales/concepto.html`, `art/t218-senales/manifest.json`, `art/t249-mejoras/asset_paths.json`, `art/t249-mejoras/manifest.json` (+2); 13 registros de validación |
| Mapa | `map/columna.svg` | 1.390 | BORRAR | PNG renderizado: `MapThemes.COLUMN` (`m79/column_01/02.png`). | `art/m79-inventario/inventario.md`, `art/t260-decoration/manifest.json`; 12 registros de validación |
| Mapa | `map/estatua.svg` | 1.686 | BORRAR | PNG renderizado: clave `estatua` (`statue_*_moss.png` y `statue_*_frost.png`). | `art/m79-inventario/inventario.md`, `art/t260-decoration/manifest.json`, `art/t267a/build_samples.py`, `art/t267a/contact.gd`, `art/t267a/manifest.json`, `art/t267a/sample_decor.gd` (+5); 13 registros de validación |
| Mapa | `map/flores.svg` | 4.591 | REVISAR | PNG renderizado: tres variantes `cantaro/flora_*.png` (T542). | lee: `art/t261-ground/refine_vectors.py`; `CHANGELOG.md`, `art/t260-decoration/manifest.json`, `art/t261-ground/manifest.json`, `art/t540-flora-current-style/README.md`, `art/t540-flora-current-style/prompts.md`, `specs/01-spec.md` (+8); 13 registros de validación |
| Mapa | `map/gate.svg` | 1.791 | BORRAR | PNG renderizado: `level_decor.gd` (`rendered/gate.png`). | 9 registros de validación |
| Mapa | `map/helecho.svg` | 1.292 | BORRAR | PNG renderizado: `MapThemes.FERN` (`rendered/fern.png`). | `art/t260-decoration/manifest.json`, `specs/03-tareas.md`, `specs/tareas/informes/T434-auditoria-activos-visuales.md`; 12 registros de validación |
| Mapa | `map/mina.svg` | 1.299 | REVISAR | PNG renderizado: clave `mina` (`mine_idle/active/depleted.png`). | `art/t220-extraccion/manifest.json`, `art/t220-extraccion/prompts.md`, `art/t233-final/prompts.md`, `art/t249-mejoras/asset_paths.json`, `art/t249-mejoras/manifest.json`, `art/t267a/manifest.json` (+4); 11 registros de validación |
| Mapa | `map/poste_cintas.svg` | 1.760 | REVISAR | PNG renderizado: clave `poste_cintas` (`banner_post_enemy.png` y `banner_post_player.png`). | `art/t218-senales/REPORTE.md`, `art/t218-senales/concepto.html`, `art/t218-senales/manifest.json`, `art/t249-mejoras/asset_paths.json`, `art/t249-mejoras/manifest.json`, `art/t260-decoration/manifest.json` (+2); 13 registros de validación |
| Mapa | `map/rock_a.svg` | 675 | BORRAR | PNG renderizado: `MapThemes.ROCK_A` (`rendered/rock_a.png`). | `art/t219-removibles/prompts.md`, `art/t260-decoration/manifest.json`; 11 registros de validación |
| Mapa | `map/rock_b.svg` | 682 | BORRAR | PNG renderizado: `MapThemes.ROCK_B` (`rendered/rock_b.png`). | `art/t260-decoration/manifest.json`; 11 registros de validación |
| Mapa | `map/tree.svg` | 931 | BORRAR | PNG renderizado: `MapThemes.TREE` (`rendered/tree.png`). | `art/t219-removibles/prompts.md`, `art/t260-decoration/manifest.json`; 11 registros de validación |
| Mapa | `map/tronco.svg` | 1.292 | BORRAR | PNG renderizado: `MapThemes.LOG` (`rendered/log.png`). | `art/t260-decoration/manifest.json`, `specs/03-tareas.md`, `specs/tareas/informes/T434-auditoria-activos-visuales.md`; 12 registros de validación |
| Efectos | `effects/flame.svg` | 547 | BORRAR | PNG `effects/rendered/flame.png` (lo precargan `enemy_shape.gd` y `fire_impact_effect.gd`). | lee: `art/prototypes/full-pass/render.gd`; `art/prototypes/towers-3d/make_full_set.py`; 9 registros de validación |
| Interfaz | `ui/demoledora.svg` | 1.313 | REVISAR | No se encontró un reemplazo claro. El botón de demoler del móvil usa `assets/ui/mobile_demolish.svg`; la pestaña de Infraestructura de escritorio no se pudo asociar a este dibujo. | `art/t221-iconos/manifest.json`, `art/t221-iconos/prompts.md`, `art/t249-mejoras/asset_paths.json`, `art/t249-mejoras/manifest.json`, `specs/02-plan-tecnico.md`, `specs/tareas/T221-arte-iconos.md`; 10 registros de validación |

## Qué falta

- La decisión de Lucas (casillas del HTML). Con ella: tarea aparte para borrar/mover, sacar de `KNOWN_UNUSED`, corregir `CONTENIDO.md` y la guía de arte, y correr GUT.
- No se verificó que algún archivo exterior al repositorio (builds viejas, otros checkouts) los lea.
