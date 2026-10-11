# T241 · Láminas de la intro

Producción del 2026-10-11 según `specs/intro/guion.md`, aprobado por Lucas ese día, en el estilo **A · Cuaderno de bitácora**. No se produjo la versión B. Las siete láminas están **listas para revisión**, pero la aprobación visual final de Lucas todavía está pendiente.

## Abrir la revisión

Abrir **`comparison.html`** en un navegador, directamente desde el disco. No necesita servidor ni internet: todas las imágenes se enlazan con rutas relativas. Incluye las siete imágenes completas, sus pesos, la hoja de miniaturas y los recortes de continuidad de la nave, la ingeniera y el herrero. El botón «Mostrar zona de texto» superpone una guía del tramo y = 842 a 1080; esa guía no está dentro de los PNG.

- `contact_sheet.png`: las siete juntas, para comparar el arco de color y la composición.
- `continuity_sheet.png`: recortes de los finales para comparar la nave (1, 5, 7), la ingeniera (2, 3, 4, 6) y el herrero (2, 4, 7). El herrero de la panorámica se amplía desde una figura diminuta: su detalle es menor que en los interiores.
- `manifest.json`: nombres definitivos, tamaños, pesos exactos y SHA-256.
- `prompts.md`: instrucciones comunes, escenas, referencias y corrección realizada.
- `sources/`: originales generados sin modificar, incluida la primera salida de la ventana, que no se entrega como final.
- `pack.py`: normalización y armado reproducible de la revisión; requiere Python 3 y Pillow.
- `.gdignore`: excluye las fuentes y la revisión de la importación de Godot; el juego consume solo `assets/intro/`.

## Reproducción

Desde la raíz del proyecto:

```bash
python3 art/intro-v1/pack.py
```

La herramienta integrada `image_gen` devolvió originales de **1672 × 941**. El empaquetador los lleva a **1920 × 1080**, completos, con remuestreo Lanczos y sin recortar el cuadro; la variación de proporción es menor al 0,1 %. Guarda RGB PNG optimizados sin pérdida. No se retocaron personajes, color, fondo ni composición mediante código.

## Peso de los finales

| Archivo | Bytes | MiB |
|---|---:|---:|
| `01_la_nave.png` | 2.771.004 | 2,64 |
| `02_la_bodega.png` | 3.701.846 | 3,53 |
| `03_los_turnos.png` | 3.513.701 | 3,35 |
| `04_la_ventana.png` | 3.422.857 | 3,26 |
| `05_el_descenso.png` | 3.279.054 | 3,13 |
| `06_los_motores_apagados.png` | 3.715.778 | 3,54 |
| `07_el_oasis.png` | 3.950.523 | 3,77 |
| **Total** | **24.354.763** | **23,23** |

Estos son los pesos de los PNG, no el incremento de la APK ni la memoria de las texturas. T242 mide el paquete exportado después de integrar la intro.

## Revisión visual realizada

Se revisaron los originales completos y las hojas de contacto. La nave conserva casco largo remachado, proa redonda, tres cúpulas, dos toberas y antena con trapo. La ingeniera conserva gorra con anteojos, pelo recogido y mono azul; el herrero conserva barba gris y delantal. En el oasis las cinco figuras son deliberadamente diminutas. Las marcas del calendario son rayas paralelas; el mapa usa círculo y punto de grafito. En la sala de máquinas se ven palanca, cuña de madera, cadena y candado cerrado, con manómetros al mínimo.

No se encontró el símbolo A ni marcas que se le parezcan en la inspección visual; tampoco animales, Moradores, ruinas, letras incorporadas ni fuegos o humo en el horizonte. El vapor de la sala de máquinas y el fuego del descenso son los pedidos por el guion. La ventana se corrigió con `image_gen` porque la primera salida tenía un segundo punto verde en el mapa; el final conserva verde únicamente sobre el planeta.

El cuarto inferior queda oscuro y sin elementos narrativos importantes. El papel crema sigue visible en los bordes; la franja real del juego debe asegurar el contraste del texto allí. Esa legibilidad en pantalla y celular se verifica en T242.

## Límites

La revisión visual final de Lucas está pendiente. No se integró la intro, no se hicieron capturas en partida ni se exportó una APK: corresponde a T242. No había navegador disponible en la herramienta de UI de este despacho, por lo que se verificaron todas las rutas del HTML y se inspeccionaron las hojas PNG, pero no se comprobó el renderizado ni el botón en un navegador. El informe de verificación técnica está en `REPORTE.md`.
