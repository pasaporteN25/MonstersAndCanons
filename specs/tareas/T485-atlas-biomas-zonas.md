# T485 · Atlas con silueta, terreno y tres zonas visuales

- **Ejecutor:** GPT‑6.1‑sol, esfuerzo alto; Impeccable local para refinamiento y crítica.
- **Depende de:** dirección B de T484 elegida por Lucas; auditoría independiente de los quince niveles antes de asignar biomas y modelar estados.
- **Rama:** `feature/t483-recorrido-organico`, PR #79; un commit propio `T485: …`, sin reescritura ni merge.
- **Refs:** RF-691/RF-695, T469/T471, T483/T484; pedido de Lucas de revisar silueta/terreno y explorar descubrimiento en tres grupos de cinco.

## Pedido e interpretación

El recorrido B se conserva. Lucas pide una silueta y terreno más verosímiles y biomas que correspondan a los niveles existentes. Propone tres zonas 1–5, 6–10 y 11–15: las posteriores comenzarían grises y se revelarían por grupos con el progreso. Esta regla se revisa contra RF/D antes de tratarla como comportamiento: la muestra no cambia runtime, desbloqueos, guardados ni progreso.

## Análisis previo

T483/T484 resolvieron el aterrizaje y el recorrido, pero conservaron literalmente un contorno angular y un campo oliva casi uniforme. La nueva devolución habilita estudiar la propia geografía. La dirección visual de T428 sigue siendo la referencia de paleta, relieve cartográfico y jerarquía: el mapa debe parecer el mismo atlas, ahora con costa menos repetitiva y accidentes que den contexto al recorrido.

La silueta se organizará con masas de escala diferente, entradas de mar desiguales, algunos promontorios y corredores interiores. El recorte continental evitará tanto la cápsula alargada como una sucesión de ondas/óvalos. El terreno será continuo, con transiciones irregulares y símbolos cartográficos dispersos que correspondan al contenido verificado. La ruta B no se redibuja para acomodarla a manchas decorativas.

## Auditoría recibida y decisiones de muestra

La auditoría independiente confirmó y se contrastó localmente: 1–5 pradera; 6–7 bosque; 8–9 ruinas; 10–12 desierto (10 con restos de transición); 13 nieve; 14 ruinas; 15 pradera. No se modifica el campo `tema` ni se agregan volcán o pantano. La costa, cauces, crestas y ubicación de terreno siguen siendo concepto de muestra para aprobar, sin fijar geografía canónica nueva.

Se explora revelar 1–5 al principio, 6–10 al desbloquear 6 y 11–15 al desbloquear 11, conservando apertura individual N→N+1. Los tres estados ilustran selección 3/6/11 y progreso anterior ficticio; no leen guardados. Descubierto no significa ganado ni accesible: se mantienen candados posteriores y estrellas independientes. Es propuesta compatible con el objetivo de RF-691, pendiente de aprobación y de especificar guardados antiguos, pruebas y tono de regiones no conquistadas antes de código. No se asignan RF/D finales por dibujarla.

## Hecho cuando

Hay fuentes editables, trazabilidad nivel→tema, capturas comparables y visor que permita revisar el atlas y, si es compatible con el alcance, tres estados visuales claramente rotulados como propuesta. Un crítico independiente evalúa geografía, fidelidad de biomas, coherencia con la ruta B y lectura de los estados. Lucas puede aprobar/rechazar cada aspecto antes de integrar. El PR #79 se actualiza; #78 se cierra solo después, por el pedido condicional de Lucas, conservándolo como referencia supersedida.

## Verificación y resultado

Muestra y tres estados listos para revisión, **sin aprobación final ni integración**. Se conservó B y se revisaron costa, relieve y biomas. La primera crítica encontró parches de color, nieve demasiado costera, ruinas 14 poco distintas y pradera 15 beige. Se corrigieron con lavados graduales, cresta nevada sobre una masa noreste mayor, restos agrupados y valle verde. Otra revisión encontró cortes verticales de descubrimiento: se reemplazaron por máscaras serpenteantes suavizadas. La crítica independiente final consideró el resultado listo para Lucas; observó franjas paralelas leves en el límite, no bloqueantes de esta muestra.

**Verificado:** SVG rasterizado con Godot 4.7.2 en carpeta temporal aislada, composición Pillow e inspección de los tres PNG 1280×720. Coordenadas y geometría B exactas; 1.201 puntos de ruta en tierra con X creciente, discos visibles completos en tierra, máscaras con centros 1–5/1–10 exactos y candados individuales coherentes en cada estado. Tabla 15/15 contrastada con JSON. `git diff --check` limpio. Impeccable detect dio seis avisos al suponer fondo blanco en elementos con fondo CSS oscuro heredado; contrastes declarados superiores a 9,9:1. Enlaces locales del HTML comprobados; no se pudo verificar el visor interactivo porque CUA no tiene navegadores disponibles.

**No se probó:** juego, importación, GUT local, bots, input, teléfono, rendimiento o integración. No se modificaron runtime ni datos de nivel. El CI remoto se registra en el PR, sin asumir resultado antes de terminar. El PR #79 contiene un commit por T483/T484/T485; #78 se cierra como supersedido solo después de actualizar #79, por el pedido condicional de Lucas. T469/T471 continúan pendientes del OK de arte y de especificar el descubrimiento antes de código.
