# T432 · Uso de torres y estrellas en los niveles 1–4

**Fecha:** 2026-10-21 · **Entorno:** Godot 4.7.2 · **Alcance:** simulador del bot; no incluye partidas nuevas de personas.

## Resumen

Los resultados no muestran una relación directa entre usar más familias de torres y obtener más estrellas. La composición elegida sí puede cambiar el resultado, pero ningún perfil compara todas las combinaciones posibles. En el nivel 1, el perfil de una sola familia gana con 10 vidas (2 estrellas); en el 4, gana con 16 (2 estrellas). En el nivel 2 y el 3, ese mismo perfil pierde, mientras que perfiles de cuatro y ocho familias ganan. No hace falta usar las ocho familias en todos los niveles.

No recomiendo cambios de balance, estrellas ni torres con estos datos. Lucas ya probó los niveles 1–4 en desktop y los consideró bien; no hay evidencia de una falla que justifique intervenir. La baja frecuencia de 3 estrellas coincide con los umbrales de RF-93 y con estos perfiles del bot, pero no se puede atribuir a la baja variedad de las partidas humanas: no tenemos el detalle de sus torres ni vidas por partida.

## Regla de estrellas

Los niveles 1–4 comienzan con 20 vidas. RF-93, configurada en `data/balance.tres`, otorga:

| Vidas al ganar | Estrellas |
|---|---:|
| 18–20 | 3 |
| 10–17 | 2 |
| 1–9 | 1 |
| Derrota | — |

Los cuatro niveles ofrecen las ocho torres comunes; ninguno agrega torres reservadas.

## Método

Corrí el simulador oficial con `--fixed-fps 60`, sin mejoras, para `basic`, `smart` y `mix`, niveles 1–4, semillas 1–5: **60 partidas, 45 victorias**. Se agregó al JSON de `tools/balance_sim.gd` el campo `tower_usage`, que cuenta las torres realmente construidas por identificador. Una partida corta de humo verificó que el contador se guarda; la corrida completa produjo el JSON usado aquí. El workflow de CI correrá GUT al abrir el PR.

En estos perfiles, los resultados fueron iguales en las cinco semillas de cada celda. Son repeticiones deterministas, no cinco muestras humanas o independientes. `basic` construye solo Ametralladoras; `smart` usa cuatro familias clásicas; `mix` usa las ocho comunes. El bot coloca torres según reglas fijas y no vende ni mejora en esta medición. Los perfiles comparan conjuntos y órdenes de compra completos, no el efecto aislado de sumar una torre.

## Resultados

`V` = victoria con vidas restantes; `D` = derrota. Las estrellas se calculan solo para las victorias.

| Nivel | `basic` · 1 familia | `smart` · 4 familias | `mix` · 8 familias |
|---|---|---|---|
| 1 · Pradera | 5/5 V10 · 2★ | 5/5 V14 · 2★ | 5/5 V20 · 3★ |
| 2 · Desfiladero | 0/5 · D en o15 | 5/5 V17 · 2★ | 5/5 V16 · 2★ |
| 3 · Encrucijada | 0/5 · D en o20 | 5/5 V8 · 1★ | 5/5 V16 · 2★ |
| 4 · Espiral | 5/5 V16 · 2★ | 0/5 · D en o15 | 5/5 V10 · 2★ |

Las familias construidas se confirmaron con `tower_usage`:

| Perfil | Familias realmente construidas |
|---|---|
| `basic` | Ametralladora |
| `smart` | Ametralladora, Cañón, Hielo y Francotirador |
| `mix` | Las ocho: Ametralladora, Cañón, Hielo, Francotirador, Incendiaria, Múltiple, Ráfaga y Eléctrica |

`basic` construyó 41, 71, 125 y 96 Ametralladoras en los niveles 1–4, respectivamente. `smart` construyó 24, 46, 79 y 46 torres; `mix`, 23, 36, 63 y 51. Estas cantidades describen las corridas del bot, no la habilidad del jugador.

## Lectura y límites

- La variedad no predice por sí sola las vidas finales: en el nivel 4, `basic` gana con 16 y `mix` con 10; ambos dan 2 estrellas. En el 2, `smart` termina con 17 y `mix` con 16. El orden fijo y las torres concretas del perfil importan junto con la cantidad de familias.
- `basic` pierde en los niveles 2 y 3, lo que respalda la intención documentada de mezclar opciones desde el nivel 2. No demuestra que todas las familias sean necesarias ni identifica el conjunto mínimo que gana.
- Entre las partidas de bot, 3 estrellas solo aparecen en el nivel 1 con `mix`. El umbral de 18 vidas exige perder como máximo dos. Un Jefe que escapa quita 10 vidas, pero el informe del simulador no registra qué enemigo causó cada pérdida; no atribuyo las vidas concretas a un Jefe sin ese dato.
- El relato humano disponible es de Lucas, en desktop, niveles 1–4: dijo que los ve bien, que el 1 le cuesta algo más, que usa pocas familias y casi nunca obtiene 3 estrellas. No tenemos cantidad de partidas, build, resultado y vidas por partida, torres construidas, mejoras o si el tutorial estaba activado.
- Los resultados actuales concuerdan con M59/T279 para el nivel 2 (mix 16, smart 17, basic pierde). `specs/01-spec.md` §7.4 todavía presenta valores anteriores para algunos perfiles de los niveles 1, 3 y 4; propongo reconciliar esa tabla en una tarea documental separada, sin mezclarlo con este análisis.

## Recomendación

No cambiar balance ni pedir que se usen todas las torres. Antes de cambiar la función de las estrellas, decidir qué deberían comunicar: si 3 estrellas son una distinción de maestría o un resultado esperado de una buena partida. Esa decisión también afecta B-45: el mapa planetario tomaría una zona solo con 3 estrellas y dejaría presencia rebelde con menos, así que la rareza actual de 3 estrellas puede producir un mapa mayormente rebelde.

Si Lucas quiere reabrir la evaluación después de sus pruebas, la evidencia humana mínima útil es registrar por partida build/commit, victoria, vidas/estrellas, familias construidas, mejoras y tutorial activado. La instrumentación del modo de pruebas B-43 sería una tarea aparte. No se recomienda cambiar oleadas ni añadir consejos automáticos con esta muestra.
