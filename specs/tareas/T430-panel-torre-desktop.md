# T430 · Panel desktop de torres claro y no obstructivo

- **Ejecutor:** Gemini · esfuerzo medio
- **Depende de:** T425 · **Compuerta:** ninguna de arte final para estructura; aprobar muestras antes de integrar assets
- **Tamaño:** mediano

## Leer
`CLAUDE.md`, reglas GDScript/tests, RF-616/RF-618, RF-645–RF-654, `TowerPanel`, `UpgradeDeltas`, escenas y entrada de mapa.

## Objetivo
Simplificar el menú de torre y permitir operar sobre otra torre aunque quede debajo del panel.

## Alcance
Quitar descripción redundante; mostrar el daño actual junto al daño al mejorar y el nivel destino; usar la card de tres colores para identificar el nivel actual; refinar botones y probar transparencia. Definir la solución de selección bajo el panel con la menor sorpresa (reubicación, ocultamiento/foco u otra interacción explícita). El alfa por sí solo no deja pasar el input. Solo desktop.

## Hecho cuando
Se cubren nivel 1→2, 2→3, máximo, sin oro, estados con apoyo/aturdida/desgastada y torre grande; mouse/teclado y foco funcionan; se puede seleccionar una torre bajo el panel sin activar sus botones. Capturas a 1280×720 y 1920×1080, pruebas focales y GUT completo pasan.

## No incluye
Cambios en daño, costo, venta, mejora, interfaz móvil ni balance.

## Resultado
Quitada la descripción redundante; daño actual y daño al mejorar aparecen juntos; el indicador de tres segmentos muestra el nivel actual y el botón dice el nivel destino. El panel es semitransparente, las zonas pasivas pasan clics y «×» lo oculta/deselecciona para seleccionar otra torre. Capturas PC solicitadas a 1280×720 y 1920×1080; la segunda salió a 1853×1042 por el área lógica reportada por Godot. Pasaron las pruebas focales y GUT completo (154 scripts, 2157 tests, 23408 asserts). No se revisó manualmente cada estado visual de apoyo/desgaste ni una torre grande en las capturas; sí pasaron sus pruebas existentes.
