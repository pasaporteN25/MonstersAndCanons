# T533 · Inventariar textos y establecer Español/Inglés

- **Ejecutor:** Sonnet 5.5 · **Tamaño:** grande · **Tipo:** auditoría y código.
- **Depende de:** T530 mergeada.
- **Revisión:** Lucas revisa el inventario completo antes de iniciar T534.

## Leer

- `specs/00-constitucion.md`, RF-113, RF-555, RF-684, RF-727 y D-217
- `SaveManager`, `OptionsMenu`, todos los recursos de texto, escenas y datos visibles del juego
- Reglas de `.claude/rules/` aplicables a todos los archivos a modificar

## Objetivo

Localizar cada fuente de texto presentado al jugador y crear la base persistente para inglés sin cambiar progreso ni canon.

## Alcance

- Inventariar literales de GDScript/escenas, datos de niveles/modos, tutorial, Wiki, resultados, errores visibles, tooltips y textos dinámicos.
- Registrar cada grupo por escena/fuente, incluyendo textos generados por plural, placeholders, concatenaciones y accesibilidad.
- Proponer y usar claves estables; configurar los recursos compatibles con Godot 4.7.2 y selector de idioma en Opciones.
- Preparar catálogo/infraestructura de idioma y una verificación automatizada para claves sin traducción, duplicadas y placeholders incompatibles.
- Mantener el selector oculto hasta que T534 complete la traducción; no exponer todavía un modo inglés parcial.
- Documentar el inventario revisable antes de traducir.

## Hecho cuando

- Cada fuente textual visible tiene registro, clave/estrategia de traducción y ruta a cubrir; el inventario está listo para la revisión de Lucas.
- El inventario cubre cada fuente textual del jugador, incluidos textos dinámicos y accesibilidad, y queda revisado por Lucas.
- La infraestructura valida claves, duplicados y placeholders; no muestra la opción inglesa hasta completar T534.
- Se documenta que el idioma se almacenará en `settings` sin modificar `SAVE_VERSION` ni progreso.
- Los tests verifican validación del catálogo.
- `godot --headless --import` y GUT completo terminan sin errores ni `SCRIPT ERROR`.

## Fuera de alcance

Completar la traducción inglesa final y habilitar el selector (T534), doblaje, otros idiomas, nombres de archivos/IDs, documentación de desarrollo, cambios de canon o balance.

## Frenar si

Un texto depende de una decisión de canon, legal/narrativa o de un término que Lucas no haya aprobado; registrar el punto para su decisión y seguir con fuentes independientes.
