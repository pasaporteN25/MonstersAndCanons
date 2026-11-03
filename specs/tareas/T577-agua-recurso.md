# T577 · Pozos que aportan recursos

- Ejecutor · Sonnet · alto · Depende de · T575 · Compuerta · 🚦 decisiones de mapas y sinergia; spec complementaria · Tamaño · dividir si excede una sesión

## Leer
RF-398–404, RF-747, D-233, informe T575 §3, reglas de datos, canon del agua y `specs/tareas/README.md`.

## Objetivo y alcance
Agregar clase de extracción `pozo`, habilitada como mina, que aporta recursos existentes a producción constante por ronda. No crear moneda de agua. Los dos sitios de agua del nivel 11 son referencia; Lucas debe definir dónde agregar fuentes para tres pozos, si la potencia depende de pozos activos y si reemplazan la mina del 11. Sinergia requiere mapas con tres o más fuentes y reglas precisas aprobadas antes de implementarla. El ejemplo 3 pozos/5 por ronda y la propuesta 1 por ronda/reserva 4 no son valores aprobados. Costo, producción, reserva y bonus: **a fijar con el bot en la tarea T577**.

## Archivos y pasos
Revisar `data/obstaculos.json`, niveles aprobados, catálogo/validador y editor de mapas, dibujo de extracción, textos `data/i18n/`, bot y tests correspondientes. Primero resolver preguntas y documentar reglas; medir línea de base y seleccionar valores con bot. Integrar clase, estados y dibujo provisional; actualizar editor, validadores, textos, tests y mapas autorizados. Arte definitivo requiere 🎨.

## Hecho cuando
Pozos dan recursos por ronda según datos y sinergia aprobada, mapas autorizados validan, mapas sin pozo y guardados viejos siguen funcionando, extracción y sinergia están probadas y el balance medido con cinco semillas cumple la regla de oro.

## Verificación y freno
`check_level` por mapa, suite completa sin errores de script, bot `sin_recursos`, `extraer_temprano` y `extraer_tarde` con cinco semillas; comparar línea de base identificada. Frenar ante respuestas o spec complementaria faltantes, o si el bot pierde un nivel que debía ganar.
