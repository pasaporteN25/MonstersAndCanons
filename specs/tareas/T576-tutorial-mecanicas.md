# T576 · Tutorial del nivel 1

- Ejecutor · Sonnet · medio · Depende de · T568, T573, T574 y T575 integradas · Compuerta · Lucas aprueba textos · Tamaño · mediano

## Leer
RF-570–577, RF-731–732, RF-739–740, RF-743–744; D-231; informe T575 §4.2; reglas de datos y tests.

## Objetivo y alcance
Aplicar T-2 al nivel 1 en PC y celular. Conservar pasos actuales, salteo y «volver a verlo»; agregar zoom por rueda o pinza/«+», arrastre de un dedo y doble toque en celular, y dos tarjetas de lectura: avance y su desbloqueo, y lo que viene. No introducir esas mecánicas en el mapa ni cambiar balance. Las lecciones son T581. Textos del informe orientativos, requieren aprobación de Lucas.

## Archivos
`data/tutorial/tutorial.json`, `data/i18n/es.json` y `en.json`, `scenes/game/tutorial_controller.gd`, `scripts/logic/tutorial_flow.gd`, overlay y tests de tutorial según necesidad; capturas y `CHANGELOG.md`.

## Pasos
1. Verificar dependencias y señales de zoom, arrastre y doble toque.
2. Redactar las dos tarjetas y pedir aprobación de Lucas. Incorporar pasos de acción adecuados por plataforma y sus textos en ambos idiomas.
3. Comprobar pasos, salteo y repetición; tomar capturas en PC y celular simulado.
4. Correr el bot `mix` en nivel 1 y suite completa; informar límites.

## Hecho cuando
Recorrido completo en ambas interfaces, gestos correspondientes funcionan, ambas tarjetas aprobadas aparecen, saltear y repetir funcionan, mapa y balance siguen iguales y el bot gana el nivel 1.

## Verificación y freno
Suite completa sin errores de script, capturas de pasos nuevos y bot; no afirmar comprensión de una persona nueva ni prueba en teléfono real sin hacerla. Frenar ante textos sin aprobación o dependencias faltantes.
