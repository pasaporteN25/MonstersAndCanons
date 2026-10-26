# T518 · Proponer el rediseño de la pantalla de niveles
- Ejecutor · Codex `gpt-6.1-sol`, esfuerzo medio/alto; revisión de Lucas
- Depende de · T515 y T501 integradas; sin compuerta previa para producir maquetas
- Tamaño · propuesta visual; sin cambios de runtime

## Leer
- `specs/01-spec.md`, RF-687 a RF-698 y estado del selector
- `specs/05-guia-de-arte.md`
- `.claude/rules/arte.md`
- `art/t518-selector/README.md`

## Objetivo
Presentar opciones para mejorar la composición completa del selector de niveles en PC y celular: uso del espacio, navegación, textos y coherencia con la estética vigente de hierro, bronce y decoración dimensional.

## Alcance
Sí: seis maquetas a partir de capturas actuales, tres composiciones con adaptación a PC y celular; recomendación razonada.

No: modificar código, escenas, datos, mapa, tarjetas, progresión, navegación ni assets del juego; no afirmar medidas o tactilidad comprobadas en Godot o teléfono real.

## Opciones
- Mesa de mando: navegación lateral y ficha persistente del nivel.
- Bastidor de campaña: navegación superior ordenada, área principal flexible y pie contextual. Recomendación de diseño.
- Lienzo primero: mapa como foco con controles superpuestos.

## Hecho cuando
Las tres opciones tienen capturas PC/celular, conservan el mapa y las tarjetas actuales como contenido, describen sus diferencias y una recomendación, y dejan claro qué decisión falta antes de escribir la spec de implementación.

## Verificación
Revisar visualmente las seis PNG y reproducirlas con `python3 art/t518-selector/sources/generate_mockups.py`; `git diff --check`. No corresponde correr Godot ni GUT porque no hay cambios de juego.

## Frenar si
Una alternativa exige inventar modos, cambiar la conducta de navegación, tocar el mapa o las tarjetas, o cerrar una decisión de producto que Lucas no aprobó.
