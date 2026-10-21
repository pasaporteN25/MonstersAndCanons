# T425 · Spec y división del rediseño desktop
- Ejecutor · Codex, esfuerzo medio/alto
- Depende de · T424 y dirección de Lucas del 2026-10-21 · Compuerta · preguntar si un criterio contradice la dirección aprobada
- Tamaño · Mediano

## Leer
`CLAUDE.md`, constitución P3/P8/P9, reglas `specs.md`, B-45 a B-49, RF-93/RF-111, M68 y T262–T265.

## Objetivo
Escribir requisitos, decisiones, plan y fichas independientes para implementar las mejoras desktop pedidas por Lucas.

## Alcance
Selector de 15 niveles con dos estilos (tarjetas y mapa planetario), identidad por nivel, tarjeta de entrada, panel de torre, revisión de sprites hacia izquierda y análisis de uso de torres/estrellas. Mobile queda fuera salvo una decisión expresa. El mapa refleja estrellas y desbloqueos existentes; no agrega guardado ni cambia balance.

## Pasos
1. Inspeccionar escenas, flujos, datos y contratos actuales antes de numerar RF/D.
2. Definir estados (bloqueado, sin jugar, 1–2 estrellas, 3 estrellas), navegación con mouse/teclado, persistencia del estilo y modo de entrada.
3. Fijar criterios de pantalla/resolución, rendimiento, accesibilidad y pruebas; separar tasks para evitar editar a la vez escenas compartidas.
4. Escribir la sección de spec, decisiones, plan y actualizar T425–T432.

## Hecho cuando
Cada RF tiene Dado/Cuando/Entonces; la spec precisa cómo se representa la conquista gradual y el aterrizaje sin cambiar los desbloqueos. Cada task tiene alcance, archivos, dependencias, pruebas, ejecutor y compuertas artísticas. No se implementa código ni se produce arte final.

## Resultado (2026-10-21)
Escritos M72 (RF-645 a RF-654), D-178 a D-180 y el plan de T425–T432. Los estados del mapa se derivan de progreso existente; la preferencia del selector queda en `settings`, no en progreso. Se definieron límites desktop, pruebas/capturas y compuertas para arte. Se agregaron fichas completas T430–T432. No se implementó código, no se produjo arte y no se corrieron tests de juego; `git diff --check` pasó.

## Frenar si
El estado de campaña actual no alcanza para derivar los cuatro estados visuales, o una petición requiere cambiar criterios de estrellas/desbloqueos.
