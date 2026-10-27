# T534 · Completar traducción inglesa y validar ambos idiomas

- **Ejecutor:** Sonnet 5.5 · **Tamaño:** grande · **Tipo:** traducción/localización.
- **Depende de:** T533 mergeada y revisión de Lucas al inventario de textos.

## Leer

- `specs/00-constitucion.md`, RF-727 y D-217
- Inventario y claves aprobados en T533
- `specs/05-guia-de-arte.md` solo para nombres aprobados de elementos
- Reglas de `.claude/rules/` aplicables a archivos de localización

## Objetivo

Ofrecer una traducción inglesa completa, consistente y revisada de los textos visibles del juego, manteniendo el español como predeterminado.

## Alcance

- Traducir toda clave del inventario de T533 y revisar que no queden textos del jugador codificados fuera del catálogo.
- Conservar placeholders, formatos numéricos, pluralización, nombres propios y términos del canon.
- Comparar PC y celular simulado para menús, selector, partida, pausa, opciones, resultados, Wiki, tutorial, comunidad y errores/mensajes cubiertos.
- Agregar tests de completitud y de integridad de placeholders; corregir recortes o desbordes causados por el inglés.
- Actualizar `CHANGELOG.md` y guías para explicar el selector de idioma cuando corresponda.

## Hecho cuando

- Todas las cadenas del inventario tienen español e inglés; la verificación de cobertura no reporta faltantes ni placeholders distintos.
- El modo inglés no deja textos normales en español; ambos idiomas caben en pantallas PC/celular simuladas.
- Selección persiste tras reiniciar y no altera guardados de progreso, datos de balance ni canon.
- `godot --headless --import` y GUT completo terminan sin errores ni `SCRIPT ERROR`.

## Fuera de alcance

Voces, idiomas distintos de inglés, cambiar el texto canónico en español, nombres internos o documentación exclusiva de desarrollo.

## Frenar si

El inglés exige elegir un término canónico que no esté resuelto en el inventario aprobado. Consultar a Lucas y seguir con cadenas independientes.
