# T484 · Alternativas para el tramo sur de T483

Dos propuestas localizadas para decidir el recorrido 5–9 después de que Lucas aceptó T483 como dirección y pidió ajustar «la parte de abajo». Se interpreta como el rodeo sur; **la costa permanece idéntica**. Si se refería a la silueta sur o a otro elemento, eso todavía no se alteró.

La recomendación visual independiente es **B**, porque reduce el rodeo sin aplanar el centro tanto como A. La elección es de Lucas: ninguna variante queda aprobada por esta recomendación. Son muestras estáticas, sin integración de arte final.

## Fuentes y reproducción

- `option_a/route.svg` y `route_points.json`: alternativa A, menos profunda; el punto 7 pasa de y=427 a y=366.
- `option_b/route.svg` y `route_points.json`: alternativa B, con tramos desiguales y centro más tendido; el punto 7 queda en y=389.
- `render_preview.py`: deriva ambas fuentes de T483, reutiliza su compositor y produce las capturas con Godot 4.7.2 aislado y Pillow.
- `index.html`: comparador entre la actual T483 y A/B; imágenes relativas en `../../Capturas/`.
- `Capturas/T484-alternativa-A.png` y `T484-alternativa-B.png`: composiciones estáticas 1280×720.
- `Capturas/T484-comparacion-tramo-sur.png`: lámina vertical 1280×1650 con la versión actual, A y B.

Ejecutar desde la raíz del worktree:

```bash
python3 art/t484-tramo-sur/render_preview.py
```

El script no importa ni abre el proyecto del juego. Necesita los archivos T483 que están en el commit anterior del mismo PR #79, Godot, Pillow y las fuentes DejaVu Sans de la máquina. La geografía base es `assets/ui/campaign_map_background.svg` de T428; la composición de referencia es `Capturas/T483-propuesta-recorrido.png` del commit `6949d19`.

El tramo central se dibuja separado y el recorrido original se recorta fuera de ese tramo. Así se conserva incluso la fase de los guiones originales en 1–4 y 10–15, que de otro modo cambiaría al variar la longitud central. Las coordenadas de aterrizaje, 1–4 y 10–15 y los siete bloques del fondo permanecen idénticos.

## Verificación y límites

El [informe T484](../../specs/tareas/T484-alternativas-tramo-sur.md) registra análisis previo y crítica independiente. Se revisaron visualmente A/B; se verificó por XML que el fondo y los elementos externos no cambian, 1.500 puntos de cada ruta sobre tierra con X creciente, discos visibles dentro de costa y diferencias de píxeles limitadas al centro. Los círculos visibles no se solapan; las áreas táctiles de 56 px no se validan con esta composición.

Impeccable 4.5.2 se aplicó al refinamiento y se ejecutó una vez su detector del HTML: ocho avisos de contraste por asumir blanco en elementos que heredan el fondo oscuro. Los colores sobre #181d20 conservan contraste superior a 9,9:1. No se presenta como detector limpio. CUA no tiene navegador disponible en esta sesión; se comprobaron enlaces locales y se inspeccionaron los PNG, pero **no el HTML interactivo en navegador**.

No se corrieron juego, GUT, importación, bots, teléfono ni mediciones de rendimiento. No se cambian reglas, biomas, canon, datos ni recursos runtime. T469/T471 continúan con la compuerta de aprobación de Lucas.

## Peso y huellas de las capturas

| Archivo | Peso | SHA-256 |
|---|---:|---|
| `T484-alternativa-A.png` | 232,990 bytes | `4ec8d1d535e5cb0b7ef76be8b6df73f6b1736d8dd248b11c1a0f2da679fb51da` |
| `T484-alternativa-B.png` | 233,287 bytes | `373d6f521a46fdbd03bbb7d2826be020bb8f7685bf8c12ee2676771397c93c56` |
| `T484-comparacion-tramo-sur.png` | 639,983 bytes | `4e9a78dd9cb7264a780d47027b7add4d8accad53758a6692a2622aa1dd1012f0` |
