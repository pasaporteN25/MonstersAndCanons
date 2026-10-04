# B-23 · Vecinas desde mejoras2/3

Análisis y ensayo completados; las recetas no están activadas en producción. Las reacciones de M20 siguen funcionando como antes, sin vecindad.

## Reglas propuestas

- Ambas torres deben ser nivel2 como mínimo. Comparación con nivel3 abajo. No basta con que solo la receptora mejore.
- Vecinas en las ocho celdas del contorno; en2×2 cuenta todo el borde. No hay alcance circular: vecindad de ocupación. Dos huellas superpuestas no son un par válido.
- La receta **añade un efecto al ataque normal**, sin sustituir daño, modo de apuntado, área, cadenas ni costos actuales. Los porcentajes de ralentización no se suman; usa el más fuerte y su regla actual de duración.
- Recetas direccionales: el estado del compañero habilita el efecto de la receptora. Un mismo efecto no se multiplica con varias vecinas; se elige el mejor por intensidad, después ID/celda para desempatar. No propagar la receta a una tercera torre ni encadenar apoyos.
- Mejorar cualquiera recalcula activación; vender/borrar cancela inmediatamente. Aturdir cualquiera suspende el efecto adicional. Recuperarse lo restablece si el par sigue válido. Proyectiles que ya salieron conservan sus datos al dispararse, evitando cambiar un impacto a mitad de vuelo.
- El brillo y línea entre bases aparece solo al seleccionar o previsualizar; tono del estado, distinto del borde de selección. Panel: nombre de receta, compañera y requisito. Para vecina insuficiente: línea discontinua y 'requiere ambas nivel2'; no mostrar una receta activa falsa.
- Diccionario espacial por casilla y actualización por construcción/mejora/venta/estado; buscar solo contorno. No recorrer todos los pares cada frame. Recalcular una sola vez por cambio y no crear materiales por vínculo.

## Tres recetas iniciales

| Par | Receptora / propuesta inicial | Papel | Riesgo y contramedida |
|---|---|---|---|
| Hielo + Cañón | Cañón añade15% de ralentización durante1s a su área | Control de grupos, sin sumar otro porcentaje a enemigos ya frenados por Hielo | Extiende el bonus de estados a más blancos. Resistencia del Jefe reduce el control; aturdir/separar suspende |
| Hielo + Múltiple | Múltiple añade15% durante1s a sus blancos | Reparte control leve; no copia el40–60% del Hielo | Puede volver redundantes varios Hielos. Pocos blancos, sin acumulación y nivel mínimo en ambas |
| Incendiaria + Eléctrica | Eléctrica aplica quemadura2/s durante1s a sus objetivos alcanzados | Aprovecha cadenas y el bonus de daño contra quemados existente | Más peligroso: el propio rayo puede habilitar su bonus30%. No copiar todo el daño de la Incendiaria; solo una aplicación por blanco/impacto |

Estos valores viven solo en el laboratorio; necesitan spec/datos y campaña antes de producción. No introducir detención total, daño doble ni copia íntegra de habilidades en esta primera tanda.

## Nivel2 frente a3

Inversión total real (construcción + mejoras de ambas torres), leída de los .tres actuales:

| Par | Ambas nivel2 | Ambas nivel3 | Aumento para exigir3 |
|---|---:|---:|---:|
| Hielo/Cañón | 365 | 655 | 290 |
| Hielo/Múltiple | 345 | 605 | 260 |
| Incendiaria/Eléctrica | 430 | 750 | 320 |

**Recomendación:** habilitar ambas2 para que sea una decisión durante la partida, con efectos pequeños y sin multiplicación. Exigir ambas3 concentra inversión y aparición tardía; no demuestra mejor balance, solo retrasa el acceso. Una receta fuerte futura podría exigir3, declarando el requisito por receta, sin cambiar todas.

## Ensayo ejecutado

`godot --headless --path . res://art/redesign-m36/combo_lab.tscn` genera `combo_results.json`. Usa Enemy.take_hit, quemadura/ralentización y Rules reales; no altera recursos.36 casos: tres receptoras × dos mejoras × armaduras0/4/12 × resistencia al frío0/50%,20 segundos por caso. Un enemigo inmóvil con vida suficiente evita muerte antes de terminar; daño de la compañera excluido para aislar la receta. No simula alcance, trayectorias, grupos, oleadas, economía ni la elección de posiciones del bot: **no es validación de campaña**.

En armadura4 y sin resistencia:

| Receptora | Nivel | DPS sin receta | DPS con receta | Frenado equivalente en20s |
|---|---:|---:|---:|---:|
| Cañón |2|16,80|16,80|1,80s|
| Cañón |3|27,60|27,60|1,80s|
| Múltiple |2|6,50|6,50|3,00s|
| Múltiple |3|10,40|10,40|3,00s|
| Eléctrica |2|12,75|14,45|0|
| Eléctrica |3|21,85|23,75|0|

En este ensayo las recetas de Hielo aportan control, sin aumento directo de daño. Eléctrica suma13,33%/8,70% respectivamente por quemadura y estado; su beneficio relativo cambia con armadura y también afectará cada salto, que este caso de un objetivo no mide. Esto justifica empezar con2/s y no copiar el fuego completo. Resistencia50% reduce a la mitad el frenado equivalente de las dos recetas de Hielo.

Topología: diagonal y borde2×2 válidos; distancia de dos celdas, nivel1, aturdida y vendida inválidos, todos comprobados.100000 pruebas de par tardaron alrededor de29ms en esta máquina: es un microbenchmark del predicado, no tiempo de frame del juego.60 torres tienen1770 pares si se compara todo; el índice por casilla evita ese recorrido constante.

Antes de integrar: prueba de tres blancos/cadenas/área, fuego y resistencia; bot con semillas fijas y mapas de varias formas, comparación con/sin receta y con presupuestos iguales. Rechazar si el bonus vuelve obligatoria una pareja o deja sin función a Hielo/Incendiaria. Entrega actual concluye con estas reglas, resultados y recomendación; activar la mecánica requiere elegir recetas y completar esa validación.
