# T215 · 📜 Spec de la Disruptora

- **Ejecutor:** Sonnet 5.5 · esfuerzo **alto**
- **Depende de:** T200 (Q-33, Q-25 y Q-29) y T205 (sin otra 📜 abierta) · **Compuerta:** ninguna aparte (Lucas ya respondió en Q-33). Si un valor falta, se pregunta · **Tamaño:** chico · 📜

## Leer
- 07 §9 (la Disruptora: dirección aprobada y pendientes).
- La respuesta de Q-33 en el 09.
- §5.6 (torres nuevas), §6.2 (auras: RF-270 a RF-277) y §6.3 (Chamán y Espejo: RF-280 a RF-287) de la spec.
- La D-041 a D-043 y los RF de M50 de colecciones y recursos (T205).
- `scenes/enemies/enemy.gd`: `has_aura` (línea ~212), `receive_aura` (~219) y el bucle que **emite** el aura (~380).
- `scenes/towers/tower.gd` y `data/towers/tesla.tres`: para **diferenciarla** de la Tesla.

## Objetivo
Escribir en `01-spec.md` (una sección nueva "M51 · Disruptora"), `04-decisiones.md` y `02-plan-tecnico.md` las reglas precisas:

- **Efecto:** un pulso periódico en un radio. Los enemigos **emisores de aura** (Guardián, Curandero y cualquiera con `has_aura()`) alcanzados quedan **suprimidos** durante X segundos: **no emiten** su aura. Los que ya la recibieron la conservan hasta que caduque normalmente (`AURA_DURATION`); escribir si eso alcanza o si la supresión también la corta, con el porqué.
- **Daño** bajo a todos los alcanzados.
- **Lo que no hace:** no afecta al Chamán, al Espejo, al Ladrón ni al Embestidor, ni a otras habilidades (07 §9: "no dar por aprobada la supresión de todas las habilidades").
- **Interacciones:**
  - El Chamán **puede** aturdirla: aturdida, no pulsa.
  - El desgaste del Embestidor reduce su cadencia, como en cualquier torre (RF-367).
  - El Mecánico la apoya.
  - El Espejo **no** refleja un pulso de área: confirmarlo con RF-285 y siguientes, y escribirlo.
- **Mejoras:** niveles 2 y 3 con los valores de Q-33.
- **Disponibilidad:** `required_collection = "disruptor"` (3 piezas, T211) **y** un nivel que la ofrezca (`"torres"` de T203). Costo en oro y recursos (T209).
- **Lectura:** el enemigo suprimido muestra un indicador distinto del aturdimiento violeta, la cura verde y el aura de apoyo cian. Propuesta: un anillo roto **blanco y azulado** sobre el aura apagada. El panel, la Wiki y la ayuda arman su texto desde los datos.
- **Bot:** cómo la usa la estrategia `mix` en los niveles 11 a 15.
- **Arte:** la ficha para Codex (T216): bobina Tesla (Lucas), anillos y pulsos, y una silueta distinta de la Tesla actual (§7 de la guía: familia C).

## Hecho cuando
- Están los RF con criterio, la D (por qué suprimir al emisor, comparada con la Tesla y con el Aislador descartado) y el plan con los archivos que toca T217.
- La ficha de arte para T216 quedó escrita en la sección del plan, o en `art/m51-disruptora/FICHA.md`.
- Resultado, commit y PR.
