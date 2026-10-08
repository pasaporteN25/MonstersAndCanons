# T223 · Niveles 6 y 7: bosque, removibles y rebalance

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio** (la parte de elegir casillas requiere criterio de diseño: si dudás, proponé 2 variantes y preguntá)
- **Depende de:** T208 (demoledora), T209 (recursos), T204 (bot con semillas) y T214 si ya existe (si no, medir con `mix` y anotarlo) · **Compuerta:** la partida de Lucas llega en G4 (T226) · **Tamaño:** mediano

## Leer
- `specs/08-plan-cierre-v1.md` §5, el bloque 2 (fichas del 6 y del 7).
- Los RF de M50 (removibles, demolición, demoledora y recursos) y las respuestas Q-09 a Q-24 (Q-10, Q-18 y Q-21 con los cambios de Lucas del 2026-10-08).
- RF-368 y RF-379 (Embestidor: las rectas y las casillas de impacto que **no hay que romper**) y RF-364 (Ladrón).
- `data/levels/level_06.json` y `level_07.json`, y la línea de base del bot (Resultado de T204).
- `art/campaign-m45/README.md`: cómo se validaron el 8 y el 9 (exposición, encuentros y semillas).

## Objetivo
- **Nivel 6 (Nido, "El lindero")**: tema `bosque`, **2 o 3 removibles** (árbol o roca) que, despejados, abren **casillas mejores** que las libres (por ejemplo, en el interior de una curva). **Sin recursos** (Q-18: el 6 no da). Enseña la demolición directa.
- **Nivel 7 (Cruce, "El aserradero")**: tema `bosque`, **5 o 6 removibles** y `demoledora` habilitada, para que comprarla convenga (07 §5). **Primer drop de recursos** (Q-18 ✎): los removibles dan 1 recurso **al azar con la semilla del mapa** (probabilidad en la leyenda). **Uso chico:** el Francotirador se compra por **150 de oro o 120 de oro + 1 recurso** (Q-21 ✎), y **nunca es indispensable**. Un primer indicio decorativo del símbolo A (T218).
- En los dos: algunas `X` pasan a señales del bloque 2 (T218), y las oleadas **solo se tocan si el rebalance lo exige**.

## Pasos
1. Diseñar dónde van los removibles. **Reglas:**
   - nunca sobre el camino;
   - no tapar las casillas de impacto del Embestidor (RF-379);
   - el mapa **se tiene que poder ganar sin demoler**.
2. Medir con el bot, 5 semillas por estrategia:
   - `sin_recursos` (o `mix` si T214 no está), que **tiene que ganar** en al menos 4 de 5 (en el 7 también sin comprar el Francotirador con recurso);
   - `demoler`, y `demoledora` en el 7.
   - Comparar con la línea de base de T204.
3. Si demoler da **demasiada** ventaja (gana con todas las vidas desde la oleada 1), subir el precio **en la leyenda del nivel**, no en la clase global. Si no da **ninguna**, mover los removibles a mejores casillas.
4. `check_level` sin errores, ni avisos nuevos de atajo.
5. Captura de cada mapa y una tabla del bot en el Resultado: estrategia × semilla, vidas y oleada.

## Hecho cuando
- Los dos niveles tienen tema, removibles y señales.
- `sin_recursos` gana en al menos 4 de 5 semillas, y demoler ayuda sin romper el mapa.
- Todos los tests en verde. `CHANGELOG.md`, Resultado, commit y PR.

## Frenar si
- Para que el mapa funcione hay que cambiar el **camino**: eso es rediseñar el mapa, y lo decide Lucas.
