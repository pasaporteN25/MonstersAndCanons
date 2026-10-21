# T428 · Selector alternativo con mapa planetario 2D
- Ejecutor · Claude, esfuerzo medio/alto
- Depende de · T425, T426, T427 aprobada · Compuerta · arte del mapa aprobado por Lucas
- Tamaño · Grande

## Objetivo
Agregar un estilo de selector de campaña que represente el planeta, el aterrizaje y el avance por 15 regiones.

## Alcance
Agregar selector de estilo entre tarjetas y mapa. Derivar estados de región de los datos actuales: bloqueada/sin jugar, territorio con presencia rebelde para victoria menor a tres estrellas y zona tomada con tres estrellas. Permitir elegir niveles desbloqueados con mouse y teclado. El estilo elegido puede persistir solo si T425 lo especifica.

## Hecho cuando
Los dos estilos abren los mismos niveles y reflejan los mismos desbloqueos/estrellas; cambiar de estilo no altera guardado ni progreso. Todos los estados son deterministas; hay pruebas de interacción, foco, datos y escena, capturas en 1280×720 y 1920×1080 y GUT completo sin errores.

## No incluye
Nuevos niveles, geografía jugable, cambios de balance, reglas de campaña o implementación mobile.
