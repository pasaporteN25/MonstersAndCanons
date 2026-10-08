# T217 · Disruptora: lógica, datos, Wiki e integración

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T215, T209 (recursos) y T211 (colecciones). T216 es opcional: sin ese arte, se usa el provisional · **Compuerta:** ninguna · **Tamaño:** mediano

## Leer
- **La sección M51 de la spec (RF-438 a RF-452) y del plan técnico**, y D-086 y D-087. Está escrita para no tomar decisiones de diseño: todo lo que hace falta está ahí, incluidos los archivos, las pruebas y la forma de comprobar el balance.
- `art/m51-disruptora/FICHA.md` (los colores y la lectura del pulso).
- `scenes/towers/tower.gd`: cómo dispara una torre, cómo se aturde (`stun`, `is_stunned`) y cómo funciona el apoyo del Mecánico.
- `data/towers/tesla.tres` y `mechanical_standard.tres`: copiar la estructura del `.tres` y de los niveles.
- `scenes/enemies/enemy.gd`: `has_aura`, `receive_aura` y el bucle emisor (~380).
- `scripts/logic/tower_text.gd` y `scripts/logic/wiki.gd`.
- `.claude/rules/datos.md` y `gdscript.md`.

## Pasos
1. **Enemigo (RF-442, RF-443, RF-444):** `suppress(seconds)`, `is_suppressed()`, `suppress_left()` e `is_pulse_immune()` (`reflect_range_tiles > 0`). Mientras está suprimido, el bucle emisor **no emite**. Respeta la pausa (el tiempo de juego, como el aturdimiento de las torres). **No se cambia `receive_aura`** ni nada de los receptores. Tests: suprimido no emite; al vencer vuelve a emitir; refrescar toma el máximo; los enemigos sin aura no cambian.
2. **Torre (RF-438 a RF-441, RF-445):** el modo de **pulso** del plan (`suppress_seconds > 0`, `_fire_pulse`, señal `pulsed`). Pulsa **solo con un emisor a su alcance** y no gasta su espera si no hay. Daña a todos los alcanzados **menos al Espejo** y suprime a los que tienen aura. No dispara proyectiles. Aturdida no pulsa. El desgaste reduce la cadencia y el Mecánico la sube. Tests de todo eso (la lista está en el plan).
3. **Datos (RF-446, RF-447, RF-448):** `data/towers/disruptor.tres`, con `reserved = true` (para que no aparezca en los niveles 1 a 10), `required_collection = &"disruptor"`, `resource_cost = 2` y los niveles 1 a 3 con la tabla del plan (los costos de mejorar, 100 y 150, son provisionales). Se suma a `tower_types` al final del orden: **no correr las teclas existentes**. Verificar cómo se asigna la tecla de una torre nueva con RF-300.
4. **Vista (RF-449, RF-451):** con el arte de T216 si existe y, si no, uno provisional (dibujo de bobina y anillos). El pulso: anillo que se expande (reusar `ring_effect.gd`, tope de 8). La marca de supresión sobre el enemigo: el **anillo roto** en el suelo y el **ícono de tres arcos**, **sin teñir** el cuerpo. Mirar una captura real y compararla con el celeste del Hielo.
5. **Texto (RF-450):** el panel, la ayuda de construcción y la Wiki ("Apaga las auras 2,5 s"), armados desde los datos, **y la línea "Contramedida"** en las fichas del Guardián y del Curandero. Agregarla a "Efectos de las torres" **sin números**.
6. **Bot (RF-452):** la estrategia `mix` la compra **por id**, cuando está disponible, hay emisores de aura en el mapa, tiene 3 torres comunes y alcanzan oro y recursos; como mucho 2. `sin_recursos` no la compra nunca. Opción `disruptor=0` para comparar.
7. **Modo de pruebas (RF-447):** la Disruptora aparece con "Habilitar todas las colecciones" (T213) aunque el nivel no la ofrezca, y "+10 recursos" paga su costo.

## Hecho cuando
- En `tools/ejemplos/mapa_disruptora.json` (Guardianes y Curanderos), el bot con la Disruptora pierde menos vidas que sin ella (tabla en el Resultado, 3 semillas). **Si no mejora, se frena y se avisa** (RF-452).
- Los niveles 1 a 10 no la ofrecen. Los tests de M17 y M18 siguen en verde.
- Todos los tests en verde. Resultado, `CHANGELOG.md` y `CONTENIDO.md`, commit y PR.

## Frenar si
- Hace falta cambiar cómo funcionan las auras de los receptores, más allá de lo que dice el RF (RF-443).
- T209 o T211 no están en `[x]` (el costo en recursos y la colección): no se puede terminar la disponibilidad.
- El bot dice que con la Disruptora no se pierde menos vidas: se revisa el balance antes de seguir.
- Hay que tocar la barra o las teclas más allá de agregar la torre al final (RF-448).
