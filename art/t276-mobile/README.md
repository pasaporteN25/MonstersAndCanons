# Capturas T276 · barra de la torre en celular

Capturas tomadas con `tools/mobile_probe.gd` desde escritorio, selector **Interfaz: Celular**, 1280 × 720 y proporción objetivo 20:9 (2400 × 1080 a 405 ppi). Sirven para revisar la composición; no son una medición táctil o física de un teléfono.

- `movil_barra_vacia_1280x720.png`: sugerencia y controles de oleada.
- `movil_fantasma_1280x720.png`: costo, tilde y cruz.
- `movil_torre_elegida_1280x720.png`: torre a la derecha, estadísticas y acciones.
- `movil_vender_armado_1280x720.png`: confirmación de venta con moneda y borde doble.
- `movil_mejorada_1280x720.png`: bloqueo breve después de mejorar.
- `movil_sin_oro_1280x720.png` y `movil_nivel_maximo_1280x720.png`: estados deshabilitados.

El probe encontró que el evento de toque inyectado no seleccionó la torre en el mapa; para capturar el estado seleccionado llamó directamente al controlador. Los botones de la barra se ejercitaron con toques simulados.
