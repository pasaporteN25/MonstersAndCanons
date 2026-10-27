# T532 · Bajar el brillo de las franjas temáticas

- **Ejecutor:** Sonnet 5.5 · **Tamaño:** pequeño · **Tipo:** código/presentación.
- **Depende de:** T530 mergeada.

## Leer

- `specs/00-constitucion.md`, RF-699 a RF-702 y RF-726, D-204 a D-206 y D-217
- Host/frame y configuración que dibujan los fondos externos, `art/t478-franjas/` y capturas vigentes T478
- Reglas de `.claude/rules/` correspondientes a scripts y escenas

## Objetivo

Reducir la atención que atraen las franjas laterales con un ajuste uniforme de los fondos existentes.

## Alcance

- Inspeccionar el tratamiento actual antes de elegir un factor de brillo/saturación.
- Atenuar las franjas en todos los temas sin alterar el viewport lógico ni la imagen dentro de él.
- Añadir cobertura de que el efecto solo corresponda al área externa, si la arquitectura lo permite.
- Capturar antes/después en nieve y al menos otros dos temas a 21:9; incluir el celular como simulación si corresponde.

## Hecho cuando

- En la comparación, las franjas se leen más apagadas y con menos saturación; el terreno se reconoce.
- El mapa, HUD, zoom, input, cámara, área jugable y composición en 16:9 son idénticos.
- Se informa la resolución capturada y se diferencia simulación de dispositivo real.
- `godot --headless --import` y GUT completo terminan sin errores ni `SCRIPT ERROR`.

## Frenar si

El oscurecimiento exige cambiar el encuadre del fondo, expandir el mapa, crear arte nuevo o tocar la composición del atlas/selector.
