# T248 · Barra con pestañas y flecha al menú (M53)

Capturas **reales** de Godot (ventana de verdad, no `--headless`) con clics y teclas reales, todas escaladas a 1280 × 720 (el lienzo base). Las hace `capture.tscn`:

```bash
godot --path . --resolution 1280x720 art/m53-barra/capture.tscn -- nivel=10 colecciones=technology 'pasos=gold:500;wait:10;shot:n10_canones_10;key:0;wait:3;shot:n10_tecla_0'
```

Los pasos (`shot`, `click`, `cell`, `btn`, `key`, `focus`, `measure`…) están en el encabezado de `capture.gd`. Usa un guardado aparte (`user://capture_m53*.json`, se borra al terminar) y **mueve el puntero real del escritorio** antes de cada clic (`Input.warp_mouse`): sin eso, el puntero del escritorio pisa al falso y el mundo ve el mouse en otro lado.

## Qué muestra cada una

| Captura | Qué se ve |
|---|---|
| `n01_sin_pestanas.png` | Nivel 1: la barra de siempre (8 botones de 76 × 60 desde x = 20), sin pestañas. Lo único nuevo es la flecha «← Menú». |
| `n06_canones.png`, `n06_infra.png` | Nivel 6 (removibles, sin demoledora): las dos pestañas; «Infraestructura» trae *Trabajo en curso* y *Recursos*, sin tarjeta de demoledora. |
| `n07_infra_sin_comprar.png` | Nivel 7 (con demoledora): las tres tarjetas, con «Comprar» (180 de oro). |
| `n07_demoliendo_en_canones.png` | Se tocó un árbol del mapa **estando en «Cañones»** y se demolió: la pestaña no cambia sola; el título dice «Infraestructura · 3 s» y el panel del objeto sigue a la derecha. |
| `n07_infra_trabajo.png` | La misma demolición vista en «Infraestructura»: nombre, barra de progreso, «Faltan 3 s», «Cancelar»; la demoledora ya dice «Demoledora activa» y su ventaja leída de los datos. |
| `n07_salir.png` | La flecha abre «¿Volver al menú principal?» con la partida en pausa y el foco en «Seguir jugando». |
| `n07_tab_con_foco_en_un_icono.png` | Con el foco del teclado en el ícono del oro (se ve su ayuda «Oro»), `Tab` cambia de pestaña y **no** mueve el foco. |
| `n10_canones_9.png` | Nivel 10 (24 × 11, con zoom) con las 9 torres de un guardado nuevo: botones de 71 px. |
| `n10_canones_10.png`, `n10_tecla_0_elige_la_decima.png` | Con la colección de avances completa (llega el Mecánico): 10 torres de 63 px, la décima con la etiqueta `0`; `0` la elige. |
| `n10_canones_11.png`, `n10_infra_mina.png` | Modo de pruebas con «Habilitar todas las colecciones»: 11 torres de 57 px (la Mina a la vista en «Infraestructura» con su ficha «Habilitar · 100 de oro»). |
| `n10_salir_con_pieza_pendiente.png` | Se demolió el escombro con la pieza de la Disruptora y se tocó la flecha: el diálogo dice «Perdés 1 pieza de colección recogida… (Disruptora)». |

## Qué se comparó (píxel a píxel, ventana real)

Contra el commit base (`ebcbf8a`), con la misma captura, a 1777 × 999:

- **Niveles 1 a 5:** la barra de abajo, el mapa y «Pausa / Velocidad» son **idénticos píxel a píxel**. Lo único que cambia es la esquina de arriba a la izquierda (la flecha y los contadores corridos).
- **Niveles 6, 7 y 10 (con zoom):** el **mapa es idéntico píxel a píxel** con y sin pestañas. En el nivel 7 la única diferencia de arriba a la derecha es que ya no está el botón suelto «Infraestructura».

## Medidas reales (`measure`)

| Torres | Ancho de botón | Último botón termina en | «Próxima oleada» arranca en |
|---|---|---|---|
| 8 (nivel 1, sin pestañas) | 76 | 698 | 800 |
| 9 (nivel 10, con pestañas) | 71 | 789 | 800 |
| 10 | 63 | 784 | 800 |
| 11 | 57 | 785 | 800 |

«Infraestructura» a 13 pt mide **96 px** (la pestaña entera): no entra. A 12 pt mide 89 y entra con 3 px de margen a cada lado (la spec decía 13; se achicó la letra, como pedía el RF-455).
