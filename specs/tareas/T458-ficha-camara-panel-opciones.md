# T458 · Ficha de implementación: «Ver todo», panel de mejora, alcance y Opciones (M75)

- **Ejecutor sugerido:** un agente de código por tarea (Sonnet o Codex). T464 incluye un ícono: lo aprueba Lucas. **Tamaño:** cinco tareas chicas a medianas (T464 a T468), una por commit.
- **Refs:** RF-674 a RF-686 (`specs/01-spec.md`, sección M75), D-192 a D-197 (`specs/04-decisiones.md`), plan M75 (`specs/02-plan-tecnico.md`), informe de partida `specs/tareas/informes/T451-camara-panel-opciones.md` (el «hoy» con archivo y línea), tablero `specs/03-tareas.md` (sección M75).
- **Protocolo común:** `specs/tareas/README.md`. Esta ficha lo da por leído.

> **Compuerta.** No empezar a programar hasta que Lucas dé el OK a la spec M75. Las decisiones funcionales anotadas en `03-tareas.md` ya están cerradas; la muestra del ícono de lupa requiere aprobación de Lucas antes de integrarse.

## 0. Antes de tocar nada

1. Leer `CLAUDE.md`, `specs/00-constitucion.md`, `.claude/rules/gdscript.md`, `.claude/rules/tests.md`, `.claude/rules/datos.md` y, si se toca un SVG, `.claude/rules/arte.md`.
2. Leer **solo** los RF/D de arriba. Las líneas que cita el informe T451 pueden haberse movido: verificarlas con `grep` antes de editar.
3. `godot --headless --import` antes de los tests si hay archivos o clases nuevas, y después `git status` + `git checkout -- assets` con lo que `--import` haya reescrito sin querer (SVG).
4. Un test que pasa pero imprime `SCRIPT ERROR` **falla**. Mirar la salida completa.
5. Una tarea = un commit `Txxx: …`. Rama `feature/txxx-nombre`. Commit y push solo como lo pida el proyecto.

## 1. Orden y dependencias

```
T464 («Ver todo») ─┐
T465 (panel)      ─┼─► T467 (ampliación, dos toques)  ─► T468 (grupos de Opciones, después de T461)
T466 (alcance)    ─┘
```

- T464 y T465 en paralelo (comparten solo `mobile_hud.gd`: coordinar).
- T467 necesita T465 (botón «Mejorar» del panel) y T466 (la opción y el estilo de dibujo).
- T468 va al final y **después de T461** (renombra la fila «Entrada de los jefes» a «Presentación de los jefes», D-190).
- **No más de dos tareas a la vez** entre las que tocan `save_manager.gd` u `options_menu.gd` (T464, T466, T468). `project.godot` no se toca en ninguna.

## 2. T464 · «Ver todo»

**Archivos:** `scenes/game/camera_controller.gd`, `scenes/game/mobile_hud.gd`, `scenes/game/game.gd`, `scripts/logic/ui_prefs.gd`, `scripts/autoload/save_manager.gd`, `data/ui/mobile_ui.json`, `assets/ui/` (lupa).

1. Sacar `_build_pc_view_all_button` y su ayuda. La PC conserva la acción `view_all`, la V, el efecto en pausa y la guarda de menús abiertos (RF-613, sin tocar).
2. Botón del celular con ícono de lupa (SVG propio, antecedente `assets/ui/mobile_demolish.svg`; ver `.claude/rules/arte.md`). **Captura para Lucas antes de integrar.** Sin aprobación, queda el texto actual.
3. Aviso de una vez (RF-676): `CameraController` emite una señal cuando el botón pasa de oculto a visible; `Game` decide si mostrarlo (`ui_prefs.view_all_hint_seen`, tutorial, menús) y lo marca al mostrarse. Los dos textos van en datos o constantes de interfaz, no repartidos por el código.
4. Campo aditivo con lectura defensiva (ausente/inválido → «no visto», con `push_warning` si es inválido). `SAVE_VERSION` no cambia.

**Tests:** actualizar `test_view_all_displaced.gd` y `test_view_all_binding.gd`; nuevo `test_view_all_hint.gd` (una vez, no con el tutorial, guardado viejo, solo en el paso de oculto a visible); `test_old_saves.gd`.

## 3. T465 · Panel de torre (propuesta A)

**Archivos:** `scenes/ui/tower_panel.gd` y `.tscn`, `scripts/logic/tower_text.gd`, `scripts/logic/upgrade_deltas.gd`, `scenes/game/mobile_hud.gd` (solo el formato y el cálculo compartido).

1. Quitar `UpgradePreview` y el rótulo «Al nivel N:». «Antes → después» en DAÑO, CADENCIA, ALCANCE y las líneas de efectos, con `UpgradeDeltas` y la tabla de `data/ui/mejoras.json` (RF-618: no hay números nuevos).
2. **Una sola función de formato decimal con coma**, usada por el panel, `TowerText` y la barra del celular.
3. `pulse_line` (Disruptora) sin cadencia, radio ni daño repetidos.
4. Tarjeta de nivel en bronce, plata y oro con el tooltip «Nivel actual: N de 3». **Los colores salen de la paleta que ya usa la UI** (`specs/05-guia-de-arte.md`); no inventar tonos nuevos: si no están, mostrar la propuesta a Lucas.
5. Tooltip del título solo si el texto se corta. Sin «Nivel N/3».
6. Si «0,75 → 0,85/s» no entra en 270 px: achicar la fuente de esas filas o pasar la cadencia a una línea propia (decidir con captura). No agrandar el panel.

**Tests:** actualizar `test_upgrade_preview.gd` (`:133`, `:137`), `test_tower_panel_layout.gd`, `test_upgrade_fx.gd`; casos nuevos para Cañón, Tesla, Hielo y Disruptora en los niveles 1 a 3 (nada duplicado, coma, último nivel sin flechas); test de ancho con la fuente del juego.

## 4. T466 · Opción de alcance, fantasma y arco

**Archivos:** `scripts/autoload/save_manager.gd`, `scenes/ui/options_menu.gd` y `.tscn`, `scenes/game/build_controller.gd`, `scenes/towers/tower.gd`, un archivo nuevo de `data/ui/` con los valores de dibujo y su lector/validador.

1. `settings.range_display` (0 Oculto por omisión, 1 Sutil, 2 Completo) con lectura defensiva; fila «Círculo de alcance» con un `OptionButton`, **en el lugar que dejará T468** (si T468 aún no existe, junto a «Animaciones de mejora», con `name` estable).
2. `BuildController`: el fantasma llama siempre al estilo completo; la torre seleccionada, al de la opción. Redibujar al cambiar la opción.
3. `Tower`: el arco de apoyo sigue la opción (Oculto no dibuja; Sutil, el arco de hoy; Completo, el estilo completo en celeste); aturdida, no dibuja.
4. Valores iniciales de RF-678 en `data/ui/` (P2), con validador en castellano.

**Tests:** `test_range_display.gd` (cada valor, fantasma completo con cualquier valor, arco según opción, aturdida); `test_old_saves.gd`; `test_mobile_ui.gd`. Capturas de Sutil y Completo sobre los 15 fondos.

## 5. T467 · Ampliación, dos toques y animación

**Archivos:** un nodo de presentación nuevo (`RangePreview`, en `scenes/effects/`), `scenes/effects/effects_layer.gd`, `scenes/ui/tower_panel.gd`, `scenes/game/mobile_hud.gd`, `scenes/game/game.gd`, `data/tutorial/tutorial.json`.

1. `RangePreview`: `Tween` y `_draw`, **sin `_process`**; recibe centro, radio actual y radio nuevo; crece y se desvanece en 0,5 s; respeta pausa y velocidad. Sin animar si `upgrade_fx` está apagado (círculo quieto).
2. PC: `mouse_entered` / `mouse_exited` del botón «Mejorar» activo. Sin oro o al nivel máximo, nada.
3. Efecto de mejora (`EffectsLayer.tower_upgraded`): dibuja el círculo con el alcance nuevo solo con `upgrade_fx` prendida.
4. Celular: estado «armado» por torre elegida. **Se desarma con:** tocar el mapa, soltar o elegir otra torre, cambiar de estado de la barra, tocar «Vender» o la prioridad, pausar, o que falte oro. Primer toque: muestra la ampliación y el botón conserva el costo con el texto de confirmación. Segundo toque: `try_upgrade`. Mantener el bloqueo de 0,35 s de RF-512.
5. Tutorial del nivel 1 (M63): actualizar el paso `upgrade` para explicar que el primer toque muestra la ampliación y el segundo confirma; verificar que el flujo siga avanzando con «Siguiente». Esto documenta el comportamiento aprobado por Lucas en D-195 y no cambia los resultados humanos de T453.

**Tests:** `test_range_preview.gd` (hover, primer y segundo toque, un test por cada evento que desarma, 0,35 s, mejora instantánea con oro/nivel/números iguales, `upgrade_fx` apagado); actualizar/verificar `test_tutorial_data.gd` para la explicación de los dos toques. Capturas en PC y celular simulado.

## 6. T468 · Reagrupar Opciones

**Archivos:** `scenes/ui/options_menu.gd` y `.tscn`; tests de Opciones.

1. `_arrange_columns()` aplica una lista de orden declarativa por grupo (arreglo de nombres de nodo); los constructores `_build_*` dejan de usar `move_child` relativos.
2. Títulos: Sonido, Pantalla, Partida y ayudas, Controles, Avanzado (estilo del título actual). Filas según RF-684. «Interfaz» en «Avanzado», Automática por omisión.
3. **No cambiar** los `name` de nodo ni las claves de guardado.
4. Celular: sin «Controles»; izquierda Sonido + Pantalla, derecha Partida y ayudas + Avanzado; si no entra en 720 px, el desplazamiento de RF-555.

**Tests:** reescribir los asserts de posición (`test_tutorial_options.gd:52-53`, `test_boss_entrance_options.gd`, `test_defeat_advice_options.gd`, `test_view_all_binding.gd`) y revisar `test_menu_layout.gd`, `test_mobile_ui.gd`, `test_options_admin.gd`, `test_news_menu.gd`, `test_game_version.gd`; nuevo `test_options_groups.gd`.

## 7. Riesgos (resumen; el detalle está en el plan M75)

Ancho del panel (no medido) · aspecto de Sutil sobre fondos claros (no probado) · dos toques en el celular sin prueba en teléfono real · estado «armado» olvidado que gaste oro · tests que fijan posiciones · el arco del Estandarte pasa a Oculto por omisión · la lupa es arte nuevo y requiere aprobación de Lucas · `--import` reescribe SVG.

## 8. Lo que no se toca

Balance, precios, daños, ventas y reglas de mejora; niveles, torres y enemigos; el arte ya aprobado; `project.godot`; `CHANGELOG.md` hasta que cada tarea esté implementada (entonces sí, junto con spec, plan, `CONTENIDO.md`, `README.md` y `ONBOARDING.md`). **B-58** (teclas configurables) queda en el backlog: no implementar.

## 9. Resultado honesto (cada tarea)

Al terminar, escribir en `03-tareas.md`: qué se hizo, qué se probó (tests y capturas) y **qué no** (en especial: ningún celular real, ningún teclado distinto del de la máquina de desarrollo).
