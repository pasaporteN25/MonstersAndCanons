# T485 · Atlas, biomas y cartografía por zonas

Nueva muestra sobre la dirección B elegida por Lucas. Revisa la silueta y el terreno del atlas y permite evaluar tres estados de descubrimiento. **Concepto para aprobar; no arte final ni función integrada.**

## Fuentes y procedencia

Base del trabajo: `origin/main` `cb748459`, con los commits de muestra T483 `6949d19` y T484 `779d82e` en la misma rama. La ruta y sus coordenadas se conservan exactamente desde `art/t484-tramo-sur/option_b/`. La paleta, el mar, la escala cartográfica y los símbolos parten de T428; la costa, el relieve, los ríos y las transiciones nuevas son concepto visual, sin fijar geografía canónica.

La auditoría independiente comunicada por el orquestador se contrastó con `data/levels/level_01.json` a `level_15.json`. `level_themes.json` registra número, nombre y tema reales. La secuencia es:

- 1–5: pradera.
- 6–7: bosque.
- 8–9: ruinas.
- 10–12: desierto; el 10 mantiene restos como transición.
- 13: nieve.
- 14: ruinas.
- 15: pradera.

No se usan volcán o pantano y no se modifica ningún JSON de nivel. La nueva colocación de montes, cauces y costas es arte conceptual sujeto a aprobación.

## Archivos

- `render_preview.py`: fuente editable y reproducible del atlas; dibuja SVG, rasteriza en Godot aislado y compone la maqueta con Pillow.
- `inicio/route.svg`, `nivel-6/route.svg` y `nivel-11/route.svg`: fuentes SVG de los tres estados. Comparten costa, terreno y ruta; cambian máscara cartográfica y marcadores de progreso ilustrativos.
- `route_points.json`: copia de las coordenadas B aceptadas.
- `level_themes.json`: trazabilidad de biomas contra los datos reales.
- `index.html`: visor comparativo y tabla de los quince niveles; utiliza las imágenes relativas en `../../Capturas/`.
- `Capturas/T485-atlas-inicio.png`, `T485-atlas-nivel-6.png`, `T485-atlas-nivel-11.png`: composiciones estáticas 1280×720.

Los estados propuestos son: primer bloque con cartografía 1–5; al desbloquear 6 se ve 1–10; al desbloquear 11 se ve 1–15. Revelar terreno no abre todos los niveles: los posteriores al disponible conservan candado y las estrellas siguen separadas. Las situaciones de progreso son maquetas, no guardados reales.

## Reproducción

Desde la raíz del worktree, con Godot 4.7.2, Pillow y DejaVu Sans disponibles:

```bash
python3 art/t485-atlas-biomas/render_preview.py
```

El comando no abre/importa el proyecto jugable. Las fuentes usan degradados y máscaras SVG, sin filtros de desenfoque. Los lavados de terreno evitan bordes de parches; el descubrimiento utiliza máscaras serpenteantes suavizadas. La revisión observó franjas paralelas leves alrededor del límite, consideradas no bloqueantes para esta muestra.

## Revisión y límites

GPT‑6.1‑sol con esfuerzo alto e Impeccable 4.5.2. La crítica independiente pidió y verificó transiciones graduales, nieve interior del 13, ruinas distintas en 14, valle verde 15, frontera de descubrimiento orgánica y candados legibles. La revisión final la consideró lista para la decisión de Lucas.

Controles de fuente: ruta B idéntica, 1.201 puntos de ruta sobre tierra con X creciente, discos visibles completos dentro de la costa, máscaras que contienen exactamente los centros 1–5 y 1–10, candados individuales coherentes y temas 15/15 iguales a JSON. `git diff --check` limpio.

Impeccable detect se ejecutó una vez sobre el HTML: seis avisos por asumir fondo blanco en elementos que heredan el fondo oscuro #181d20. Los contrastes CSS declarados superan 9,9:1; no se informa detector limpio. Los enlaces locales del HTML se comprobaron. CUA no tiene navegadores disponibles: el visor interactivo no se verificó en navegador; sí los PNG.

No se corrieron juego, importación, GUT, bots, teléfono ni mediciones de rendimiento. La propuesta de descubrimiento requiere aprobación y futura especificación de guardados anteriores, modo de pruebas y separación entre cartografía, acceso y conquista antes de escribir código. No se redactan RF/D finales en una muestra de arte. T469/T471 continúan con sus compuertas. El PR #78 queda supersedido por #79 tras publicar esta actualización, por instrucción de Lucas.

## Peso y huellas de las capturas

| Archivo | Peso | SHA-256 |
|---|---:|---|
| `T485-atlas-inicio.png` | 189,359 bytes | `6f0f34a1cc756513fc34c8ff9a628e1d15b45bf5e8e768b12ec0e9a4ba4eee78` |
| `T485-atlas-nivel-11.png` | 214,548 bytes | `31c4e6861a380a373a795b81e8ce9dea6df4ca7623a78a3e8ab9f0fef9229659` |
| `T485-atlas-nivel-6.png` | 211,108 bytes | `95cc3bc8b28ad4ff7970f25a0d36b52517fe834e1071a813f86e581e048cd004` |
