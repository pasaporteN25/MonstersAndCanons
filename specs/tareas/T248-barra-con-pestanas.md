# T248 · Barra con pestañas y flecha al menú: código

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio** (alto si la captura obliga a rehacer el reparto de la barra)
- **Depende de:** **T247** (la spec M53, RF-454 a RF-463, y D-088) y de T207, T208 y T210 (el código de demolición, demoledora y extracción) · **Compuerta:** 🚦 **el OK de Lucas a la spec M53** y a sus preguntas P1 a P8. **Si su respuesta no está registrada** (en `specs/04-decisiones.md`, D-088, o en la entrada de T247 de `03-tareas.md`), **no empezar** · **Tamaño:** mediano

## Leer
- **La sección «M53 · Barra con pestañas y flecha al menú» de `specs/01-spec.md`** (RF-454 a RF-463 y las preguntas P1 a P8), **D-088** y **«M53 / T247» del plan técnico**. Está escrito para no tomar decisiones de diseño: las medidas, las teclas, los textos y los archivos están ahí.
- `scenes/game/hud.gd` y `hud.tscn` (la barra de abajo, `setup_towers`, el botón de pausa), `scenes/ui/infrastructure_panel.gd` (lo que se reemplaza) y `scenes/ui/obstacle_panel.gd` (que **no** se toca).
- `scenes/game/build_controller.gd` (`_unhandled_input`) y `scenes/game/game.gd` (el menú de pausa, `set_paused`, `_commit_collection`, `findings`).
- `scenes/ui/pause_menu.gd` y `pause_menu.tscn`, para copiar el estilo del diálogo.
- `scripts/logic/finding_run.gd` y `scripts/data/level_data.gd` (`uses_resources()`).
- `.claude/rules/gdscript.md` y `tests.md`.

## Objetivo
En los niveles que usan infraestructura (hoy del 6 al 10), la barra de abajo tiene dos pestañas, **«Cañones»** e **«Infraestructura»**, y el panel suelto de arriba a la derecha desaparece. Una flecha **«← Menú»** arriba a la izquierda, en todos los niveles, vuelve al menú principal tras pedir confirmación. Los niveles 1 a 5 se ven y se juegan **exactamente igual** que antes (salvo la flecha).

## Alcance
**Sí:**
- Lógica pura y sus tests: `BarLayout`, `ExitText`, `LevelData.uses_infrastructure()`.
- Acciones `build_10` (tecla `0`) y `switch_tab` (`Tab`); `BuildController` deja de preguntar por acciones que no existen.
- `BarTabs`, `InfrastructureTab` (reemplaza a `InfrastructurePanel`), `ExitDialog`, la flecha, y su conexión en `Hud` y `Game`.
- Botones de torre que se achican para que entren hasta 11 (RF-455).
- Capturas reales de 1280 × 720 y de un mapa con zoom; `CHANGELOG.md`, `README.md`, `ONBOARDING.md` y, si lo nombran, `CONTENIDO.md`.

**No:**
- Reglas ni números de demolición, demoledora, extracción o recursos (`ObstaclePanel` y `InfrastructureController` **no cambian**).
- El menú de pausa (RF-461; su diálogo de confirmación es una sugerencia de §13 que solo se hace con el OK de Lucas, pregunta P7).
- Arte final de los íconos de las pestañas: se usan texto y figuras simples.
- Guardar la última pestaña, más pestañas o más teclas.

## Pasos
1. **Comprobar la compuerta** (arriba) y que `git log` trae el código de T207, T208 y T210.
2. **Lógica pura primero:** `BarLayout.button_width/key_label/action_for`, `ExitText.message`, `LevelData.uses_infrastructure()`. Tests de los tres. Correr todo.
3. **Teclas:** agregar `build_10` y `switch_tab` a `project.godot` (con la herramienta Edit). `BuildController` usa `BarLayout.action_for` y saltea los índices sin acción. Test: con 10 torres, `0` elige la décima, `1` la primera y **no se imprime ningún error de acción inexistente**.
4. **Pestañas:** `BarTabs` e `InfrastructureTab`; `Hud` los crea **solo si** el nivel usa infraestructura. Pasar las cuatro tarjetas del RF-457 a `InfrastructureTab` leyendo lo que ya expone `InfrastructureController`. Borrar `infrastructure_panel.gd` cuando nada lo nombre.
5. **Objeto del mapa (RF-458):** probar que tocarlo en «Cañones» abre su panel sin cambiar de pestaña, y que el título de «Infraestructura» muestra el tiempo del trabajo.
6. **Flecha y diálogo (RF-459 a RF-461):** `ExitDialog`, `Game._request_exit()`, el texto armado con `ExitText`, la pausa que se restaura, el caso «Probar» y el de la partida terminada. Confirmar **no llama** a `_commit_collection()`.
7. **Captura real** del nivel 6 y del 10 (24 × 11 con zoom), con 9 y con 10/11 torres (modo de pruebas, «Habilitar todas las colecciones»). Guardarlas en `art/m53-barra/` con un `README.md` corto. Mirar: nada se pisa, el mapa queda igual, se lee el costo de los botones angostos y la insignia del recurso. **Si algo no entra, achicar la letra o acortar el texto, no sacar información**; si hace falta cambiar una medida de la spec, anotarla en el Resultado y en el RF.
8. **Documentos:** `CHANGELOG.md` (lo nuevo para quien juega), `README.md` y `ONBOARDING.md` (teclas `0` y `Tab`, la barra y la flecha), `CONTENIDO.md` si menciona el panel «Infraestructura».

## Hecho cuando
- Los niveles 1 a 5 tienen la barra **idéntica** a la de antes (un test compara posición y tamaño de los botones) y los 6 a 10 muestran las dos pestañas.
- `Tab` y `0` funcionan como dice el RF-456; con 10 torres no aparece ningún error del motor.
- La flecha pide confirmación, dice qué se pierde (piezas pendientes y confirmadas sin guardar, y demolición en curso) y, al confirmar, **no deja nada escrito** en el guardado.
- Todo se puede hacer con toques (sin teclado).
- **Todos los tests en verde** (nunca menos que la línea de base), 0 `SCRIPT ERROR` ni `Parse Error`. Resultado honesto en `03-tareas.md` (qué se probó y qué no: **el celular seguro no**), commit y PR.

## Verificación
- `godot --headless --import`; después `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit 2>&1 | grep -c "SCRIPT ERROR\|Parse Error"` tiene que dar 0.
- `git status` antes del commit: devolver con `git checkout -- assets` lo que `--import` haya reescrito.
- Abrir el juego, jugar el nivel 1 (barra de siempre) y el 6 (pestañas, comprar la demoledora, demoler, cancelar, `Tab`, `0`) y probar la flecha con y sin una pieza recogida.

## Frenar si
- No está registrado el OK de Lucas a M53 (la compuerta).
- Con 10 u 11 torres la barra no se puede leer ni achicando la letra: hay que decidir otro reparto con Lucas.
- `Tab` mueve el foco en vez de cambiar la pestaña, o choca con otra función de la partida.
- Hace falta tocar `ObstaclePanel`, `InfrastructureController`, `ObstacleField`, `FindingRun` o el guardado: el pedido es solo de interfaz.
