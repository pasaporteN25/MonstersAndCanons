# T287 · HUD móvil tras la prueba del PR #10

Pedido de Lucas: carrito que responda pegado al borde, controles compactos y redondeados, tilde sin precio, barra inferior con el estilo del juego, sin franjas grises ni línea atravesando la barra de arriba.

## Cambios

- Un único recorrido de toque/clic para los controles móviles. Los íconos no delegan una segunda pulsación al mouse emulado. Un arrastre guarda la posición; soltar fuera del control no lo pulsa.
- Carrito, salida, confirmar y cancelar de 64 px virtuales (mínimo físico 6 mm), íconos SVG propios, fondo oscuro y bronce; tilde con acento verde. En la barra se centran verticalmente para conservar su forma circular.
- Catálogo y barra heredan el tema del juego. Precio en catálogo/barra y motivo inválido en barra. Se oculta la ayuda de construcción de PC que antes se superponía al mapa móvil.
- Un solo borde al pie de la barra superior. Textura del suelo detrás del mapa para cubrir los márgenes del encuadre; no agrega casillas ni cambia caminos.

## Verificación

GUT completo: **1664/1664 pruebas**, sin SCRIPT ERROR ni Parse Error. Cuatro regresiones nuevas empujan eventos por un SubViewport con la escena real: mouse/toque a ambos bordes, mouse emulado, arrastre al otro borde y estado inválido de la tilde. La regresión visual de la tilde falló antes del cambio (precio repetido y tamaño aumentado por el texto); los eventos en escritorio no reprodujeron por sí solos el fallo exacto reportado en el teléfono antes de la corrección.

Las capturas limpias se generan con la partida real, pausando entre estados preparados mediante el controlador; no son partidas humanas. Se revisaron los niveles 1 y 15, catálogo, fantasma y torre elegida. El sondeo anterior también confirmó carrito+tarjeta → fantasma y tilde inferior → construcción, y mantuvo la protección de mejorar/vender. Ese sondeo no seleccionó la torre con su evento de mapa y preparó esa selección con el controlador; no se afirma una prueba física Android.

Reproducción (desde el repositorio):

```powershell
godot --path . res://art/t287-mobile/capture.tscn
godot --path . res://art/t287-mobile/capture.tscn -- wide
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_mobile_hud_input.gd -gexit
```

El sondeo abre una ventana de 1280 × 720 o 1600 × 720; las imágenes capturan el área renderizada del juego (1280 × 720), sin los márgenes negros externos del modo keep. Usa un guardado temporal separado. No mide DPI, tacto, muesca ni legibilidad en un teléfono real: esa comprobación queda para Lucas con la APK.
