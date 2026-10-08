# T209 · Recursos locales y torres que cuestan recursos

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T207 · **Compuerta:** ninguna · **Tamaño:** mediano

## Leer
- Los RF de M50 de **recursos** y su D. Q-18 y Q-21 a Q-24.
- `scenes/game/level_session.gd`, `scripts/data/tower_data.gd`, `scenes/game/build_controller.gd` (`try_build`, `sell_value`, `sell`), `scenes/game/hud.gd` (la barra superior y los costos de la barra de construcción), `scenes/ui/tower_panel.gd`, `scripts/logic/tower_text.gd` y `scripts/logic/wiki.gd` (la ficha de torre).

## Objetivo
1. `LevelSession` lleva un contador de **recursos** local a la partida: empieza en 0, se suma con las recompensas de demolición (el gancho de T207) y **no se guarda** entre niveles.
2. `TowerData` gana un costo opcional en recursos (`resource_cost`, 0 por defecto). Construir exige y cobra oro **y** recursos. Vender devuelve los dos con el porcentaje de venta, redondeado hacia abajo.
3. HUD: un contador de recursos con un ícono provisional, **solo si el nivel usa recursos** (alguna recompensa, extracción o torre con costo en recursos). La barra de construcción muestra "300 + 3 ⛭" y deshabilita con el motivo.
4. El panel de torre, la ayuda de construcción y la Wiki muestran el costo en recursos desde los datos (RF-164: el texto se arma leyendo los datos).
5. **Mortero** (Q-21 ✎): ponerle el costo en recursos que decidió Lucas en `data/towers/mortar.tres` (300 de oro + 3 recursos, iniciales). Debuta en el **nivel 9** (T224), así que **no cambia el balance** de los niveles 1 a 8. Verificarlo.
6. **Francotirador con dos precios** (Q-21 ✎): se puede comprar **de las dos formas en la misma partida**, 150 de oro o 120 de oro + 1 recurso; en los mapas sin recursos (o con 0 recursos) la segunda opción queda deshabilitada. Con 1 recurso, la venta devuelve 0 (Q-23). Nunca es indispensable.
7. **Drop al azar con semilla** (Q-18 ✎): el removible tiene una probabilidad de dar 1 recurso, sale de la semilla de la partida y el bot lo repite. Es la única excepción a "sin sorteos".

## Pasos
1. Lógica y tests primero: el contador, `can_afford(gold, resources)` y `spend_both`, que es atómico (o cobra los dos o ninguno), además del reembolso.
2. La recompensa de T207 suma recursos.
3. HUD, barra, panel y Wiki.
4. Tests:
   - construir con y sin recursos suficientes;
   - vender (devolución redondeada);
   - un nivel sin recursos no muestra el contador;
   - mejorar no cobra recursos;
   - la recompensa entra una sola vez;
   - el reinicio vuelve a 0.
5. `CONTENIDO.md` (el campo nuevo de las torres) y `CHANGELOG.md`.

## Hecho cuando
- Ejemplo jugable: demoler una roca que da 1 recurso y, con 3 recursos, construir el Mortero en un mapa de ejemplo que lo habilite.
- Los 9 niveles actuales dan lo mismo en el bot.
- Todos los tests en verde. Resultado, commit y PR.
