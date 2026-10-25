# T488 · Vista del atlas con zonas sin descubrir

- **Ejecutor:** Sonnet · UI.
- **Depende de / compuerta:** 🚦 T486 aprobada por Lucas, T487 integrada, T471 integrada (que a su vez espera la aprobación de arte de T469) y 🎨 máscara gris aprobada. **No empezar antes.**
- **Refs:** RF-709, RF-710, RF-688, D-209. **Rama:** `feature/t488-vista-descubrimiento`, desde `origin/main`; un commit `T488: …`, PR a main.

## Objetivo y alcance

Las regiones de zonas sin descubrir no son focalizables ni seleccionables y no dibujan número, candado ni estrellas; el fondo las muestra con la máscara aprobada. Flechas y Enter siguen RF-688. La vista de tarjetas no cambia.

## Archivos previstos

`scenes/ui/campaign_map_view.gd`, `campaign_region.gd`, el fondo del atlas aprobado, tests de la vista. Comparten archivos con T471, T473 y T474: una a la vez.

## Hecho cuando

Los tres estados (solo A, A+B, A+B+C) se ven en PC y celular simulado; el foco por teclado nunca entra en una zona oculta; el 6 o el 11 disponibles se pueden jugar. Capturas a 1280×720; sin teléfono real.

## Frenar si

Falta algún OK; el gris se confunde con el candado y Lucas no aprobó otra solución; una prueba imprime SCRIPT ERROR.
