# Auditoría integral de tamaño y código sin uso · Monsters & Canons (TDv1)

**Contexto.** Lucas pidió una auditoría de solo lectura para reducir el tamaño del juego, sin borrar nada. Este documento es el informe. Si Lucas lo aprueba, el "plan" de abajo se convierte en tareas chicas. **No se editó, no se borró, no se corrió Godot ni GUT, no hubo commit.**

---

## 0. Baseline reproducible

- **Commit analizado:** `86911ee3d46f` (= `origin/main`, 2026-10-27 02:17 -0300), rama `feature/t538-auditoria-integral`, árbol limpio. El worktree no tiene `.godot/`.
- **Comandos de inventario:**
  - `git ls-files -z | xargs -0 stat -c '%s %n'` agrupado por carpeta y por extensión.
  - `git rev-list --objects --all | git cat-file --batch-check` para el historial.
  - `file` y `python3 -I`, leyendo solo encabezados PNG/WebP/WAV.
  - `grep` de todos los `.import`.
- **Caché de importación (medida, de otro worktree).** Leí `.godot/imported` del worktree `t537-gallery-art-review`, que está en `8309ac0`, del 2026-10-27, casi igual a este commit.
  - Asocié cada archivo con `md5("res://"+ruta)`, que es el hash que Godot pone en el nombre del `.ctex`. Lo verifiqué: `md5("res://Capturas/T464-ver-todo-pc.png") = 765dcc79…`, igual al archivo del caché.
- **Limitaciones:**
  - No hay export medido.
  - El caché `.ctex` aproxima lo que va al `.pck`, pero no es igual: no incluye compresión del PCK, ni scripts, ni el motor.
  - El caché de la carpeta principal `~/Documentos/Proyectos/TDv1` está en un commit viejo (`fcf467e`, 2026-10-07) y no se usó.

| Capa | Archivos | Bytes medidos | Nota |
|---|---|---|---|
| Repo versionado (total) | 4675 | ~988 MB | — |
| `art/` | 2428 | 783.900.196 | excluido del export (`art/*`) |
| `Capturas/` | 257 PNG | 138.256.832 | **no excluido** y sin `.gdignore` |
| `assets/` | 629 | 74.954.695 | exportado |
| `specs/`, `addons/`, `tests/`, `scenes/`, `scripts/`, `tools/`, `data/` | — | 3,5 MB / 2,5 / 1,55 / 0,73 / 0,46 / 0,36 / 0,16 | el código pesa poco |
| Historial git (blobs en disco) | — | `art` 791 MB, `Capturas` 141 MB, `assets` 66 MB | pack de 823 MiB |
| Caché `.godot` del worktree t537 | 1872 importados | 901.385.522 | de eso, `art` 670 MB, `Capturas` 170 MB y `assets` ~53 MB |
| Caché de `Capturas/` | 257/257 importadas | **170.054.036** | lossless con mipmaps |
| Caché de `assets/` | ~310 | ~53 MB | detalle en §3 |

**Conclusión ejecutiva.**
- **Mayor oportunidad:** casi seguro el export de hoy mete ~170 MB de capturas de documentación. Se arregla con una exclusión, sin tocar arte ni código.
- **Segunda oportunidad:** las franjas (15,8 MB en caché) y otras imágenes grandes guardadas sin pérdida. Cambiarlas es una decisión visual de Lucas.
- **Archivos muertos en `assets/`:** suman ~1,95 MB de fuente, y el 90 % es un solo PNG.
- **Código:** el código muerto no pesa nada en tamaño (decenas de KB). Limpiarlo es mantenimiento, no reducción.
- **Repo:** pesa por `art/` y su historial. Achicarlo exige reescribir la historia, lo que es decisión de Lucas.

| Oportunidad | Impacto en el export | Riesgo | Certeza |
|---|---|---|---|
| Excluir `Capturas/` | **alto**: ~138–170 MB | bajo | probable (falta un export) |
| Franjas con pérdida, como la intro | medio: ~8–12 MB (rango) | medio, visual | hipótesis |
| `rammer.png` heredado | bajo: 1,76–2,04 MB | bajo | confirmado sin referencias |
| SVG fuente sin uso en `assets/` | bajo: <1,5 MB (rango) | bajo/medio | confirmado sin referencias directas |
| Música a OGG | bajo: ~1,5–2 MB | bajo/medio, audio | hipótesis |
| `.gdignore` en `art/` | 0 MB en el export; −670 MB de caché y menos tiempo de import en CI/editor | medio, por herramientas | probable |

---

## 1. Hallazgos numerados

**H1 · Prioridad alta · Probable · Export / `Capturas/`.**
- **Evidencia:**
  - `export_presets.cfg:11,51,91`: `export_filter="all_resources"` y `exclude_filter="tests/*, tools/*, specs/*, addons/gut/*, art/*"`. `Capturas/` no aparece.
  - No hay `Capturas/.gdignore` (`find -name .gdignore`).
  - `git check-ignore` no la ignora.
  - En t537, las 257 PNG están importadas como textura: 170.054.036 B de `.ctex`, contra 138.256.832 B de fuente.
- **Uso real:**
  - Ningún archivo de `scripts/`, `scenes/`, `data/` ni `project.godot` la nombra.
  - Sí la usan `README.md:37,41` (3 imágenes, `T520-*`), `ONBOARDING.md` y READMEs de `art/`.
  - `tools/capture_campaign_map` escribe ahí con `Image.save_png`.
- **Por qué es seguro:** excluirla del export o ignorarla en el import no toca ni el README de GitHub ni las herramientas que escriben PNG.
- **Ahorro:** entre ~138 MB (fuente) y ~170 MB (caché), según cómo empaquete Godot. **No medido en un export.**
- **Siguiente verificación:** exportar Linux antes y después en una carpeta temporal y comparar tamaños y la lista del PCK (`--export-pack` + listado). Confirmar que `ONBOARDING.md:123` (`~110 MB`) y `:215` (`~75 MB`) quedaron viejos.

**H2 · Alta para CI y editor (sin efecto en el export) · Probable · `art/` sin `.gdignore` total.**
- **Evidencia:**
  - Solo 30 subcarpetas de `art/` tienen `.gdignore`.
  - 1304 de 1731 archivos binarios de `art/` se importan: 670.022.630 B de caché.
  - Además hay 26 `.translation` versionados en `art/t262-mobile`, `t263-mejora-torre`, `t264-zoom-compra` y `t276-mobile`. Son restos del importador al leer CSV de medición: el `.gitignore` cubre `*.import` y `*.log` de `art/`, pero no `*.translation`.
- **Riesgo:** muchos scripts de `art/*/capture.gd` y de `tools/` hacen `load()` y `preload()` de `res://art/...`. Por ejemplo, `art/prototypes/full-pass/render.gd`, `tools/prepare_monster_sprites.gd`, `tools/prepare_logo.gd`, `tools/make_sounds.gd` y `tools/t263_upgrade_mock.gd`.
  - Si se pone un `.gdignore` general, eso se rompe.
  - Los tests solo leen JSON de `art/` con `FileAccess` (`test_campaign_geography.gd:7`, `test_m36_effects_audio.gd:70`), y eso no se ve afectado.
- **Ahorro:** 0 en el juego. En CI y en cada worktree nuevo ahorra import y disco; el tiempo no está medido.
- **Siguiente verificación:** listar qué carpetas de `art/` se cargan como recurso desde `tools/` o `tests/` y poner `.gdignore` solo en las demás. CI corre `--check-only` de `tools/*.gd`: un `preload` a un recurso ignorado haría fallar el chequeo.

**H3 · Media · Confirmado sin referencias · `assets/sprites/enemies/rammer.png`.**
- **Datos:** 1.764.976 B, 1536×1024. Lo agregó `dbcd60a` (T185) y lo reemplazó `rendered/rammer_m43*.png` (`data/enemies/rammer.tres:3-4`).
- **Evidencia de que nada lo usa:** `git grep "rammer\.png"` solo encuentra el `.import`, y su `uid` no aparece en ningún archivo. La imagen se carga a través de `.tres`, no con una ruta armada.
- **Ahorro:** 1,76 MB de fuente; en un caché viejo, 2,04 MB de `.ctex`.

**H4 · Baja · Confirmado sin referencias directas · SVG fuente y PNG heredados en `assets/`** (~55 archivos, ~188 KB de fuente).
- **Qué son:**
  - 13 SVG de enemigos (todos menos `flyer.svg`, que usa `tower_panel.tscn:6`).
  - 13 SVG de torres (`base_*`, `turret_*`, `mechanical_standard`).
  - 9 SVG de proyectiles.
  - 17 SVG de mapa.
  - `effects/flame.svg`, `ui/demoledora.svg` y `enemies/rendered/healer.png` (51.469 B, reemplazado por `healer_m43*`).
- **Atención:**
  - `tools/make_icon.gd` precarga `boss.svg`, `base_3.svg` y `turret_cannon.svg`: son **solo de herramienta**, no muertos.
  - `hito.svg` sigue nombrado en la tarea abierta T233 ("`hito.svg` e imagen del epílogo"): se conserva hasta que Lucas decida.
- **Ahorro:** cada SVG se importa a 2× con mipmaps; en el caché suman poco. El rango justificado es <1,5 MB. **Hay que medirlo.**

**H5 · Media (tests) · Confirmado · Hueco en `tests/test_resource_audit.gd:146-153`.**
- **Problema:** el test da por usado un archivo si el nombre **sin extensión** aparece en cualquier lado (`haystack.contains(file.get_basename())`). Por eso `rammer`, `healer`, `armored`, `tronco` o `demoledora` pasan aunque nadie los cargue.
- **Además:**
  - `_all_assets()` no mira `webp` ni `jpg`.
  - El test no cubre `Capturas/` ni el export.
- **Consecuencia:** este test no alcanza como red de seguridad para borrar. Antes de cualquier limpieza hay que endurecerlo, por ejemplo con la ruta `res://` completa, el `uid` o los patrones conocidos `shot_%s` y `audio/`.

**H6 · Media · Medido · Imágenes grandes guardadas sin pérdida.**
- **Franjas:** 7 PNG de 1672×941 RGB (`assets/backgrounds/stripes/`), 16,1 MB de fuente y 15,8 MB de caché, con `compress/mode=0` y mipmaps.
- **Otras:** `story/epilogue.png`, 1920×1080, 2,8 MB de caché; `ui/logo.png`, 0,89 MB.
- **Antecedente medido:** la intro ya usa `compress/mode=1` (lossy 0,9), y sus 18,2 MB de fuente quedaron en 4,19 MB de caché, un 23 %.
- **Las franjas temáticas no se pueden sacar:**
  - `volcan` y `pantano` no están en ningún nivel de campaña, pero el fondo se elige por `level.theme` (`game.gd:471`, `presentation_host.gd:75`).
  - Los mapas de comunidad pueden usar esos temas (RF-267).
  - Los tests las cargan (`test_map_drawings.gd:252-264` y `tools/ejemplos/tema_*.json`).
- **Pendiente relacionado:** T532 (bajar el brillo de las franjas, RF-726) está abierta. Cualquier cambio de compresión va **después** de T532 y con comparación visual.

**H7 · Hipótesis · Mipmaps.**
- **Son deliberados:** 17 usos de `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS` (D-023). **No hay que desactivarlos en general.**
- **Casos a medir:**
  - Las franjas se dibujan con el filtro del viewport, que `presentation_host.gd` calcula con `PresentationGeometry.content_texture_filter`. Ahí hay rama con y sin mipmaps, así que no se puede afirmar que sobren.
  - La intro está importada **sin** mipmaps, pero `intro_screen.gd:261` pide un filtro con mipmaps. Es una incoherencia a revisar con una captura.

**H8 · Baja · Medido · Audio.**
- **Fuente:** 26 WAV PCM de 16 bits; la música estéreo pesa 14,1 MB.
- **Ya importa con QOA** (`compress/mode=2`): `music_menu` queda en 1.628.975 B y `music_combat` en 1.221.855 B de caché, un 20 %. El tamaño del WAV en el repo **no** es el del juego.
- **Opción:** pasar a OGG ahorraría ~1,5–2 MB más (rango). Requiere escucharlo.

**H9 · Info · Confirmado · Lo que no sobra.**
- No hay fuentes propias: se usa la fuente por defecto. Las TTF son de `addons/gut`, que se excluye.
- `docs/` es un solo `.md`, que no se importa.
- El ícono es único.
- No hay scripts ni escenas huérfanas: 173 de 175 se alcanzan desde el juego.
- No hay `uid://` colgados.
- No hay TODO, FIXME ni HACK.

**H10 · Baja · Confirmado · Código solo de herramientas, dentro de `scripts/`.**
- `scripts/logic/balance_args.gd` (8.353 B; solo lo usan `tools/balance_sim.gd` y `tests/test_balance_args.gd`).
- `scripts/logic/intro_doc.gd` (14.788 B; solo `tools/intro_doc.gd` y `tests/test_intro_doc.gd`; lee `res://specs/…`, que está excluido del export).
- Se exportan por estar en `scripts/`. El ahorro es ~23 KB y moverlos obliga a tocar `tools/` y `tests/`: **no vale la pena por tamaño.**

**H11 · Baja · Confirmado · Siete funciones que nadie llama** (grep `-w` en todo el repo, sin `call`, `Callable` ni `[connection]`):
- `tutorial_controller.gd:79` `current_targets`
- `tower.gd:274` `has_emitter_in_range`
- `touch_scroller.gd:41` `is_scrolling`
- `save_manager.gd:427` `has_siege_legacy`
- `ghost_placement.gd:30` `move_by_cells`
- `obstacle_field.gd:108` `seconds_with_machine`
- `touch_gesture.gd:63` `active_fingers`

Además hay duplicados:
- `game_flow.gd:203` `is_campaign_complete` y `:271` `campaign_complete`.
- `_is_number` está copiado 7 veces.
- `_label` 8 veces y `_button` 4 veces.
- El bloque de reseteo de navegación se repite en `game_flow.gd:384-459`.

Ahorro ≈ 0. Es mantenimiento.

**H12 · Info · Probable · Ramas de dibujo de antes del arte.**
- El dibujo por forma (`enemy.gd:551-558`, `enemy_icon.gd:38-39`), el cuadrado de color de la torre (`tower.gd:456-460`, `:476-487`) y `EnemyData.shape` no se alcanzan con los datos oficiales.
- Pero los tests crean `EnemyData.new()` sin textura, y además son el respaldo si falta un recurso. **Se conservan (C).**

**H13 · Info · Confirmado · Migraciones de guardado vivas.**
- `_migrate_siege_access` y `_migrate_selector_style` (`save_manager.gd:553-589`), el acceso heredado a Asedio (`siege_access.gd`) y los valores por defecto de `ui_prefs` tienen tests propios.
- D-216 dice que no se prueba el guardado *viejo* de la prueba con el tester, pero eso **no** autoriza borrar migraciones de jugadores. **Se conservan (C);** si se quieren sacar, primero lo decide Lucas (D).

**H14 · Baja · Confirmado · `supply_conveyor.svg` precargado sin uso en niveles.**
- Está en `map_drawings.gd:20,53,72`, el editor lo ofrece y lo nombra `test_level_15.gd:186`.
- Pesa ~2 KB. Es un dibujo de la cadena de abastecimiento: está ligado a la decisión T527.

**H15 · Info · Confirmado · T527 no es deuda accidental.**
- El nivel 15 usa `supply_cart`, `supply_line_pole` y `supply_depot` (SVG M52, `map_drawings.gd:50-52`).
- T527 (`03-tareas.md:3060-3063`) está `[x]` **como concepto**. Las muestras están en `art/t527-abastecimiento/`; `manifest.json` tiene `assets_integrated: false`.
- Falta el OK de Lucas para integrarlo y para reusar `stat_resources.svg`. Ese archivo está en `KNOWN_UNUSED`: si se usa, hay que sacarlo de la lista.
- Por eso el 15 **conserva los SVG a propósito.**

**H16 · Baja · Confirmado · Documentos que no coinciden con el código.**
- `README.md:15` habla de "volcanes" y "pantanos", pero ningún nivel de campaña usa esos temas.
- `ONBOARDING.md:17,96` dice "145 tests"; hoy hay 182 archivos y unas 2536 funciones `test_`.
- `ONBOARDING.md:123,215` da tamaños de ejecutable viejos.
- `CONTENIDO.md`:
  - `:259`: el orden de la barra, sin la Disruptora y con nombres viejos.
  - `:612`: el nivel 14 "14 enemigos", cuando en realidad son 16.
  - `:483`, `:499` y `:708` dicen "todavía no está" sobre M58, el Coloso y M76, que ya existen.

**H17 · Media · Confirmado · CI sin export ni tamaño.**
- `.github/workflows/tests.yml` solo importa, hace `--check-only` de `tools/*.gd` (sin `tools/t265/`) y corre GUT. No exporta ni mide tamaño.
- Ninguna reducción puede confirmarse automáticamente.

**H18 · Hipótesis · Android y VRAM.**
- Todas las texturas son lossless (`compress/mode=0`), aunque `import_etc2_astc=true`.
- Los 18 atlas de caminata son de 1024² RGBA con mipmaps, unos 5,6 MB de VRAM cada uno.
- La compresión VRAM es una optimización de **memoria**, no siempre de disco. Es post-V1 y hay que medirla en un celular real.

---

## 2. Clasificación

**(A) Candidatos inmediatos de bajo riesgo**
1. Excluir `Capturas/*` del export y agregar `Capturas/.gdignore` (H1).
2. Sacar de `assets/` `rammer.png` y `rendered/healer.png` (H3), siguiendo el orden reversible de §3.
3. Corregir los documentos desactualizados (H16), con tarea documental.
4. Agregar `/art/**/*.translation` al `.gitignore` y desversionar los 26 archivos (H2, higiene del repo).

**(B) Necesitan tests o medición**
1. Endurecer `test_resource_audit` (H5). **Esto va antes de B2.**
2. Mover los ~55 SVG fuente de `assets/` a `art/` (H4), salvo los de herramienta.
3. `.gdignore` selectivo en `art/` (H2).
4. Franjas, epílogo y logo con compresión con pérdida (H6), después de T532.
5. Mipmaps de las franjas y de la intro (H7).
6. Música en OGG (H8).
7. VRAM en Android (H18, post-V1).
8. Un paso de export y tamaño en CI (H17).

**(C) Parecen viejos, pero se conservan**
- Las franjas y los temas `volcan`/`pantano` (comunidad, RF-267, tests).
- Los SVG del nivel 15 (T527).
- `supply_conveyor` (editor; también T527).
- `hito.svg` (T233).
- Todo lo de `KNOWN_UNUSED`: arte aprobado esperando uso (D-170, T216, T221).
- Los SVG que usa `tools/make_icon.gd`.
- `balance_args.gd` e `intro_doc.gd` (herramientas).
- Las migraciones de guardado (H13).
- Las ramas de dibujo de respaldo (H12).
- El estilo de selector Tarjetas, que está vivo.
- `addons/gut` (ya excluido).
- `tests/` (ya excluido; **no se borra para achicar**).
- Las 3 `Capturas/T520-*` que muestra el README.

**(D) Decisiones de Lucas**
1. ¿`Capturas/` sigue en el repo (138 MB y 141 MB de historial) o se pasa a otro lugar (Releases o LFS)? Las del README se quedan.
2. ¿Reescribir el historial para achicar el repo? Implica `push --force`, prohibido sin permiso explícito. **Recomiendo que no**, salvo necesidad real.
3. ¿Se acepta compresión con pérdida en las franjas, el epílogo y el logo, viendo la comparación?
4. ¿La música pasa a OGG?
5. ¿Los SVG fuente se mueven a `art/` (quedan como fuente) o se borran?
6. T527: ¿se integra la nave y el taller y se reusa `stat_resources.svg`? ¿Qué pasa con `supply_conveyor`?
7. ¿Las migraciones de guardado siguen después de V1?

---

## 3. Orden reversible para cualquier eliminación

Para todas las eliminaciones se sigue este orden:

1. **Inventario:** lista exacta con ruta, bytes, `uid` y quién lo nombra, en código, tests, tools y art.
2. **Aislamiento:** primero se excluye del export (`exclude_filter`) o se mueve a `art/<tarea>/` con `.gdignore`, sin borrar.
3. **Prueba:** `godot --headless --import` y luego GUT completo, sin `SCRIPT ERROR`. Además, `--check-only` de `tools/` y las capturas de las pantallas afectadas.
4. **Comparación:** export Linux antes y después en `/tmp`, con tamaño y listado del PCK. Comparación visual cuando cambia una compresión.
5. **Borrado definitivo:** en una tarea aparte, con su commit, y actualizando `KNOWN_UNUSED` y los documentos.

---

## 4. Plan de tareas propuestas

Los números de tarea, RF y D los asigna quien escriba la spec; acá no se inventan. Todas requieren una **tarea documental 📜 antes** (spec → decisión), según el SDD.

| # | Tarea | Depende de | Hecho cuando | V1 / post |
|---|---|---|---|---|
| P0 📜 | Spec y decisión: política de qué entra en el paquete (export filters, `.gdignore`, carpetas de documentación) y la medición del tamaño | — | Hay RF y D escritos con alternativas | V1 |
| P1 | Medir el baseline actual: export Linux desde `main` a `/tmp`, con tamaño y lista del PCK (solo lectura; no necesita esperar una política) | — | Los números quedan en el Resultado; corrige ONBOARDING | V1 |
| P2 | Especificar y excluir `Capturas/*` del export; evaluar `Capturas/.gdignore` por separado con las herramientas de captura | P0, P1 | El PCK ya no lista `Capturas/`; GUT en verde; diferencia medida | V1 (cambio chico, impacto alto) |
| P3 | Endurecer `test_resource_audit` (ruta completa y `uid`, `webp`/`jpg`) y actualizar `KNOWN_UNUSED` | P0 | El test detecta `rammer.png` y los SVG fuente; la lista queda explícita | V1 |
| P4 | Aislar `rammer.png`, `healer.png` y los SVG fuente (se mueven a `art/`) | P3, D5 | GUT, `--check-only` de tools y export pasan; se mide la diferencia | V1 u opcional |
| P5 | `.gdignore` selectivo en `art/` y `*.translation` en `.gitignore` | P0 | `--import` en CI más corto y sin errores de tools | post-V1 |
| P6 | Paso en CI: export headless y tamaño del PCK como artefacto (requiere plantillas) | P1 | El workflow publica el tamaño | post-V1 |
| P7 🎨 | Comparación lossless/lossy de franjas, epílogo y logo | T532, D3 | Lucas eligió con capturas a escala real | post-V1 o V1 si Lucas quiere |
| P8 | Revisar mipmaps de la intro y las franjas | P1 | Capturas sin diferencia y VRAM medida | post-V1 |
| P9 | Música en OGG | D4 | Escucha aprobada y loops verificados | post-V1 |
| P10 | Limpieza de código: las 7 funciones sin uso y los duplicados (`_is_number`, `campaign_complete`) | — | GUT en verde; sin cambio de comportamiento | post-V1 |
| P11 📜 | Corregir documentos (H16) | — | README, ONBOARDING y CONTENIDO coinciden con el código | V1 |

**Reducción estimada (no prometida):**

| Ítem | Nivel | Tipo | Valor |
|---|---|---|---|
| Capturas fuera del export | alto | rango medido de fuente y caché | 138–170 MB |
| Franjas lossy | medio | rango, por analogía con la intro (23 %) | 8–12 MB |
| `rammer.png` | bajo | medido | 1,76–2,04 MB |
| Música OGG | bajo | rango | 1,5–2 MB |
| SVG fuente y `healer.png` | bajo | rango | <1,5 MB |
| Código | nulo | medido | <30 KB |
| `art/` con `.gdignore` | 0 en el juego | medido en caché | −670 MB en disco y CI |

---

## 5. Backlog de decisiones visuales y artísticas para Lucas

1. **Flores y vegetación alien en los niveles 1, 3, 4 y 5** (pedido de Lucas).
   - Hoy los cuatro usan `flores.svg`, el SVG plano de T260 que se conservó al revertir.
   - No encontré un RF ni una tarea que registre el pedido: **requiere tarea documental 📜 antes.**
   - Va con muestras y compuerta 🎨, en la estética actual.
2. **T527, abastecimiento del 15:** aprobar la nave y el taller, el farol roto, y reusar `stat_resources.svg` en el poste.
3. **`supply_conveyor`:** ¿se usa en el 15 con el nuevo arte, o queda solo para el editor?
4. **T233:** `hito.svg` y la imagen del epílogo siguen pendientes. El epílogo pesa 2,8 MB de caché: si se rehace, conviene definir el formato desde el principio.
5. **Franjas:** junto con T532 (brillo), elegir si se guardan con o sin pérdida.
6. **Temas `volcan` y `pantano`:** hoy solo los usa la comunidad. ¿Algún nivel de campaña los usa, o se corrige el README?

---

## 6. Cobertura de esta auditoría

**Cubierto:** las fases 1 a 7.

**Pendiente, porque necesita ejecución:**
- El tamaño real del export.
- El listado del PCK.
- La VRAM real.
- La comparación visual de las compresiones.
- El tiempo de import con `.gdignore`.
- Confirmar que `art/*` excluye en forma recursiva en el export.


## Nota del coordinador (2026-10-27)

- Se contrastaron de forma puntual los filtros de `export_presets.cfg`, el inventario de `Capturas/` (257 PNG, 138.256.832 bytes), el total de `.gdignore` dentro de `art/` (30), la referencia débil de `tests/test_resource_audit.gd` y los cuatro JSON que usan `dibujo:flores`. Coinciden con el informe.
- La auditoría no midió un export ni ejecutó Godot/GUT. El rango 138–170 MB es una estimación basada en fuentes y caché importada de un worktree cercano, no un ahorro comprobado del paquete final. No se descarta ni se mueve material de `Capturas/` en esta tarea.
- El análisis del empaquetado debe arrancar con el baseline de export en una carpeta temporal; esa medición read-only no necesita esperar una decisión de política. Después se especifica y aprueba el cambio de inclusión. No se genera APK en esta máquina.
- Sobre T527: los conceptos de nave y taller con el farol oscuro ya recibieron conformidad visual de Lucas. Los SVG del nivel 15 siguen en el juego hasta implementar el reemplazo; la galería T537 no era esa integración. Reutilizar `stat_resources.svg` y mantener `supply_conveyor` son decisiones de alcance todavía separadas.
- El usuario ya pidió iniciar la vegetación alienígena de los cuatro mapas de pradera. T539 prepara muestras visuales, sin integración.

---

## Nota de seguimiento (2026-10-28, T551): P3 hecho y parte segura de P4

- **P3 (H5):** `tests/test_resource_audit.gd` ya exige la ruta `res://` completa o el `uid` para los dibujos y mira también `webp` y `jpg`. `KNOWN_UNUSED` quedó explícita y comentada en tres grupos (arte aprobado a la espera, pendiente de revisión de Lucas y SVG fuente a la espera de D5). El test detecta los SVG fuente de `assets/` sin uso (50 listados) y habría detectado `rammer.png` y `rendered/healer.png`.
- **P4 (solo PNG):** esos dos PNG (H3) se movieron a `art/t551-retirados/` con `.gdignore`, sin borrarlos del repositorio (orden reversible §3, pasos 1 y 2), y se quitaron sus `.import`. GUT completo (2573 pruebas), `--import` y `--check-only` de los 39 `tools/*.gd` pasan.
- **Sigue abierto:** los SVG fuente (D5, decisión de Lucas) no se movieron; el ahorro en el paquete no se midió (falta el export de P1); el borrado definitivo es otra tarea.
