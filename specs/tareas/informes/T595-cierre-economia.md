# T595 · Economía de cierre de V1

Base de comparación `7575e5f` y candidato T592–T594, en Godot 4.7.2 para Windows. Las simulaciones se ejecutaron con `--fixed-fps 60`, guardados aislados por proceso y semillas iguales por perfil. El bot se inicia con `tools/run_balance_sim.gd` para cargarlo después de los autoloads.

## Ajustes de recursos

- En 7, 8 y 10–15, los removibles ordinarios que ya daban recursos ahora siempre los entregan. Árbol 1, roca y escombros 2, con los mismos costos de demolición. El 9 conserva sus tres escombros de un recurso y las ruinas con hallazgos conservan su recompensa diferenciada. El panel indica la cantidad garantizada.
- El Francotirador cuesta 150 solo en oro o 95 + 1 recurso. El Mortero baja a 250 + 3 y la Disruptora a 100 + 2. Los costos de oro de las mejoras, la producción de mina/bosque y los precios de demolición se mantienen. Las torres usan sus precios nuevos donde estén disponibles, incluido Asedio si las ofrece.
- Una roca de 60 da dos recursos. Usados en dos Francotiradores son 110 de ahorro bruto y 50 netos de oro antes de contar el tiempo. Con dos recursos de escombros de 90 el ahorro neto equivalente es 20. En el 7, `demoler` ganó 5/5 con 13 vidas, 7 recursos por 240 de infraestructura y 350–365 de oro final. Ese perfil solo mide demolición, porque compra sus torres con oro.
- Control de Asedio 11 con `extraer_temprano`, semilla 1. Victoria con 20 vidas, 8 recursos obtenidos y consumidos, 100 de infraestructura y primera compra mixta en la oleada 1. La prueba cubre la opción con recursos en ese mapa de Asedio.

## Oro tardío

El candidato de V1 conserva las recompensas de bajas y los bonos de oleada. La caja alta aparece al llenar todas las casillas y dejar las torres sin mejoras. Cuando el bot invierte en mejorar, la reserva cae y el enfoque de mejora temprana pierde en el 15. Los bonos de las últimas oleadas también forman parte de la caja. El caso medido justifica una prueba humana con mejoras antes de reducir el ingreso de las bajas o del bono.

| Mapa | Perfil, semilla 1 | Oro antes de la oleada final | Resultado | Oro final | Oro en mejoras |
|---|---|---:|---|---:|---:|
| 14 | `sin_recursos mejoras=llenar` | 295 | Victoria, 20 vidas | 388 | 5.270 |
| 14 | `sin_recursos mejoras=temprana` | 404 | Victoria, 9 vidas | 344 | 5.120 |
| 15 | `sin_recursos`, base sin mejoras | 3.833 | Victoria, 2 vidas | 5.426 | 0 |
| 15 | `sin_recursos mejoras=llenar` | 245 | Victoria, 9 vidas | 282 | 5.200 |
| 15 | `sin_recursos mejoras=temprana` | 231 antes de la oleada 26 | Derrota en la 26 | 31 | 3.340 |

En los perfiles de RF-432 se usaron las semillas 1 a 5, sin mejoras, sin infraestructura y con el mismo orden de compra. La base y el candidato ganaron 5/5 en 7 y en cada mapa del 11 al 15. Las vidas coincidieron por mapa (12, 6, 3–5, 5, 3 y 2, respectivamente). El control del 9 en el candidato dio 5/5 con 11 vidas. En el 15 con extracción temprana, ambos ganaron 5/5 y juntaron 24 recursos. El candidato pasó de 12 a 17 vidas y adelantó la primera compra mixta de la oleada 4 a la 3.

## Control del Mortero

El perfil histórico del nivel 9 arrancaba a demoler tras las primeras dos torres. En la base perdió 5/5 en la oleada 3 y juntó tres recursos por 270 de oro. Se corrigió una doble reserva en el bot que hacía exigir su precio dos veces cuando ya era pagable. Aun con esa corrección, demoler demasiado pronto perdió en la tercera oleada en la primera semilla.

En el candidato, el bot defendió primero y empezó a demoler durante la oleada 5, gastó 270 en los tres comunes y compró el Mortero por 250 y los tres recursos en la 7 en cinco de cinco semillas. Ganó las cinco con 13–16 vidas. En los ensayos de una semilla, empezar en la 3 compró en la 5 y ganó con 6 vidas, y empezar en la 7 compró en la 9 y perdió en la 16. El mapa y sus demoliciones conservan los valores anteriores.

## Reproducir

```text
godot --headless --path . --fixed-fps 60 -s tools/run_balance_sim.gd -- x check_rule=1 levels=11-15
godot --headless --path . --fixed-fps 60 -s tools/run_balance_sim.gd -- demoler level=7 seeds=5
godot --headless --path . --fixed-fps 60 -s tools/run_balance_sim.gd -- mortero level=9 seeds=5 mortero_desde=5
godot --headless --path . --fixed-fps 60 -s tools/run_balance_sim.gd -- sin_recursos level=15 seed=1 mejoras=llenar
godot --headless --path . --fixed-fps 60 -s tools/run_balance_sim.gd -- extraer_temprano level=15 seeds=5
```

El oro final incluye el último bono cuando hay victoria. Para ver el saldo de cada oleada se usa una única semilla por proceso. Queda por validar la percepción del ahorro y del sobrante en partida humana, además de las compras táctiles en un APK.
