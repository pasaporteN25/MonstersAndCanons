# T520 · Implementar Mesa de mando en el selector de niveles
- Ejecutor · Sonnet 5.5; revisión visual con Codex `gpt-6.1-sol`, esfuerzo medio
- Depende de · T519 integrado; decisión de Lucas registrada en D-215
- Tamaño · UI, tests, capturas PC y celular simulado

## Leer
- `CLAUDE.md`, `specs/00-constitucion.md`, `.claude/rules/gdscript.md`, `.claude/rules/tests.md`
- RF-687 a RF-698, RF-711 y RF-723 en `specs/01-spec.md`
- M76 y M81 en `specs/02-plan-tecnico.md`; D-215 en `specs/04-decisiones.md`
- `scenes/ui/level_select.tscn`, `scenes/ui/level_select.gd`, `scenes/ui/campaign_map_view.gd`
- `tests/test_menu_layout.gd`, `tests/test_community_select.gd`, `tests/test_mode_tabs_records.gd`, `tests/test_campaign_map.gd`, `tests/test_campaign_map_input.gd`
- `art/t518-selector/README.md` y Mesa de mando PC/celular; tomar las medidas del celular como orientación conceptual porque la captura vertical no coincide con el viewport real apaisado
- La skill Impeccable instalada en `.claude/skills/impeccable/`: contexto, guía de trabajo para UI nativa y craft-floor antes de editar. Reusar las decisiones de Mesa de mando; si falta contexto del producto, aplicar la guía sin modificar ni versionar configuraciones generadas de Impeccable.

## Objetivo
Reorganizar la pantalla completa para que la navegación, el contenido, el progreso y las acciones aprovechen el espacio con jerarquía clara y estética de hierro/bronce, preservando el atlas y las tarjetas.

## Alcance
Sí: `level_select.tscn/.gd`, tests directamente afectados, capturas de la pantalla y actualización de T520 en `specs/03-tareas.md`; CHANGELOG por el cambio visible. El texto de la pestaña queda «Comunidad», sin número en el rótulo.

No: redibujar `CampaignMapView`, tarjetas, niveles, modo de selección, reglas de progreso, arte nuevo, `project.godot`, ni una promesa de teléfono real o rendimiento.

## Pasos
1. Reorganizar jerarquía con contenedores/anclas adaptables: en espacio amplio navegación lateral al estilo de Mesa de mando; cuando el ancho no alcance, una fila de navegación horizontal desplazable. Mantener el área de contenido flexible en 1280×720 horizontal.
2. Reubicar y rotular las acciones actuales; conservar modo de vista, carpeta, total de estrellas/mapas, controles de regreso y DevMode. No crear destinos nuevos ni ocultar páginas dinámicas.
3. Acortar el botón/tab de comunidad a «Comunidad». El conteo de mapas permanece en el indicador de contenido ya existente.
4. Mantener `MenuTouch.attach`, mínimos de 56 px para controles táctiles y `TouchScroller` en cada `ScrollContainer` del modo celular. Asegurar la pestaña activa visible con mouse/touch y AvPág/RePág.
5. Actualizar pruebas de texto y añadir cobertura de bounds al viewport, presencia/acceso a acciones, más modos que el ancho disponible, modo de tarjetas/mapa y carpeta.
6. Capturar campaña en mapa y tarjetas, Comunidad y un modo en PC y celular simulado a 1280×720; anotar que celular es simulado. Ejecutar las verificaciones descritas.

## Hecho cuando
- La vista usa el espacio con una jerarquía reconocible de navegación, título/progreso, contenido y acciones; ningún control fijo se solapa ni sale del viewport.
- Campaña, Comunidad y modos conservan estado y comportamiento; la etiqueta visible es «Comunidad».
- Atlas y tarjetas no cambian de dibujo, datos ni lógica.
- Todas las páginas dinámicas siguen alcanzables y la activa queda visible; la navegación por teclado se conserva.
- En modo celular todos los botones fijos caben, miden al menos 56 px y los scrolls se desplazan con tacto.
- Tests de selector y suite completa pasan sin `SCRIPT ERROR`; `godot --headless --import` termina correctamente (si termina con 139, relanzar y registrar ambos intentos).
- Capturas comparables de PC y celular simulado guardadas en `Capturas/T520-*.png`; CHANGELOG actualizado; el diff no incluye archivos o configuraciones ajenos generados por Impeccable.

## Verificación
1. `godot --headless --import`.
2. `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`.
3. Capturas del motor para las cuatro páginas/estilos y dos modos de interfaz; revisar visualmente y ejecutar el detector mecánico de Impeccable una sola vez sobre los archivos UI modificados.
4. `git diff --check`, revisar `git status`, ignorar/revertir solo archivos generados accidentalmente fuera del alcance.

## Frenar si
- La implementación exige cambiar el contenido o interacción del atlas o las tarjetas.
- Se detecta que las páginas o acciones existentes no pueden conservarse en el marco aprobado.
- El detector requiere cambiar comportamiento o alcance: documentarlo, no introducir cambios extra.
