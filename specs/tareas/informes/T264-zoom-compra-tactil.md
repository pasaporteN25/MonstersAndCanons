# T264 · Zoom táctil y flujo de compra y colocación de torres

> **Estado: PROPUESTA PARA DECIDIR EN G7. Nada de esto está aprobado.** Escrito el 2026-10-16 por Claude (Opus 5.5, esfuerzo medio), tarea **T264** (B-35). **No se tocó código, escenas, datos ni assets del juego.** Lo nuevo es una herramienta de maquetas (`tools/t264_touch_mockups.gd` y su `.tscn`) y las muestras de [`art/t264-zoom-compra/`](../../../art/t264-zoom-compra/).
>
> **Pedido (B-35):** poder hacer zoom en el celular (clave para Lucas) sin que el gesto compre o elija por accidente; evaluar torres de compra más grandes y una tienda o carrito desplegable; comparar «previsualizar, ajustar y aceptar con tilde o cancelar» con «colocación automática protegida»; precisión del dedo, oclusión, pasos, rapidez durante oleadas y torres de 2 × 2. **La tilde, el carrito y la colocación automática son alternativas abiertas**: acá se comparan, se recomienda y se listan los casos de error; decide Lucas.
>
> **Línea de base:** el informe [T262](T262-analisis-mobile.md) y sus capturas de `art/t262-mobile/`. No se repite su relevamiento: se usan sus números (celular supuesto de 1080 × 2400 a 405 ppi, escala 1,5, **1 px virtual = 0,094 mm**) y sus hallazgos P-02 (comprar al apoyar; arrastrar y pellizcar compran), P-03 (sin zoom; casillas de 4,5 a 6,0 mm), P-12 (la casilla sale de la posición del mouse) y P-13 (en pausa no se construye).
>
> **Límite principal:** no hay celular. Las muestras son la partida real, en escritorio, con la proporción de 20:9, y una **capa de maqueta encima**. El dedo es un dibujo de 10 mm. Las cuentas de toques salen de un **modelo de los gestos**, no de personas jugando (§11).

## 0. Resumen (para quien lea solo esto)

1. **El zoom resuelve la precisión; las reglas de gestos resuelven las compras por accidente. Hacen falta las dos cosas.** Con zoom al máximo propuesto (casilla de **96 px virtuales = 9,0 mm**, ×2 en los niveles 13 a 15) el modelo de acierto pasa de **55–95 %** en una casilla de 4,5 mm a **95–100 %** (§3.3). Pero si comprar sigue siendo «al apoyar el dedo», la pinza que hace zoom **compraría una torre cada vez** (T262, prueba C). Por eso el §6 fija reglas comunes a todas las variantes: **nunca se compra al apoyar, dos dedos nunca compran, un dedo que se movió más de 2 mm no es un toque**.
2. **Zoom (Z1, recomendado):** pinza para acercar y alejar, **dos dedos para desplazar** (un dedo también, cuando no hay torre puesta para colocar), un botón **«Ver todo»** que vuelve al encuadre de hoy, y del encuadre de hoy hasta casilla de 96 px. Con zoom al máximo se ve **la cuarta parte del mapa del nivel 15** y el 44 % del nivel 1: hay que desplazar. El mapa en miniatura es opcional.
3. **Colocar: dos flujos comparados con imágenes.**
   - **C1 · fantasma con tilde y cruz:** el toque pone una **torre fantasma sin cobrar**; arrastrar un dedo la corre (sin taparla); la **tilde** (9,0 × 8,3 mm, arriba del fantasma, con el costo) compra; la **cruz** la saca. **0 compras por error en los 8 casos probados**, igual con o sin zoom, con 1 × 1 y con 2 × 2. Cuesta **1 toque más por torre** (3 en vez de 2).
   - **C2 · colocación automática protegida:** con la casilla en pantalla de al menos 7,6 mm, **el toque construye al soltar** y aparece **«Deshacer»** 3 s (devuelve el 100 %). Si la casilla es más chica, **el toque no compra: acerca el mapa alrededor del dedo**, y el siguiente toque construye. También **0 compras por error** en el modelo; es más rápido **cuando ya hay zoom** (6 toques para 5 torres, contra 11 de C1) pero se comporta distinto según el zoom, y el primer toque «que acerca» puede sorprender.
4. **Dónde se elige la torre:** la barra de hoy tiene botones de **7,1 × 5,6 mm**. Se compararon **S1** (la misma barra con botones de **9,4 × 8,3 mm**, sin «Próxima oleada»), **S2** (tienda o carrito: un botón «Torres» abre tarjetas de **18,4 × 10,2 mm con nombre y costo**; +1 toque cada vez que se cambia de torre) y **S3** (la barra grande de S1, **plegable**). **Hallazgo:** esconder la barra **casi no agranda el mapa sin zoom** (+3 % en el nivel 15, 0 % en el nivel 1), porque el encuadre de hoy lo limita el ancho; lo que se gana es ver **una fila más con zoom**.
5. **Recomendación (para discutir, no cerrada):** **Z1 + reglas de gestos + C1 + S3**, y dejar **C2 como atajo opcional** para después de probar C1 en el celular de Lucas. C1 es el único flujo que no depende del zoom para ser seguro, explica lo que va a pasar antes de cobrar y sirve igual para 2 × 2; su costo (un toque más por torre) es chico frente a perder el 30 % y 5 toques más por cada compra en la casilla equivocada que pasa hoy (§7). **Lo que tiene que decidir Lucas está en el §10.**

## 1. Punto de partida (de T262, sin repetirlo)

| Hoy | Dato de T262 | Consecuencia para T264 |
|---|---|---|
| Comprar = **2 toques** (botón + casilla), **sin vista previa antes** | Pruebas A, B y C; `build_controller.gd:272-280, 315-317` | La compra ocurre al **apoyar** el dedo: arrastrar y pellizcar con una torre elegida **compran** |
| Casillas de **6,0 mm** (1 a 9), **4,9** (10–11), **4,6** (12), **4,5** (13–15), **sin zoom** | §1.6; `rules.gd:23-24` | En el 15, un corrimiento de 0,6 casilla (2,7 mm) ya es la casilla de al lado |
| Botón de torre **7,1 × 5,6 mm** | `sizes_20x9.csv` | Debajo de los 7,6 mm (48 dp) de Android |
| La casilla sale de la posición del **mouse emulado** | P-12; `build_controller.gd:234, 279, 285` | Las reglas nuevas tienen que leer el **toque** (`InputEventScreenTouch` / `ScreenDrag`), no el mouse emulado |
| En pausa no se construye y pausar suelta la torre elegida | P-13; RF-104; `game.gd:467-472` | No se puede «parar y pensar dónde va» (§10, decisión D4) |
| Corregir una compra en la casilla equivocada | Con la torre elegida, tocar otra torre **no** abre su panel (`build_controller.gd:268-280`) | Soltar la elección, tocar la torre, «Vender» (devuelve el 70 %, `data/balance.tres`), volver a elegir y tocar: **5 toques más y se pierde el 30 %** |

## 2. Cómo se hicieron las muestras

- **Herramienta:** `tools/t264_touch_mockups.gd` (nombre propio de T264; T263 usa los suyos). Abre la **partida real** del nivel 1 (20 × 9) y del nivel 15 (26 × 12) con un guardado temporal (`user://t264_touch_mockups.json`, se borra), pone la cámara donde hace falta y usa la **vista previa real de `BuildController`** (casillas verdes o rojas, torre fantasma y alcance). Lo que todavía no existe (tilde, cruz, tienda, barra grande, «Ver todo», «Deshacer», el mapa en miniatura y el dedo) se dibuja en una **capa de maqueta** encima. **Cada captura dice arriba «HOY» o «MAQUETA …»**.
- Carga la partida con `load` (no `preload`): compila con `--check-only` sin autoloads.
- **Todas las capturas tienen el mismo tamaño** (la pantalla lógica de 1280 × 720 dentro del marco de 20:9 que agrega `stretch/aspect = keep`, 1600 × 720), el **mismo nivel** y la **misma casilla** en el «antes» y el «después».
- **El dedo:** un círculo de **10 mm** (la yema apoyada, **106 px virtuales**) y la sombra del pulgar (16 mm de ancho) que viene desde abajo a la derecha. Es un supuesto razonable para un adulto, no una medida de Lucas. Un contorno sin relleno marca dónde **estuvo** el dedo (ya levantado).
- **Medidas** de cada control nuevo en `art/t264-zoom-compra/medidas_20x9.csv` (px virtuales, mm en el celular supuesto y alto en mm en el 16:9 chico de T262, 294 ppi).
- No se usó `tools/mobile_probe.gd` para los toques: T262 ya midió con él lo de hoy (pruebas A a G). Lo nuevo (las reglas propuestas) no existe en el juego, así que se probó con un **modelo** (§7).

**Hojas de comparación** (cada una junta las capturas a la mitad, «hoy» a la izquierda arriba):

| Hoja | Qué compara |
|---|---|
| `comparar_zoom_20x9.png` | Nivel 15 y nivel 1: hoy contra zoom al máximo, con el mismo dedo en la misma casilla |
| `comparar_tienda_20x9.png` | Nivel 15: barra de hoy, S1, S2 cerrada y abierta, S3 abierta y plegada |
| `comparar_colocacion_20x9.png` | Hoy (ya compró), C1 fantasma, C1 ajuste, C1 en el 15 sin zoom, C2 acerca, C2 «Deshacer» |
| `comparar_2x2_y_errores_20x9.png` | Mortero (2 × 2) hoy y con C1 + zoom; casilla que no se construye; fantasma en el borde |

## 3. Zoom y desplazamiento

### 3.1 Muestras

| Hoy (Z0) | Propuesta (Z1) | Qué se ve |
|---|---|---|
| `z0_n15_hoy_20x9.png` | `z1_n15_zoom_20x9.png` | Nivel 15: casilla de **4,5 mm**; el dedo tapa la casilla, sus vecinas y la vista previa entera. Con ×2 la casilla mide **9,0 mm** y el mismo dedo tapa más o menos una |
| — | `z1_n15_zoom_vista_20x9.png` | Lo que entra con el zoom máximo: un cuarto del mapa; «Ver todo» y la miniatura |
| `z0_n01_hoy_20x9.png` | `z1_n01_zoom_20x9.png` | Nivel 1: de **6,0 a 9,0 mm** (×1,5) |

### 3.2 Cómo funcionaría (propuesta Z1)

- **Rango:** desde el encuadre de hoy (RF-251, todo el mapa) hasta que la casilla mida **96 px virtuales**: **9,0 mm** en el celular supuesto y **8,3 mm** en el 16:9 chico. Por nivel:

| Niveles | Mapa | Zoom de hoy | Zoom máximo | Aumento | Casilla hoy → máx. (mm) | Se ve del mapa al máximo |
|---|---|---|---|---|---|---|
| 1 a 9 | 20 × 9 | 1,00 | 1,5 | ×1,5 | 6,0 → 9,0 | 67 % × 67 % (44 %) |
| 10 y 11 | 24 × 11 | 0,818 | 1,5 | ×1,83 | 4,9 → 9,0 | 56 % × 55 % (30 %) |
| 12 | 26 × 11 | 0,769 | 1,5 | ×1,95 | 4,6 → 9,0 | 51 % × 55 % (28 %) |
| 13 a 15 | 26 × 12 | 0,75 | 1,5 | ×2,0 | 4,5 → 9,0 | 51 % × 50 % (26 %) |

  El máximo es un número de interfaz, no de balance; si se especifica, iría como constante de interfaz (como `TILE_SIZE`) o en `data/` si Lucas lo quiere ajustable.
- **Gestos:** **pinza** = zoom alrededor del punto medio de los dos dedos; **dos dedos que se mueven juntos** = desplazar; **un dedo que se arrastra** = desplazar **solo si no hay un fantasma puesto** (con C1, un dedo que arrastra con fantasma lo corre a él, §5). El mapa no sale de sus bordes (la cámara se limita al mapa).
- **«Ver todo»** (120 × 96 px = 11,3 × 9,0 mm, abajo a la derecha, sobre el mapa): vuelve al encuadre de hoy. Muestra el aumento («×2,0»). El **doble toque para acercar no se propone**: choca con tocar una casilla para construir.
- **Mapa en miniatura** (arriba a la derecha en las maquetas): opcional, para ubicarse con zoom. Se puede dejar para después.
- **El HUD no cambia** (está en otra capa) y, por D-037, una cámara no cambia las coordenadas del mundo: alcances, disparos y la casilla bajo el dedo siguen valiendo lo mismo. Esto ya funciona hoy con la cámara de los mapas grandes (T262 lo comprobó en el nivel 15).
- **¿Y en escritorio?** La rueda del mouse podría hacer lo mismo. No hace falta (con el mouse se apunta al píxel); queda como decisión (§10, D2).

### 3.3 Precisión: cuánto ayuda el zoom (modelo, no medición)

Si el dedo cae alrededor del centro con un error normal de desvío σ en cada eje, la probabilidad de acertar una casilla cuadrada de lado *s* es erf(*s* / (2·√2·σ))². Los valores de σ (1,0 a 2,0 mm) son un **rango supuesto** para un toque con el pulgar o el índice; el error real de Lucas se mide con K4 y K11 del kit de T262.

| Casilla en pantalla | σ = 1,0 mm | σ = 1,5 mm | σ = 2,0 mm | Dónde aparece |
|---|---|---|---|---|
| 4,5 mm | 95 % | 75 % | 55 % | niveles 13 a 15, hoy |
| 4,9 mm | 97 % | 81 % | 61 % | niveles 10 y 11, hoy |
| 6,0 mm | 99 % | 91 % | 75 % | niveles 1 a 9, hoy |
| 7,6 mm | 100 % | 98 % | 89 % | el mínimo de Android (48 dp) |
| 9,0 mm | 100 % | 99 % | 95 % | **zoom máximo propuesto** |
| 10,5 mm | 100 % | 100 % | 98 % | (referencia) |

Lectura: **con σ = 1,5 mm, hoy en el nivel 15 uno de cada cuatro toques cae en otra casilla**; con el zoom máximo, uno de cada cien. El modelo no incluye el corrimiento sistemático (la gente suele tocar un poco más abajo de donde mira), que **empeora** las casillas chicas.

## 4. Dónde se elige la torre: barra, botones grandes o tienda

### 4.1 Muestras (nivel 15, 8 torres)

| Variante | Captura | Botones | Medida (celular supuesto) |
|---|---|---|---|
| **S0 · hoy** | `s0_n15_barra_hoy_20x9.png` | Barra fija, 8 botones con tecla | **7,1 × 5,6 mm** |
| **S1 · botones grandes** | `s1_n15_botones_grandes_20x9.png` | La misma barra, sin las teclas; «Próxima oleada» sale de la barra para que entren | **9,4 × 8,3 mm** (100 × 88 px) |
| **S2 · tienda cerrada** | `s2_n15_tienda_cerrada_20x9.png` | Sin barra: «Torres» y «Empezar oleada» flotando | 14,1 × 8,3 y 21,8 × 8,3 mm |
| **S2 · tienda abierta** | `s2_n15_tienda_abierta_20x9.png` | Tarjetas con dibujo, **nombre** y costo, 6 por fila; cruz para cerrar | **18,4 × 10,2 mm**; cruz 7,9 × 7,9 |
| **S2 · torre elegida** | `s2_n15_elegida_20x9.png` | La tienda se cierra sola; una pastilla dice qué se construye (tocarla la suelta) | 28,2 × 8,3 mm |
| **S3 · plegable abierta** | `s3_n15_plegable_abierta_20x9.png` | La barra de S1 con «Plegar» | 9,4 × 8,3; «Plegar» 8,7 × 7,9 |
| **S3 · plegada** | `s3_n15_plegable_cerrada_20x9.png` | Como S2 cerrada; «Torres» despliega la barra de S1 y queda abierta | 14,1 × 8,3 mm |

### 4.2 Comparación

| | S0 hoy | S1 grandes | S2 tienda | S3 plegable |
|---|---|---|---|---|
| Toques para elegir una torre | 1 | 1 | **2** (abrir + tarjeta) cada vez que se cambia de torre | 1 abierta; 2 plegada |
| Tamaño del botón | 7,1 × 5,6 mm ✗ | 9,4 × 8,3 ✓ | 18,4 × 10,2 ✓ | 9,4 × 8,3 ✓ |
| Muestra el nombre (hoy solo en el tooltip, P-07) | no | no | **sí** | no |
| Mapa que se gana al cerrar, **sin zoom** | — | — | +3 % (nivel 15), **0 %** (nivel 1) | igual que S2 |
| Mapa que se gana al cerrar, **con zoom** | — | — | **+1 fila visible** (96 px de 576) | igual que S2 |
| Con 10 torres (niveles 11 a 15 con todas las colecciones) | entran, achicados (56–57 px de ancho, `BarLayout`) | **no entran** en una fila: desplazar o dos páginas | entran (2 filas) | como S1 |
| Dónde va la pestaña «Infraestructura» | a la izquierda | a la izquierda | **dentro de la tienda** (otra pestaña) | a la izquierda |
| Durante una oleada | rápido | rápido | lento si se cambia mucho de torre; tapa la mitad del mapa mientras está abierta | rápido abierta |
| Costo de implementar | — | bajo (solo celular) | medio (pantalla nueva) | medio |

**Por qué casi no se gana mapa:** el encuadre de hoy (RF-251) toma el menor de dos límites: el ancho (1280 px) y el alto (576 px). El nivel 15 (26 × 12) ya está limitado casi por igual por los dos; sacar la barra sube el alto a 672 px pero el ancho sigue en 1280, y la casilla pasa de 48 a **49 px**. En el nivel 1 (20 × 9) no cambia nada. Ganaría de verdad si además se usara el ancho de 20:9 (`aspect = expand`, P-09 de T262: 1600 px de ancho llevarían la casilla del 15 a 56 px con la barra cerrada), que es otra tarea, cara y fuera de T264.

## 5. Comprar y colocar

### 5.1 Muestras

| Flujo | Captura | Qué se ve |
|---|---|---|
| **C0 · hoy** | `c0_n01_hoy_20x9.png` | Al apoyar el dedo ya se compró (oro 5150 → 5100). El dedo tapa la torre y la vista previa |
| **C1 · fantasma** | `c1_n01_fantasma_20x9.png` | El toque solo pone el fantasma (oro sin cambiar). **Tilde** verde con el costo (96 × 88 px = 9,0 × 8,3 mm) **arriba a la derecha**; **cruz** (84 × 84 = 7,9 mm) arriba a la izquierda, separadas 48 px (4,5 mm) |
| **C1 · ajuste** | `c1_n01_ajuste_20x9.png` | El dedo arrastra **por debajo** del fantasma y el fantasma se corre lo mismo (arrastre relativo): se ve todo el tiempo. La tilde se esconde mientras se arrastra y vuelve al soltar |
| **C1 · nivel 15 sin zoom** | `c1_n15_sin_zoom_20x9.png` | Funciona sin zoom: la casilla sigue siendo de 4,5 mm, pero **se ve antes de pagar** y se corrige |
| **C1 · 2 × 2 con zoom** | `c1_n15_2x2_zoom_20x9.png` | El Mortero: fantasma de 18 mm y la tilde con «300 + 3» arriba del cuadrado |
| **C0 · 2 × 2 hoy** | `c0_n15_2x2_hoy_20x9.png` | El cuadrado (9 mm) se centra en el dedo (RF-292): el dedo de 10 mm lo tapa entero |
| **C1 · casilla que no se construye** | `c1_n15_invalida_20x9.png` | Fantasma rojo, tilde apagada con el motivo («Ahí no»); no se cobra nada |
| **C1 · borde** | `c1_n15_borde_20x9.png` | Arriba no entra la tilde: va abajo y corrida hacia adentro, nunca encima del fantasma |
| **C2 · toque sin zoom** | `c2_n15_toque_acerca_20x9.png` | La casilla es chica: el toque **acerca ×2** alrededor del dedo y avisa «tocá de nuevo para construir»; no se cobra |
| **C2 · con zoom** | `c2_n15_deshacer_20x9.png` | El toque construyó al soltar; aviso con «Deshacer» (160 × 84 px = 15,1 × 7,9 mm) y una barra de 3 s |

### 5.2 C1 · fantasma ajustable con tilde y cruz

1. Tocar la torre en la barra (o en la tienda) → queda elegida, como hoy.
2. **Tocar una casilla** → al **soltar**, aparece el fantasma ahí (verde o rojo, con alcance). **No se cobra.**
3. **Ajustar** (si hace falta): arrastrar un dedo desde **cualquier parte** del mapa corre el fantasma lo mismo que el dedo, casilla por casilla. **Tocar otra casilla** lo lleva allá. La pinza y los dos dedos siguen haciendo zoom y desplazamiento.
4. **Tilde** → cobra y construye (RF-43: la torre sigue elegida para poner otra igual; el fantasma desaparece). **Cruz** → saca el fantasma (la torre sigue elegida). **Atrás de Android** → primero saca el fantasma; un segundo atrás suelta la torre.
5. La tilde y la cruz van **arriba** del fantasma (el pulgar viene de abajo), a 14 px del borde del fantasma o del cuadrado de 2 × 2, nunca encima de él; si no entran, abajo; siempre dentro del área del mapa y lejos de los bordes de la pantalla (los gestos del sistema de Android viven ahí).

**Variante a decidir (D6):** que **tocar el fantasma otra vez** también confirme (como la tilde). Ahorra el viaje del dedo a la tilde, pero es un toque **encima** de lo que se quiere ver y con la casilla chica sin zoom vuelve a depender de la precisión.

### 5.3 C2 · colocación automática protegida

1. Tocar la torre → elegida.
2. Tocar una casilla:
   - si la casilla **en pantalla** mide **al menos 7,6 mm** (con el zoom suficiente): **construye al soltar** y muestra «Deshacer» 3 s, que devuelve **todo** el oro y los recursos (no el 70 % de vender);
   - si mide menos (**cualquier nivel sin zoom**: 4,5 a 6,0 mm): **no compra**; acerca el mapa al máximo alrededor del dedo y avisa. El siguiente toque, ya con la casilla grande, construye.
3. Cualquier otro gesto (arrastre, pinza, dos dedos) es solo zoom o desplazamiento.

**Su problema:** el mismo toque hace cosas distintas según el zoom. Sin zoom, **todos** los niveles caen en «acerca» (ni el 1 llega a 7,6 mm), así que en la práctica C2 es «hacer zoom y después tocar», con un «Deshacer» que hay que especificar (cuánto dura, qué pasa si en esos 3 s la torre ya disparó, si sirve después de una mejora). Y el umbral de 7,6 mm depende del celular: hay que calcular los milímetros reales con el tamaño de la pantalla, que Godot no siempre informa bien (`DisplayServer.screen_get_dpi()`, a verificar en el celular).

## 6. Reglas de gestos (comunes a C1 y C2): cómo no comprar por accidente

Estas reglas son el núcleo de B-35 y **valen para cualquier variante**. El modelo del §7 las implementa (`TouchBuildModel` en la herramienta).

| # | Regla | Evita |
|---|---|---|
| G1 | **Nada se compra ni se elige al apoyar el dedo**: se decide **al soltar** (hoy se compra al apoyar, `build_controller.gd:315-317`) | Compra al empezar una pinza o un arrastre (T262, B y C) |
| G2 | Si en algún momento del gesto hubo **dos dedos o más**, el gesto es zoom o desplazamiento: **no compra, no elige, no pone fantasma**, aunque un dedo se levante antes que el otro | Compra con el «dedo rezagado» al terminar la pinza |
| G3 | Un dedo que se movió **más de 2 mm** (≈ 21 px virtuales en el celular supuesto; Android usa 8 dp ≈ 1,3 mm para empezar un arrastre) **no es un toque**: desplaza el mapa o corre el fantasma | Compra al querer mover el mapa |
| G4 | Un temblor **menor** a 2 mm sigue siendo un toque | Que un toque normal se pierda |
| G5 | Durante unos **150 ms después de una pinza**, se ignoran los toques nuevos de un dedo (valor a ajustar en el celular) | El dedo que queda apoyado al terminar el zoom |
| G6 | Un toque que **empieza sobre el HUD** (barra, botones, tilde) nunca llega al mapa, y uno que empieza en el mapa nunca pulsa el HUD al soltar | Comprar o elegir al rozar un botón |
| G7 | La casilla sale de la **posición del toque** pasada por la cámara, no del mouse emulado (P-12) | Construir donde estaba el cursor (T262, A0) |
| G8 | El juego tiene que leer los toques de verdad (`InputEventScreenTouch` / `ScreenDrag`) y **dejar de actuar con los clics emulados** en el mapa (`emulate_mouse_from_touch` sigue sirviendo para los botones) | Que el mismo toque se procese dos veces |

## 7. Medición: pasos y toques, hoy y propuesto

**Cómo se midió.** El modelo `TouchBuildModel` (en `tools/t264_touch_mockups.gd`) recibe la secuencia de toques de cada caso (apoyar, mover, soltar, con uno o dos dedos) y aplica las reglas de cada flujo: **C0** = hoy (compra al apoyar el primer dedo, como midió T262), **C1** y **C2** = §5 con las reglas del §6. «Persona» = lo que haría quien juega **viendo la pantalla**: si el fantasma quedó al lado lo corre antes de la tilde (C1), si compró mal vende (C0) o deshace (C2). Los toques cuentan **cada dedo que se apoya** (el botón de la torre incluido; una pinza son 2). Salida completa: `art/t264-zoom-compra/salida_20x9.txt` (líneas `T264 MODELO`).

| Caso (nivel 15, casilla 4,5 mm, sin zoom al empezar) | C0 · hoy | C1 · tilde | C2 · protegida |
|---|---|---|---|
| Una torre, toque justo | **2** | 3 | 3 (acerca + toque) |
| Una torre, el dedo cae **2,7 mm** al costado (0,6 casilla) | **7** y pierde el 30 % (compra al lado, suelta, toca la torre, vende, elige, toca) | **4** (arrastre de una casilla + tilde), sin pérdida | **3** (con zoom, el mismo error en mm es 0,3 casilla: acierta) |
| Una torre, temblor de 1 mm | 2 | 3 | 3 |
| **Arrastrar 2 casillas** para mover el mapa, con torre elegida | **compra 1 por error** | 0 compras | 0 compras |
| **Pinza** para hacer zoom, con torre elegida | **compra 1 por error** | 0 | 0 |
| Pinza con un dedo que se levanta después | **compra 1 por error** | 0 | 0 |
| **Cinco torres iguales en fila** (rapidez en oleada) | **6** | 11 | 7 (6 si ya había zoom) |
| Toque en una casilla que no se puede construir | 2, no pasa nada (sin aviso hasta después) | 3: fantasma rojo con motivo y cruz | 2: acerca y no construye |
| **Compras por error en los 8 casos** | **3** | **0** | **0** |

En el **nivel 1** (casilla de 6,0 mm) los números son los mismos salvo que el error de 2,7 mm no alcanza a cambiar de casilla (0,45 casilla), así que C0 acierta en ese caso; C2 igual acerca primero porque 6,0 mm < 7,6 mm.

**Elegir la torre** suma, según la variante del §4: S0, S1 y S3 abierta, **+0**; S2 y S3 plegada, **+1** cada vez que se cambia de tipo de torre (para «cinco iguales», +1 en total).

**Qué no dice esta tabla:** cuánto **tarda** cada toque. La tilde está a 1 o 2 casillas del fantasma (viaje corto), mientras que hoy un error se paga con un viaje a la barra y al panel. Los tiempos reales se miden en el celular (§11).

## 8. Torres de 1 × 1 y de 2 × 2

- **Hoy** el 2 × 2 se centra en el dedo (RF-292): el cuadrado de 9 mm queda **entero debajo** de la yema de 10 mm (`c0_n15_2x2_hoy`), y se compra al apoyar.
- **C1:** el cuadrado aparece al soltar, con sus 4 casillas verdes o rojas (RF-292 no cambia); la tilde va arriba del **cuadrado**, no de una casilla; el arrastre relativo lo corre de a una casilla; si una de las cuatro queda fuera del mapa, se propone correr el fantasma hacia adentro (hoy `origin_for` no lo hace: la vista previa queda roja). Con zoom, el cuadrado mide 18 mm (`c1_n15_2x2_zoom`).
- **C2:** el umbral se mide con la **casilla**, no con el cuadrado (un 2 × 2 de 9 mm sin zoom tiene casillas de 4,5 mm: igual acerca primero). El «Deshacer» devuelve también los recursos (el Mortero cuesta «300 + 3»).
- **Caso de error propio del 2 × 2:** tres casillas libres y una ocupada o de camino → fantasma rojo entero; la tilde apagada dice cuál falla.

## 9. Oclusión del dedo

- La yema apoyada mide unos 10 mm y el pulgar tapa además una franja hacia abajo y a la derecha (en las maquetas, la mancha clara). **Hoy, en el nivel 15, eso tapa unas 2 × 2 casillas y toda la vista previa**, justo cuando se compra.
- **C1 no necesita ver debajo del dedo:** el fantasma aparece **después** de soltar; para ajustar, el dedo arrastra **lejos** del fantasma (arrastre relativo), y la tilde y la cruz van **arriba**, del lado contrario al pulgar.
- **C2** depende del zoom: con la casilla de 9 mm, el dedo tapa una casilla y la torre se ve al soltar; el «Deshacer» está abajo, lejos de la casilla.
- **Una lupa** (círculo ampliado arriba del dedo, como al elegir texto) **no se propone**: con el zoom y el fantasma no hace falta, y agrega otra cosa que aprender.
- **Pulgar izquierdo o celular girado al revés:** la tilde «arriba» sigue sirviendo (el pulgar viene de abajo de cualquier lado). Con el celular girado, Android da vuelta la pantalla y el juego se ve igual (`window/handheld/orientation = 4`, horizontal en los dos sentidos).

## 10. Decisiones que tiene que tomar Lucas (G7)

| # | Pregunta | Opciones | Recomendación de esta tarea |
|---|---|---|---|
| **D1** | ¿Zoom con pinza en el celular? | Sí (Z1) / no | **Sí**, del encuadre de hoy a casilla de 96 px, con «Ver todo» |
| **D2** | ¿Zoom también en escritorio (rueda del mouse)? | Solo celular / los dos | Solo celular primero; en escritorio no hace falta para apuntar |
| **D3** | ¿Cómo se coloca? | **C1** tilde y cruz / **C2** automática protegida / C1 ahora y C2 como atajo después | **C1**, y decidir C2 después de probar C1 en el celular |
| **D4** | ¿Se puede poner el fantasma y confirmar **en pausa**? Hoy no se construye en pausa (RF-104), en ningún lado | No (como hoy) / fantasma sí, tilde no / las dos | **Fantasma sí, tilde no**: se planea en pausa sin cambiar el balance; se confirma al seguir. Cambiaría RF-104 |
| **D5** | ¿Dónde se eligen las torres? | S1 / S2 tienda / S3 plegable / dejar la barra | **S3** (rápida abierta; S2 solo si se quiere que la tienda muestre nombres) |
| **D6** | ¿Tocar el fantasma otra vez también confirma? | Sí / no (solo la tilde) | No al principio; probarlo en el celular |
| **D7** | Un dedo que arrastra, con fantasma puesto: ¿corre el fantasma o mueve el mapa? | Fantasma (relativo, el de las maquetas) / fantasma solo si el arrastre empieza encima / siempre el mapa (el fantasma solo con toques) | **Fantasma relativo**; el mapa, con dos dedos |
| **D8** | Con torre elegida, ¿tocar una torre ya construida abre su panel? Hoy no hace nada | Sí (suelta la elección) / no | Sí: es el camino de corrección más corto. Coordinar con T263, que diseña ese panel |
| **D9** | ¿Las reglas valen también con mouse en escritorio? | Solo táctil / los dos | **Solo táctil**: en escritorio la vista previa ya sigue al mouse antes de comprar y no hay problema que arreglar |
| **D10** | En C2: ¿cuánto dura «Deshacer» y devuelve todo? | 3 s y 100 % / otra cosa | Solo si se elige C2 |

## 11. Qué no se pudo probar sin un celular

- **El dedo de verdad:** su tamaño (se supuso 10 mm), el temblor, el error real al apuntar (el §3.3 es un modelo con σ supuesto) y cómo tapa la pantalla con el pulgar y con el índice.
- **Los gestos de verdad:** cómo entrega Android la pinza y el arrastre (el gestor de gestos del sistema, los bordes que abren la barra o el «atrás» por gesto, la multitáctil real) y si los umbrales de 2 mm y 150 ms (G3 y G5) se sienten bien. **Nada de las reglas del §6 corrió en el juego**: el modelo las aplica sobre toques escritos a mano.
- **La rapidez:** no se midió el tiempo de ningún flujo, solo la cantidad de toques. No se jugó una oleada con ninguna variante.
- **Si se entiende sin explicación:** el fantasma con tilde, el toque de C2 que acerca en vez de comprar y la tienda plegable no se probaron con nadie.
- **El zoom en el celular:** fluidez, rendimiento con la cámara moviéndose (no se midió ni en escritorio) y si 9,0 mm alcanza.
- **El tamaño real de la pantalla de Lucas:** todos los mm son del celular supuesto (1080 × 2400, 6,5"). Con otro, la herramienta los recalcula (`target=` y `ppi=`).
- **El 16:9 chico** solo está en la columna de medidas (alto en mm), no en capturas.
- **La herramienta deja un aviso al salir** («2 ObjectDB instances were leaked», la música del autoload `Audio` al cerrar con `quit()`); no afecta las capturas ni el juego.

**Pruebas para agregar al kit de T262 cuando haya un prototipo jugable** (no antes): pellizcar y arrastrar con torre elegida 10 veces (compras por error de 10); colocar 10 torres en el nivel 15 sin zoom y con zoom (aciertos de 10 y tiempo); cinco torres seguidas durante una oleada (tiempo); corregir una torre mal puesta (toques y tiempo).

## 12. Si se aprueba: tareas chicas para la spec M58 (orden sugerido)

1. **Toques de verdad y comprar al soltar** (G1, G6, G7, G8): leer `InputEventScreenTouch` en el mapa, la casilla desde el toque. Sin zoom ni fantasma todavía; ya saca las compras por arrastre. Bajo–medio.
2. **Clasificador de gestos en `scripts/logic/`** (G2 a G5), probado con GUT como el modelo de la herramienta (P10). Bajo.
3. **Zoom y desplazamiento** (Z1): cámara con límites, pinza, dos dedos, «Ver todo». Alto.
4. **Fantasma con tilde y cruz** (C1): estado nuevo en `BuildController`, ubicación de la tilde, atrás de Android, 2 × 2. Medio.
5. **Barra grande plegable** (S3), solo en el celular. Medio.
6. Lo que se decida de D4, D6 y D8.

Cada una pasa por la spec (RF nuevos, RF-43, RF-104 y RF-143 cambian) y su decisión antes de programarse (P3). T263 diseña el panel de una torre ya construida: si D8 dice «sí», se coordina con su propuesta.

## 13. Cómo repetir

```bash
# Capturas, hojas de comparación, medidas y el modelo de gestos (no toca el guardado del jugador)
XDG_DATA_HOME=/tmp/xdg godot --path . --resolution 1600x720 res://tools/t264_touch_mockups.tscn -- res=1600x720 tag=20x9
# Solo una parte: only=zoom,shop,place,model ; otro celular: target=WxH ppi=N
```

La salida de esta corrida está en `art/t264-zoom-compra/salida_20x9.txt`.
