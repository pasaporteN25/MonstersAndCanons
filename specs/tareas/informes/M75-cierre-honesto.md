# M75 · Cierre honesto de T458, T480, T464, T465, T466 y T467

**Fecha:** 2026-10-25 · **Base:** `origin/main` e121f0c · **Rama:** `feature/m75-cierre-honesto` · **Hizo:** Claude (Opus), sin Lucas presente.

**Origen:** una auditoría de solo lectura (Haiku) encontró que el código de M75 estaba en `main` pero el tablero no decía la verdad: tareas con resultados viejos («sin commit»), capturas que faltaban y fichas inexistentes. Acá se revisa **cada criterio del «Hecho cuando»** contra el código, los tests y una ventana real de Godot.

## 1. Cómo se verificó

| Qué | Resultado |
|---|---|
| `godot --headless --import` | Dos corridas (al empezar y después de agregar la herramienta), las dos con salida 0, sin segfault 139. No cambió nada de `assets/`; se borraron los `.import` sueltos que generó en `Capturas/`. |
| GUT completo **antes** de tocar nada | **2418/2418** tests, 34.476 aserciones, 171 scripts, 0 `SCRIPT ERROR` / `Parse Error` (los `ERROR:`/`WARNING:` de la salida son los esperados por los tests de datos rotos). |
| Tests focales (dentro de la corrida completa) | `test_view_all_hint` 7/7 · `test_view_all_displaced` 9/9 · `test_view_all_binding` 16/16 · `test_upgrade_preview` 10/10 · `test_tower_panel_layout` 2/2 · `test_range_display` 10/10 · `test_range_preview` 34/34 · `test_old_saves` 20/20 · `test_options_groups` 10/10 · `test_tutorial_game` 24/24. |
| Ventana real (`DISPLAY=:0`, pantalla 1920 × 1080) | Herramienta nueva `tools/capture_m75_cierre.gd`, en pantalla completa (1920 × 1080 exactos: la ventana con borde de los intentos anteriores quedaba en 1853 × 1042) y en ventana de 1280 × 720. Guardado temporal `user://capture_m75_cierre.json`, borrado al terminar. |
| Arreglo de una línea | `scripts/logic/tower_text.gd:17` (ver §3, H-1) con test nuevo; después: `test_upgrade_preview` 11/11, `test_wiki` 16/16, `test_disruptor_text` 9/9, `test_tower_panel_layout` 2/2, sin `SCRIPT ERROR`; el test nuevo **falla** con la línea vieja. GUT completo final: **2419/2419**, 34.489 aserciones, 0 `SCRIPT ERROR` / `Parse Error`. |

**No se pudo probar:** ningún teléfono real (pinza, dedo, tamaño táctil de la lupa), Windows, ni un teclado distinto del de esta máquina. No se midió rendimiento.

## 2. Criterio por criterio

Leyenda: ✅ cumplido (con la prueba) · ◐ parcial · ❌ no se cumple · ⏳ espera a Lucas.

### T458 · Especificar M75 (documental, PR #62, commit 43b32ef)

| # | Criterio | Estado | Prueba |
|---|---|---|---|
| 1 | Sección M75 con RF-674 a RF-686 y enmiendas anotadas en los RF viejos | ✅ | `specs/01-spec.md` § M75; 11 «Enmienda M75» agregadas en el commit |
| 2 | D-192 a D-197 y D-161 anotada | ✅ | `specs/04-decisiones.md:1409-1411` y `:1701-1750` |
| 3 | Plan M75 | ✅ | `specs/02-plan-tecnico.md:1713` |
| 4 | T464 a T468 con «Hecho cuando» | ✅ | `specs/03-tareas.md` § M75 |
| 5 | Ficha T458 | ✅ | `specs/tareas/T458-ficha-camara-panel-opciones.md` |
| 6 | CONTENIDO, README y ONBOARDING «pendiente de implementación» | ✅ (en su momento) | commit 43b32ef; hoy esos textos quedaron viejos (H-5) |
| 7 | B-54 y B-58 al día | ✅ | `specs/01-spec.md:1454` y `:1458` |
| 8 | `CHANGELOG.md` sin cambios | ✅ | `git show --stat 43b32ef` |
| 9 | Solo documentos y `git diff --check` limpio | ✅ | `git show --stat` / `--check 43b32ef` |

**→ Se cierra `[x]`.**

### T480 · Precisar el aviso de «Ver todo» (documental, PR #71, commit 8846750)

| Criterio | Estado | Prueba |
|---|---|---|
| RF-676 y D-192: solo al aumentar el zoom | ✅ | `01-spec.md` RF-676; D-192 en `04-decisiones.md:1701` |
| D-207 con porqué y alternativas | ✅ | `04-decisiones.md:1781` |
| Plan, README, CONTENIDO y ONBOARDING consistentes | ✅ | plan M75, README:332, CONTENIDO:719, ONBOARDING:537 |
| Ficha y entrada en el índice | ✅ | `T480-aclarar-aviso-zoom.md`, `specs/tareas/README.md` §11 |
| Solo documentos, `CHANGELOG` igual, `--check` limpio | ✅ | `git show --stat` / `--check 8846750` |

**→ Se cierra `[x]`.** El código que la aplica (T464) sí respeta D-207: `camera_controller.gd:119` emite `view_zoomed_in` solo si `next_zoom > old_zoom`.

### T464 · «Ver todo» (PR #70)

| Criterio | Estado | Prueba |
|---|---|---|
| PC sin botón al acercar o correr el mapa | ✅ | `test_pc_has_no_button_after_pan_or_zoom`, `test_pc_has_no_button_tooltip`, `test_pc_has_no_onscreen_view_all_control` |
| La tecla funciona en marcha y en pausa | ✅ | `test_pc_view_all_key_goes_back_to_the_fit_even_while_paused`, `…does_nothing_with_the_pause_menu_open`; `game.gd:608` |
| Celular: botón con la **lupa aprobada** | ⏳ | muestra `art/t464-muestra-lupa/` sin OK; `mobile_hud.gd:443` sigue con «Ver todo» (lo correcto mientras no haya OK) |
| Aparece solo con zoom | ✅ | `test_panning_at_minimum_zoom_keeps_button_hidden_until_zoom_and_then_returns_to_fit` |
| No tapa carrito/X/demolición | ◐ | en la ventana real, en las posiciones por omisión, no se pisan; **pero el botón sale 7 px de la pantalla** (H-2); sin test |
| Aviso con los textos aprobados, una vez, solo al acercar | ✅ | `test_view_all_hint.gd` (7 tests) |
| No aparece con el tutorial | ◐ | código en `game.gd:617`; **ningún test lo prueba** (H-3) |
| `view_all_hint_seen` ausente/inválido = no visto; `SAVE_VERSION` igual | ✅ | `test_invalid_hint_marker_falls_back_to_unseen`, `test_old_saves.gd` |
| Tests actualizados y `test_view_all_hint.gd` nuevo | ◐ | existen; falta «desplazar y después acercar» (lo pide el plan) |
| Suite sin `SCRIPT ERROR` | ✅ | 2418/2418 |
| Capturas de las dos interfaces | ✅ | `Capturas/T464-ver-todo-pc.png`, `T464-ver-todo-celular.png`, `M75-T464-celular-simulado-ver-todo.png` |

**→ Queda `[ ]`.**

### T465 · Panel de torre (PR #68)

| Criterio | Estado | Prueba |
|---|---|---|
| Sin «Al nivel N:» ni «Nivel N/3» | ✅ | `test_pc_panel_shows_the_preview_and_hides_it_at_max_level` |
| Daño, cadencia, alcance y efectos «antes → después» una vez | ✅ (criterio) / ❌ (RF-677.1) | `test_panel_shows_each_upgrade_value_once_…`; pero los efectos van en un bloque aparte (H-4) |
| Ningún decimal con punto | ✅ **tras el arreglo** | el Cañón de nivel 3 decía «Área: radio 1.5» (H-1); test nuevo de nivel 3 |
| La Disruptora no repite cadencia/radio/daño | ✅ | `TowerText.panel_pulse_line`; capturas |
| Tarjeta bronce/plata/oro con tooltip | ✅ | `test_tower_panel_layout.gd` (colores), tooltip en `test_upgrade_preview.gd` |
| Tesla de nivel 1 entra en 270 px (test de ancho) | ✅ | test con «0,75 → 0,85/s»; medición real de los 12 casos: panel 270 px, ningún texto sin ajuste se pasa de su columna |
| Mismo cálculo que el celular | ✅ | `UpgradeDeltas.preview` en `tower_panel.gd:118` y `mobile_hud.gd:297` |
| Casos nuevos Cañón/Tesla/Hielo/Disruptora en niveles 1 a 3 | ✅ **tras el cierre** | niveles 1-2 ya estaban; nivel 3: `test_panel_at_level_three_has_no_arrows_and_no_decimal_point` (nuevo) |
| Capturas 1280 × 720 y 1920 × 1080 | ✅ | `Capturas/M75-T465-panel-12-casos-1280x720.png`, `…-1920x1080.png`, `M75-T465-panel-tesla-n1-1920x1080.png` |
| No cambia precio, daño, venta ni reglas | ✅ | el diff de #68 no toca `data/towers/` |

**Medición de ancho (ventana real, 1920 × 1080, `T465 ancho · …`):** panel de 270 px en los 12 casos. Renglón más ancho sin ajuste de línea: 242 px («Pulso: apaga las auras durante 3,5 s», Disruptora 3). La cadencia de la Tesla 1 («0,75 → 0,85/s») entra en su columna. La línea de combo del Hielo (354 px) se parte en dos porque esa etiqueta tiene ajuste de línea.

**→ Queda `[ ]`** por H-4: el RF que implementa dice otra cosa y hace falta que Lucas elija.

### T466 · Círculo de alcance (PR #69)

| Criterio | Estado | Prueba |
|---|---|---|
| `range_display` con defensa, sin subir `SAVE_VERSION` | ✅ | `test_range_display.gd` (3 tests) y `test_old_saves.gd` |
| Fila en Opciones (PC y celular) | ✅ | `test_range_option_sits_with_upgrade_animation_option`, `test_mobile_options_keep_the_range_row_touchable_and_inside_the_panel` |
| Fantasma siempre completo | ✅ | `test_ghost_is_always_complete_and_placed_tower_uses_the_setting`; `build_controller.gd:562` |
| Torre construida solo con Sutil/Completo, al instante | ✅ | mismo test; `build_controller.gd:533` y `:593`; en la ventana real el cambio se ve 3 cuadros después |
| Arco de apoyo sigue la opción; aturdida no lo dibuja | ✅ | `test_stunned_support_tower_is_not_drawn_as_active`; `tower.gd:439` |
| Valores en `data/ui/` | ✅ | `data/ui/alcance.json`, `test_range_drawing_data_matches_the_approved_styles` |
| `test_range_display.gd` nuevo | ✅ | 10/10 |
| Capturas Sutil y Completo sobre los 15 fondos, informando cuál no se lee | ✅ | `Capturas/M75-T466-alcance-sutil-15-niveles-recorte-1920x1080.png` (tamaño real) y `…-completo-…-recorte.png` |

**Lectura de las capturas:** el Completo se lee en los 15. El Sutil se ve en pasto y piedra (niveles 1 a 9, 14 y 15), **apenas en la arena (10 a 12)** y **casi nada en la nieve (13)**. Las capturas viejas `Capturas/T466-*-15-niveles.png` están achicadas a ~430 px de ancho y son de antes de T465: con ellas no se podía juzgar.

**→ Se cierra `[x]`.** El criterio pide informar qué fondo no se lee, y queda informado. Retocar el Sutil es opcional y se hace solo con datos (R-2).

### T467 · Ampliación del alcance (PR #72)

| Criterio | Estado | Prueba |
|---|---|---|
| PC: el mouse sobre «Mejorar» la muestra y al salir se va | ✅ | 8 `test_pc_*`; cableado `tower_panel.gd:51-52` → `game.gd:205`; **movimiento de mouse real por el viewport** en la ventana, a 1920 × 1080 y 1280 × 720 (aparece, se va, la torre no sube) |
| Celular: el primer toque no cobra y la muestra; el segundo mejora | ✅ | `test_mobile_first_tap_…`, `test_mobile_second_tap_upgrades_once_instantly` |
| Un test por evento que desarma | ✅ | mapa, soltar, otra torre, otro estado, Vender, prioridad, pausa, falta de oro |
| Bloqueo de 0,35 s | ✅ | `test_mobile_double_tap_after_confirming_raises_only_one_level` |
| Mejora instantánea | ✅ | `test_pc_click_upgrades_instantly_…` |
| Con animaciones apagadas, quieta y sin círculo en el efecto | ✅ | `test_with_upgrade_animations_off_…` |
| Pausa y velocidad | ✅ | `test_the_preview_waits_while_the_game_is_paused_…`, `…follows_the_game_speed` |
| El tutorial del nivel 1 no se traba | ✅ | `test_tutorial_game.gd` recorre el paso «upgrade» en PC y celular (24/24); texto de los dos toques probado |
| `test_range_preview.gd` nuevo, sin `_process` | ✅ | 34/34; `test_the_preview_does_not_use_process` |
| Capturas PC y celular simulado; se dice que no hay celular real | ✅ | `Capturas/t467-*.png`, `Capturas/M75-T467-pc-hover-real-*.png` |

**→ Se cierra `[x]`.** El «Resultado» viejo decía «sin commit»: el código está en `main` desde el PR #72.

## 3. Hallazgos

- **H-1 (arreglado, una línea):** `scripts/logic/tower_text.gd:17` escribía `"Área: radio %.1f"`. Por eso el Cañón de nivel 3 mostraba «Área: radio 1.5» en el panel y la Wiki «radio 1.0». Ahora usa `TowerText.decimal` («1,5», «1»). Test nuevo: `tests/test_upgrade_preview.gd::test_panel_at_level_three_has_no_arrows_and_no_decimal_point`. Los tests de T465 solo recorrían los niveles 1 y 2.
- **H-2 (T464):** con el texto «Ver todo», el botón del celular mide 99 × 64 y empieza en `ver_todo_x_px = 1188` (`data/ui/mobile_ui.json:27`, `mobile_hud.gd:446`): **termina en x = 1287 y sale 7 px de la pantalla de 1280**. Se ve cortado en `Capturas/T464-ver-todo-celular.png` y en `M75-T464-celular-simulado-ver-todo.png`. La lupa de 64 × 64 lo resuelve (termina en 1252). No se tocó: depende de la lupa.
- **H-3 (T464):** la exclusión del aviso con el tutorial activo (`game.gd:617`) y el caso «desplazar y después acercar» no tienen test, aunque el plan de la ficha T458 §2 los pide.
- **H-4 (T465):** RF-677 punto 1 dice que se elimina el bloque aparte (`UpgradePreview`) y que los efectos muestran el «antes → después» **en su lugar**. El código conserva `UpgradePreview` sin rótulo, entre «Apuntar» y «Mejorar» (`tower_panel.gd:106-140`), y saca de la lista el renglón que cambia. Ejemplos en la captura: «área 1 → 1,2», «saltos 2 → 3», «s de pulso 2,5 → 3». Además: el Hielo necesita barra de desplazamiento en la lista de efectos (en el nivel 3, «Voladores: sí» queda debajo del corte), el Hielo de nivel 2 parte «… s de frenado 2 → 3» en dos renglones, y los rótulos cortos («s de frenado», «s de pulso») se entienden poco.
- **H-5 (resuelto en T517):** `CONTENIDO.md:713-715` («todavía **no está programada** … hoy no existe»), `ONBOARDING.md:529` («cuando se implemente T464…») y `specs/01-spec.md:4184` («sin implementar») habían quedado viejos: el código de T464 a T468 y T481 está en `main`. También B-54 (`01-spec.md:1454`: «aún sin integrar a main»).
- **H-6 (menor):** `TowerText.describe` (`tower_text.gd:203-204`) todavía usa `%.1f`. Hoy no lo llama ninguna escena; no se tocó.

## 4. Lo que queda y de quién

| Tarea | Estado | Falta | De quién |
|---|---|---|---|
| T458 | cerrada | — | — |
| T480 | cerrada | — | — |
| T464 | cerrada en main (T517) | H-2 resuelto con la lupa aprobada e integrada; H-3 cubierto en los tests de cierre | — |
| T465 | cerrada en main (T517) | PC-A y CEL-B integradas por T513/T514; queda la prueba de CEL-B en teléfono real a cargo de Lucas | Lucas (teléfono real) |
| T466 | cerrada | (opcional) Sutil más visible en arena y nieve | Lucas decide si se retoca (solo datos) |
| T467 | cerrada | — | — |

**Actualización T517 (2026-10-26):** H-5 quedó corregido en los documentos listados. Las tablas de hallazgos y estado de las secciones 3–4 describen la revisión original del 2025-10-25, salvo las filas T464/T465 que se actualizaron arriba.

## 5. Recomendaciones (no implementadas)

- **R-1 · Lupa (T464), con la estética actual.** La referencia vigente es el HUD de partida y el atlas de Cántaro integrado en T471 (pergamino, bronce y tinta sobre fondo oscuro), no el estilo anterior. La muestra `art/t464-muestra-lupa/lupa.svg` (trazo crema `#e4c28b` con interior bronce `#ab8752`) ya está en esa paleta. Para que combine con los otros botones flotantes, conviene presentarla igual que el carrito y el pico: círculo oscuro con aro de bronce, ícono crema al centro y un cuadrado de 64 × 64. Esa medida además resuelve H-2. Mostrarle a Lucas la captura en partida (no solo el SVG suelto) sobre pasto, arena y nieve.
- **R-2 · Sutil (T466).** Si Lucas quiere que el Sutil se lea en nieve y arena, subir `sutil.opacidad_borde` de 0,3 a ~0,45 en `data/ui/alcance.json`, o darle un color oscuro sobre fondos claros. Hacerlo con capturas antes y después usando la misma herramienta.
- **R-3 · Documentos (H-5).** Una tarea documental chica que ponga al día CONTENIDO, ONBOARDING, el estado de M75 en `01-spec.md` y B-54. No se le asigna número acá: lo toma quien numere la próxima tarea 📜.

## 6. Archivos de este cierre

- Herramienta: `tools/capture_m75_cierre.gd` (panel ×12 con medición, hover real, Sutil/Completo ×15, botón del celular).
- Capturas: `Capturas/M75-T464-celular-simulado-ver-todo.png`, `Capturas/M75-T465-panel-12-casos-1920x1080.png`, `Capturas/M75-T465-panel-12-casos-1280x720.png`, `Capturas/M75-T465-panel-tesla-n1-1920x1080.png`, `Capturas/M75-T466-alcance-sutil-15-niveles-recorte-1920x1080.png`, `Capturas/M75-T466-alcance-completo-15-niveles-recorte.png`, `Capturas/M75-T467-pc-hover-real-1920x1080.png`, `Capturas/M75-T467-pc-hover-real-1280x720.png`.
- Fichas nuevas: `specs/tareas/T464-ver-todo-lupa-aviso.md`, `T465-panel-torre-sin-repeticiones.md`, `T466-opcion-circulo-alcance.md`, `T467-ampliacion-alcance.md`.


## Actualización de estado T517 (2026-10-26)

El hallazgo H-5 se resolvió en la rama documental `feature/t517-limpieza-backlog`: se actualizaron `CONTENIDO.md`, `ONBOARDING.md`, el estado M75 de `specs/01-spec.md` y B-54. La lupa de T464 fue aprobada e integrada en PR #105; T465 cerró al integrarse T513 y T514 (PR #112). El informe y sus tablas siguen siendo la fotografía de la revisión del 2026-10-25.
