# T575 · 📜🚦 Definir recursos, agua, estandartes y lo que se guarda para la parte 2 y la versión 3D

- Ejecutor · Opus · esfuerzo alto
- Depende de · nada · Compuerta · 🚦 **Lucas elige antes de escribir los RF** · Tamaño · Mediano

## Leer

`specs/04-decisiones.md`: D-229. `specs/01-spec.md`: RF-360, RF-361, RF-398 a RF-417, RF-574 a RF-577. `specs/10-universo.md` (oasis, agua, §5 avances). `specs/06-monsters-canons-3d.md`. `data/obstaculos.json`, `data/levels/*.json` (niveles con `demoledora`, `mina`, `bosque_explotable` y `agua`), `scenes/game/level_session.gd`, `scripts/logic/support_rules.gd`.

## Objetivo

Lucas quiere que **el nivel 1 sirva para entender todas las mecánicas**, y reconoce que los recursos y los estandartes están sin afinar. También quiere pensar el **agua como recurso**, por cómo se armó la historia, además de los árboles, y **presentar o guardar** algo para la parte 2 y la 3D. Esta tarea no programa: deja una elección clara para Lucas.

## Hechos de partida (comprobarlos)

- Hay **una sola moneda de recursos**. Sale de árboles y rocas (con probabilidad), de escombros, de minas y de bosques explotables.
- La demoledora aparece recién en el nivel 7; las minas y bosques, en los niveles 10 a 15.
- El Estandarte exige cinco avances y **no se puede construir en los niveles 1 a 5** (RF-360). Además RF-577 prohíbe cambiar el mapa, el oro y las oleadas del nivel 1. **Enseñar todo en el nivel 1 choca con estas dos reglas.**
- El agua hoy es un dibujo de leyenda, no un objeto, en los niveles 1 a 4 y 11.

## Qué tiene que contestar el informe

`specs/tareas/informes/T575-mecanicas-y-agua.md`, en español claro, con una recomendación en cada punto:

1. **Recursos:** qué le falta para sentirse una mecánica, con datos: cuánto se gana y en qué se puede gastar por nivel.
2. **Estandartes:** cómo se entienden hoy, qué tienen de confuso y qué afinar.
3. **Agua**, comparando al menos:
   - A: otra fuente de la **misma** moneda (una clase de extracción `pozo`). Costo bajo.
   - B: una **segunda** moneda. Costo alto: guardado, HUD, costos de torres, editor, bot y balance.
   - C: dejarla como historia en la V1 y presentarla en la parte 2.
   
   Sumar qué dice el canon, qué niveles cambian y cómo se vería.
4. **Tutorial del nivel 1:** una lista de pasos concreta. Para cada mecánica: se enseña jugando, se **presenta** con una tarjeta sin que se pueda usar, o se enseña la primera vez que aparece en su nivel. Decir qué regla se enmienda en cada caso. Incluir los gestos nuevos: zoom, un dedo y doble toque.
5. **Parte 2 y 3D:** qué mecánica conviene reservar o adelantar, y cómo se presenta sin prometer lo que no se va a hacer.
6. **Costo:** tareas, modelo y riesgo por opción, incluido el rebalanceo con el bot.

Mostrar simulaciones si hacen falta. No cambiar datos del juego.

## Después del OK de Lucas

1. Registrar la elección en la entrada de T575 y en `specs/04-decisiones.md`.
2. Escribir los `RF` y `D` con el siguiente número libre y actualizar `10-universo.md` si cambia canon.
3. Completar `T576-tutorial-mecanicas.md` y `T577-agua-recurso.md` con su alcance y «Hecho cuando» reales; cancelar T577 si no se hace.

## Hecho cuando

El informe está en el PR y Lucas eligió. Quedan escritos los `RF`, `D` y las fichas T576 y T577. Sin cambios en `data/` ni en código.

## Verificación

Sin correr el juego no se afirma balance: las cifras salen de los datos o del bot, y se dice de cuál. Los números de `RF` no se reusan.

## Frenar si

Lucas todavía no eligió: se entrega el informe y se espera. Las demás tareas siguen.
