# T225 · Nivel 10: la mina vieja (el prototipo completo del bloque 2)

- **Ejecutor:** Sonnet 5.5 · esfuerzo **alto** (es diseño de nivel nuevo)
- **Depende de:** T210, T211, T214 y T224 · **Compuerta:** G4 (T226) · **Tamaño:** mediano

## Leer
- La ficha 10 del plan 08 §5, el 07 §3 ("Ficha pendiente para cada mapa": son los 9 puntos que hay que cubrir) y el 07 §11.B (es el prototipo del bloque 2).
- Los RF de M50 y RF-300 (el Mortero ya debutó en el 9; acá sigue habilitado).
- §7.4 de la spec (aumento de vida por nivel) y los niveles 8 y 9 como referencia de dificultad.
- El Resultado de T223 y T224 (método).

## Objetivo
Crear `data/levels/level_10.json` y sumarlo a `data/campaign.json`:
- Un **mapa nuevo**, que puede ser más grande (hasta 26 × 12, RF-250). Tema `ruinas` con transición a `desierto`: usar la leyenda (arena o rocas rojizas) para sugerir el cambio, o elegir uno de los dos temas y anotarlo.
- Una **mina** con reserva finita (los valores de Q-19), removibles que **dan 1 recurso al azar con semilla** (Q-18 ✎) y un escombro con la **pieza 3/3** de la Disruptora.
- El **Mortero** sigue habilitado (debutó en el 9, Q-21 ✎) y el Francotirador conserva sus dos precios.
- Enemigos: la mezcla del 6 al 9, con Guardián y Curandero juntos. **Sin debuts.** De 18 a 20 oleadas.
- **La ficha completa** (los 9 puntos del 07 §3) va escrita como una subsección nueva de la spec §7 ("Nivel 10 — La mina vieja"), con su RF de campaña, como RF-378. Es 📜: coordinarlo para que no haya otra 📜 abierta.

## Pasos
1. Escribir la ficha y su RF.
2. Armar el mapa (en el editor de T212, si está). `check_level` sin errores ni avisos.
3. Bot, 5 semillas, las 5 estrategias de T214:
   - **`sin_recursos` gana en al menos 4 de 5** (la regla de oro);
   - `extraer_temprano` y `extraer_tarde` ganan con más vidas o más puntos que `sin_recursos`, para que la extracción **valga la pena sin ser obligatoria**;
   - documentar en qué oleada compra el Mortero cada estrategia y cuánto aporta la mina.
4. Agregar el mapa 10 a la exposición y a las capturas, como en M45.
5. Agregar la fuente de la pieza 3/3 en `progression.json`. Comprobar que, con las 3 piezas confirmadas, la Disruptora queda **lista** para el 11 (aunque el 11 todavía no exista).

## Hecho cuando
- El nivel está en la campaña, se desbloquea al ganar el 9 y tiene captura.
- La tabla del bot cumple los criterios de arriba.
- Todos los tests en verde (los que cuentan los niveles de la campaña se actualizan a 10).
- Resultado, `CHANGELOG.md` y `README.md` ("10 niveles"), commit y PR.

## Frenar si
- No hay forma de que la extracción valga la pena sin que `sin_recursos` deje de ganar. Es una decisión de economía para Lucas: llevarle los números.
