# M89 · Orquestación de las mejoras de celular

Guía para el agente coordinador. Reparte T563 a T589 entre Haiku, Sonnet, Codex (Terra 6.1) y Opus. La spec es M89 en `specs/01-spec.md`; las decisiones, D-223 a D-230.

**Antes de empezar:** el PR de T562 tiene que estar mergeado. Ese merge es el OK de Lucas a la spec y a sus valores propuestos.

## Pedido para abrir al coordinador

> Leé `specs/tareas/README.md` y `specs/tareas/M89-orquestacion.md`, y coordiná las tareas de M89 en el orden de las olas. No avances por una compuerta sin el OK de Lucas.

## Tablero

| Ola | Tarea | Qué hace | Ejecutor y esfuerzo | Depende de | Compuerta | Archivos principales |
|---|---|---|---|---|---|---|
| 1 | T563 | Cadencia de la Ráfaga | Haiku · alto | — | — | `data/towers/burst.tres`, `tests/test_new_content.gd` |
| 1 | T564 | Marca de torre elegida | Haiku · alto | — | — | `scenes/towers/tower.gd`, `scenes/game/game.gd`, `data/ui/mobile_ui.json` |
| 1 | T565 | Cuadrícula marcada | Codex Terra 6.1 · medio | — | — | `scenes/levels/level.gd`, `scenes/ui/options_menu.gd`, `scripts/autoload/save_manager.gd` |
| 1 | T572 | Caminata izquierda | Codex Terra 6.1 · medio | — | 🎨 si propone arte | informe; `scenes/enemies/enemy.gd` solo si hay un error |
| 1 | T575 | Recursos, agua, estandartes | Opus · alto | — | 🚦 Lucas elige | informe; después `specs/` |
| 1 | T578 | Investigar PvP | Opus · alto | — | — | solo un informe |
| 2 | T566 | Orden de la barra | Sonnet · medio | — | — | `scenes/game/mobile_hud.gd`, `tests/test_mobile_tower_bar.gd` |
| 2 | T568 | Zoom y arrastre | Sonnet · alto | — | — | `scenes/game/camera_controller.gd`, `scenes/game/build_controller.gd` |
| 2 | T569 | Capa de rieles | Codex Terra 6.1 · alto | — | — | `scripts/host/presentation_host.gd`, `scripts/logic/presentation_geometry.gd` |
| 3 | T567 | «Menú» en lugar de X | Sonnet · medio | T566 | — | `scenes/game/game.gd`, `scenes/ui/pause_menu.gd`, `scenes/game/mobile_hud.gd` |
| 3 | T571 | Jefe a pantalla completa | Sonnet · medio | T569 | — | `scenes/ui/boss_presentation.gd`, `scripts/host/presentation_host.gd` |
| 3 | T573 | Doble toque | Sonnet · medio | T568 | — | `scenes/game/build_controller.gd`, `scenes/game/hud.gd` |
| 4 | T570 | Controles en los rieles | Sonnet · alto | T566, T567, T568, T569 | — | `scenes/game/mobile_hud.gd`, `scenes/game/game.gd` |
| 5 | T574 | Foco del tutorial | Sonnet · medio | T570 | — | `scenes/ui/tutorial_overlay.gd`, `scenes/game/tutorial_controller.gd` |
| 6 | T579 | Revisión integrada | Sonnet · medio | T563 a T574, T578 | — | documentos y capturas |
| Después del OK | T576 | Tutorial con las mecánicas | Sonnet · medio | T568, T573, T574, T575 | textos 🚦 | `data/tutorial/tutorial.json`, tutorial |
| Después del OK | T577 | Agua como recurso | Sonnet · alto | T575 | 🚦 mapas y sinergia | `pozo`, mapas y extracción |

**Dentro de una ola**, las tareas no comparten archivos de código, salvo T564 y T567/T570, que tocan zonas distintas de `game.gd`. No correr dos tareas a la vez sobre `mobile_hud.gd`.

**T575 quedó cerrada en documentos:** Lucas eligió el 2026-11-03. T576 espera aprobación de textos; T577 espera decisiones de mapas y sinergia y spec complementaria. T579 no depende de ellas. Ver RF-743–750 y tareas T581–T589.

## Ramas y PR

Las tareas dependen unas de otras, así que no pueden esperar cada una a un merge en `main`:

1. El coordinador crea `feature/m89-integracion` desde `origin/main` actualizado.
2. Cada tarea sale de esa rama como `feature/txxx-nombre-corto` y abre su PR **contra `feature/m89-integracion`**. El coordinador revisa el criterio y lo mergea ahí.
3. La dependencia se cumple cuando la tarea está `[x]` en la rama de integración.
4. Al terminar T579, el coordinador abre un PR de `feature/m89-integracion` contra `main`. **Ese merge lo hace Lucas.** Nunca hay `--force` sobre `main`.

Esto reemplaza el paso 5 de la sección 4 del README solo para M89. Los conflictos en `specs/03-tareas.md` y `CHANGELOG.md` se resuelven conservando las dos entradas.

## Reglas comunes a las fichas

- **Protocolo:** `specs/tareas/README.md` entero, salvo lo de ramas de arriba.
- **Godot:** el README describe Linux. En Windows, desde Git Bash, es `/c/Tools/Godot/godot.cmd`; en PowerShell, `godot`.
- **Tests:** la suite entera en verde y sin `SCRIPT ERROR`. Tomar la cantidad de tests antes de empezar: no puede bajar, salvo un test retirado con su motivo.
- **Textos nuevos:** con `Localization`, en `data/i18n/es.json` y `data/i18n/en.json` (RF-727).
- **Números:** en `data/`, nunca en el código (P2).
- **Arte provisional:** un ícono nuevo se dibuja simple, siguiendo la guía, y queda anotado como provisional en el Resultado. No se espera al arte.
- **Capturas:** van en `Capturas/T5xx-*.png` y necesitan ventana (no sirven en `--headless`). El celular se simula con el `ui_mode` celular.
- **Límite honesto:** nadie en esta ronda tiene un teléfono. Ningún Resultado afirma tamaño físico, pulgar, área segura real ni rendimiento en Android. Eso lo prueba Lucas con la lista de T579.
- **Ideas propias:** a «Sugerencias de Claude» (§13), sin implementarlas.

## Qué frena al coordinador

- T576 espera aprobación de textos; T577 espera decisiones sobre pozos y spec complementaria. T584 espera modalidad de canje; T589 requiere OK de diseño.
- T572 propone arte: no se produce sin el OK de Lucas.
- T568 muestra que el suelo se ve mal a 2,0: se avisa a Lucas, que puede pedir otro tope.
- T563: el bot pierde un nivel que antes ganaba, o gana con una holgura rara.
- T570: un botón no entra en el riel sin bajar de los 6 mm de RF-507.
- Cualquier motivo de la sección 5 del README.

## De dónde sale cada anotación de Lucas

| Anotación | Dónde quedó |
|---|---|
| La imagen de «llega el jefe» no está optimizada | RF-738, T571 |
| ¿Mapas más largos para el celular? | B-64 y D-224: recomendación de no hacerlo por ahora |
| Usar los costados para comprar, zoom y salir | RF-733, RF-734, T569, T570 |
| Salir debería ser el menú de opciones de la PC | RF-735, T567 |
| El zoom acerca poco y no deja moverse | RF-731, RF-732, T568 |
| «Vender» en el lugar de «Empezar oleada» | RF-736, T566, y RF-734 con rieles |
| No se ve qué torre está elegida | RF-737, T564 |
| Cerrar el menú de la torre, totalmente a la izquierda | RF-736, T566 |
| ¿Sigue rota o falta la caminata a la izquierda? | T572 |
| Efecto de foco o «pulsame» en el tutorial | RF-739, T574 |
| Que el nivel 1 enseñe todas las mecánicas | T575, T576 |
| Afinar recursos y estandartes; presentar algo para la parte 2 y la 3D | T575 |
| Investigar PvP con Opus, sin aplicarlo | T578 |
| Doble toque abre el carrito, en PC y celular | RF-740, T573 |
| El agua como recurso | T575, T577 |
| Opción de cuadrícula más marcada | RF-741, T565 |
| La Ráfaga debería ganar más velocidad | RF-742, T563 |


## Continuación T575 · decisiones del 2026-11-03

T581 lecciones por nivel; T582 R1/R2; T583 fuentes y oro; T584 canje; T585 remedición; T586–T588 explicación, avance y medición del Estandarte; T589 diseño de apoyos con 🚦. Dependencias y alcance en cada ficha y tablero. T577 y T584 no resuelven por su cuenta las preguntas de Lucas; los valores se fijan con el bot en T577, T583 y T584. Coordinar archivos compartidos y no paralelizar tareas que los editen.
