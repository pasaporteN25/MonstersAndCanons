# T208 · Demoledora global

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio** (o **bajo**: es chica y sigue un patrón ya hecho)
- **Depende de:** T207 · **Compuerta:** ninguna · **Tamaño:** chico

## Leer
- **RF-411 a RF-414** (la demoledora), D-082 y la respuesta de Lucas en Q-08, Q-10 y Q-13.
- El código de T207 (`DemolitionJob`, el panel "Demoler") y `scenes/game/hud.gd`.

## Objetivo
En los niveles que la habilitan, un panel o botón **"Infraestructura"** en el HUD permite comprar la demoledora **una vez por partida**. Desde la compra, cada demolición cuesta el **precio con máquina** (10 % del precio, mínimo 5) **y tarda el 80 % del tiempo** (RF-413, Q-10 ✎) en todo el mapa. No se vende.

## Pasos
1. Leer del nivel la habilitación (`"demoledora": true`, ya parseado en T206) y los números de la máquina de `data/obstaculos.json` (`precio`, `costo_uso_porcentaje`, `costo_uso_minimo`, `tiempo_porcentaje`).
2. Lógica pura en `ObstacleField`: `has_machine`, `buy_machine()` (el cobro lo hace el controlador; no se repite) y `cost_of` / `seconds_of`, que ya tienen en cuenta la máquina. Tests con la fórmula de RF-413 y los casos de amortización de RF-414.
3. HUD: el botón o panel aparece **solo** si el nivel la habilita. Muestra el precio y, después de comprarla, "Demoledora activa" y el costo con máquina en el panel de cada removible.
4. El trabajo **ya en curso** al comprar conserva el precio y el tiempo con los que se ordenó (RF-406, RF-413): no hay reembolso de la diferencia.
5. Ícono provisional. El definitivo llega en T221.
6. Tests: comprar, sin oro, comprar dos veces, el descuento aplicado, el nivel sin habilitar (no se ve) y reiniciar la partida (se pierde).

## Hecho cuando
- Ejemplo jugable con 5 removibles: con máquina, la suma sale más barata que sin ella a partir de 4 demoliciones (07 §5).
- Todos los tests en verde. Resultado, `CHANGELOG.md`, commit y PR.
