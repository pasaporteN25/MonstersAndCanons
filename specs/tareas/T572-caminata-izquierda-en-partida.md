# T572 · Caminata hacia la izquierda: verla en partida y medirla

- Ejecutor · Codex (Terra 6.1) · esfuerzo medio
- Depende de · nada · Compuerta · 🎨 Lucas aprueba cualquier arte · Tamaño · Chico a mediano

## Leer

`specs/tareas/informes/T431-diagnostico-caminata-izquierda.md` y su galería `art/t431-diagnostico/comparison.html`. `scripts/logic/enemy_visual.gd`, `scenes/enemies/enemy.gd` (`_heading`, 462-487). `specs/05-guia-de-arte.md` y D-049.

## Lo que se sabe

Lucas pregunta si la caminata a la izquierda sigue rota o falta. T431 revisó los atlas: cada enemigo tiene fila propia para la izquierda y las piernas alternan, pero **no abrió una partida ni midió nada**, y lo que encontró fue una diferencia de pose. Falta lo que ve quien juega.

## Objetivo

Contestar con evidencia, por enemigo: ¿está rota, falta, o solo se ve distinta?

## Alcance

**Sí:** una herramienta en `tools/` para capturar o medir, un informe en `specs/tareas/informes/T572-caminata-izquierda.md`, capturas, y **solo si hay un error de código**, su arreglo en `scenes/enemies/enemy.gd` o `scripts/logic/enemy_visual.gd` con test.

**No:** producir, retocar ni espejar sprites.

## Pasos

1. Por cada enemigo con atlas, medir en resolución fuente, fila 0 contra fila 2: si los cuadros son distintos entre sí, ancho y alto del contenido, y altura de los pies.
2. En una partida real (nivel 1, que tiene un tramo hacia la izquierda en la fila 4), comprobar qué fila y cuadro se dibujan mientras camina a la izquierda. Registrar también el giro entre tramos: `_heading` se interpola y puede pasar por otra fila. Revisar que `walk_frame` avance en ese sentido.
3. Capturas a tamaño de juego, y a zoom 2,0 si T568 ya está.
4. Clasificar cada enemigo: bien / pose distinta / defecto. Sumar los jefes y la lista de T431.
5. Si hay un error de código: arreglarlo con un test que falle antes. Si no lo hay, decirlo sin vueltas.
6. Si conviene arte: proponer solo los enemigos concretos, con costo en cuadros. Queda para el OK de Lucas.

## Hecho cuando

El informe contesta por enemigo con medidas y capturas de partida real. Un error de código, si lo hay, queda arreglado con test. El arte queda como propuesta, sin producir.

## Verificación

Suite completa sin `SCRIPT ERROR`, si se tocó código. Sin cambios en `assets/sprites/`: comprobar con `git status`.

## Frenar si

Hace falta redibujar para contestar, o la herramienta exige cambiar la escena de los enemigos.
