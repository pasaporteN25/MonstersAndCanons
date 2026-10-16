# T264 · Maquetas del zoom táctil y de la compra y colocación de torres

Evidencia del informe [`specs/tareas/informes/T264-zoom-compra-tactil.md`](../../specs/tareas/informes/T264-zoom-compra-tactil.md). Todo se generó el 2026-10-16 **en escritorio** (Linux, GTX 1660 Super, Godot 4.7.2) con `tools/t264_touch_mockups.gd`, no en un celular.

- Cada captura es la **partida real** (nivel 1 o nivel 15) dentro del marco negro de 20:9 (1080 × 2400 acostado), con una **capa de maqueta** encima. El cartel de arriba dice **«HOY»** (lo que hace el juego) o **«MAQUETA …»** (una propuesta que **no está aprobada** ni implementada).
- Prefijos: `z` = zoom (Z0 hoy, Z1 propuesta), `s` = dónde se elige la torre (S0 hoy, S1 botones grandes, S2 tienda, S3 barra plegable), `c` = comprar y colocar (C0 hoy, C1 fantasma con tilde y cruz, C2 colocación automática protegida).
- `comparar_*_20x9.png`: hojas con varias capturas a la mitad, para comparar de un vistazo.
- El círculo color piel es el **dedo** (10 mm, supuesto) con la sombra del pulgar; un contorno sin relleno marca dónde estuvo el dedo ya levantado.
- `medidas_20x9.csv`: tamaño de cada control de la maqueta en px virtuales, en mm en el celular supuesto (405 ppi) y alto en mm en el 16:9 chico de T262 (294 ppi).
- `salida_20x9.txt`: lo que imprimió la herramienta (capturas, el modelo de gestos `T264 MODELO` y el modelo de acierto `T264 ACIERTO`).

Para regenerarlo, ver el §13 del informe. Los `.import` que crea Godot no se versionan (`.gitignore`).
