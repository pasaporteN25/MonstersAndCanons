# T217 · Disruptora: lógica, datos, Wiki e integración

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T215, T209 (recursos) y T211 (colecciones). T216 es opcional: sin ese arte, se usa el provisional · **Compuerta:** ninguna · **Tamaño:** mediano

## Leer
- La sección M51 de la spec y del plan (T215).
- `scenes/towers/tower.gd`: cómo dispara una torre, cómo se aturde (`stun`, `is_stunned`) y cómo funciona el apoyo del Mecánico.
- `data/towers/tesla.tres` y `mechanical_standard.tres`: copiar la estructura del `.tres` y de los niveles.
- `scenes/enemies/enemy.gd`: `has_aura`, `receive_aura` y el bucle emisor (~380).
- `scripts/logic/tower_text.gd` y `scripts/logic/wiki.gd`.
- `.claude/rules/datos.md` y `gdscript.md`.

## Pasos
1. **Enemigo:** `suppress(seconds)` y `is_suppressed()`. Mientras está suprimido, el bucle emisor **no emite**. Respeta la pausa (el tiempo de juego, como el aturdimiento de las torres). Tests: suprimido no emite; al vencer vuelve a emitir; refrescar toma el máximo; los enemigos sin aura no cambian.
2. **Torre:** un modo de ataque "pulso" (o el patrón que fijó el plan): cada X segundos daña y suprime a los que están en el radio. No dispara proyectiles. Aturdida no pulsa. El desgaste reduce la cadencia. Tests de todo eso.
3. **Datos:** `data/towers/disruptor.tres`, con `reserved = true` (para que no aparezca en los niveles 1 a 10), `required_collection = &"disruptor"`, el costo en oro y recursos, y los niveles 1 a 3, todo con los números del RF. Se suma a `tower_types` al final del orden: **no correr las teclas existentes**. Verificar cómo se asigna la tecla de una torre nueva con RF-300.
4. **Vista:** con el arte de T216 si existe y, si no, uno provisional (dibujo de bobina y anillos). El pulso: anillo que se expande (reusar `ring_effect.gd`). La marca de supresión sobre el enemigo.
5. **Texto:** el panel, la ayuda de construcción y la Wiki ("Suprime el aura de Guardianes y Curanderos durante X s"), armados desde los datos. Agregarla a "Efectos de las torres" si corresponde.
6. **Bot:** la estrategia `mix` la compra cuando hay emisores de aura en el mapa y está disponible.
7. **Modo de pruebas:** la Disruptora aparece con las colecciones habilitadas (T213).

## Hecho cuando
- En un mapa de ejemplo con Guardianes y Curanderos, el bot con la Disruptora pierde menos vidas que sin ella (tabla en el Resultado, 3 semillas).
- Los niveles 1 a 10 no la ofrecen. Los tests de M17 y M18 siguen en verde.
- Todos los tests en verde. Resultado, `CHANGELOG.md` y `CONTENIDO.md`, commit y PR.

## Frenar si
- Hace falta cambiar cómo funcionan las auras de los receptores, más allá de lo que dice el RF.
