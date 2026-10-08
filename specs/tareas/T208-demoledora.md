# T208 · Demoledora global

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio** (o **bajo**: es chica y sigue un patrón ya hecho)
- **Depende de:** T207 · **Compuerta:** ninguna · **Tamaño:** chico

## Leer
- Los RF de M50 de la **demoledora** y su D. La respuesta de Lucas en Q-08 y Q-13.
- El código de T207 (`DemolitionJob`, el panel "Demoler") y `scenes/game/hud.gd`.

## Objetivo
En los niveles que la habilitan, un panel o botón **"Infraestructura"** en el HUD permite comprar la demoledora **una vez por partida**. Desde la compra, cada demolición cuesta el **precio con máquina** (por ejemplo, 10 % del precio, con un mínimo) en todo el mapa. No se vende.

## Pasos
1. Leer del nivel la habilitación (campo de T205) y los precios de `data/obstaculos.json` o del archivo que fijó T205.
2. Lógica pura: `has_machine`, `buy_machine()` (cobra y no se repite) y `demolition_cost(obstacle)`, que tiene en cuenta la máquina. Tests.
3. HUD: el botón o panel aparece **solo** si el nivel la habilita. Muestra el precio y, después de comprarla, "Demoledora activa" y el costo con máquina en el panel de cada removible.
4. El trabajo **ya en curso** al comprar conserva el precio que pagó (no hay reembolso de la diferencia), salvo que el RF diga otra cosa.
5. Ícono provisional. El definitivo llega en T221.
6. Tests: comprar, sin oro, comprar dos veces, el descuento aplicado, el nivel sin habilitar (no se ve) y reiniciar la partida (se pierde).

## Hecho cuando
- Ejemplo jugable con 5 removibles: con máquina, la suma sale más barata que sin ella a partir de 4 demoliciones (07 §5).
- Todos los tests en verde. Resultado, `CHANGELOG.md`, commit y PR.
