# T545 · Revisión de textos del lore

Carpeta de trabajo de T545 (documentos y arte; no toca `data/`, `scripts/`, `scenes/` ni `tests/`).

| Archivo | Qué es |
|---|---|
| `revision.html` | Informe de lectura con capturas reales (37 piezas, 16 hallazgos). Informe en texto: `specs/tareas/informes/T545-revision-textos-e-imagenes.md`. |
| `opciones.html` | **Documento de opciones de redacción** para la revisión manual de Lucas (2026-10-28). Una tarjeta por texto: actual, 0 a 3 alternativas, cuadro «Mi redacción» con contador contra el límite, nota, filtros, guardado en el navegador y «Copiar mis decisiones». Autocontenida; solo usa Google Fonts opcional. |
| `opciones.json` | Los mismos datos, ordenados por id estable (`nivel_02.entrada`, `lore.la_central`, `intro.lamina_4`, `epilogo`, `creditos`…): fuente, texto actual tal cual, límites, hallazgos y opciones con qué problema resuelve cada una. |
| `capture_t545.gd`, `capture_t545.tscn`, `captures/` | Capturas de PC a 1280×720 con el motor. |

**Nada de esto está cargado en el juego.** Lucas elige o escribe, y una tarea posterior copia lo decidido a `specs/11-textos-lore.md` (y `specs/intro/guion.md`) y recién después a `data/`.

## Cómo se usa `opciones.html`

1. Abrir el archivo en el navegador (PC o celular). «Dejar actual» está marcado en todas.
2. Elegir una opción o escribir en «Mi redacción» (si hay texto ahí, prevalece sobre la opción). El contador pasa a rojo si se pasa del límite del juego.
3. «Copiar mis decisiones» arma un texto compacto con el id, la opción o el texto propio y la nota; se pega en el chat. «Descargar JSON» baja lo mismo como archivo.
4. Lo que se escribe queda guardado en ese navegador (localStorage); «Borrar todo» lo limpia.

El epílogo (la frase de Lucas en 3 líneas) **no tiene opciones**: las alternativas están en lo que lo rodea (`nivel_15.victoria`, `nivel_15.entrada`, `lore.la_central`).

## Validación

`python3 tools/t545_validar_opciones.py` (desde la raíz del proyecto) comprueba que el JSON esté bien formado, que los ids no se repitan, que el «texto actual» coincida con `data/`, que cada opción cumpla líneas y caracteres de su campo (RF-464), que no use el vocabulario vetado y que no haya más de 3 opciones ni repetidas.

Resultado (2026-10-28):

```
Entradas: 82 · con opciones: 49 · opciones: 119
Errores: 0 · Advertencias: 4
  AVISO  nivel_01.entrada: tiene hallazgo de prioridad Alta/Media y solo 0 opciones
  AVISO  nivel_03.nombre: tiene hallazgo de prioridad Alta/Media y solo 1 opciones
  AVISO  nivel_04.entrada: tiene hallazgo de prioridad Alta/Media y solo 2 opciones
  AVISO  nivel_14.victoria: tiene hallazgo de prioridad Alta/Media y solo 2 opciones
RESULTADO: OK
```

Las 4 advertencias son a propósito: en esas piezas el hallazgo de prioridad alta o media es de *otra* pieza (el 1 y el 4 dependen de lo que se decida en el nivel 2; la victoria del 14 queda bien con cualquier entrada) y su propio problema es menor.

Límites de nombre (24 caracteres, una línea) y de Wiki (sin límite duro) son orientativos: el juego no los exige.

## Cobertura

82 entradas: 15 niveles × 4 campos (nombre, lugar, entrada, victoria), selector, epílogo, imagen del epílogo, créditos, 7 láminas de intro y 11 artículos de Wiki Lore. Los niveles no tienen un campo «descripción» aparte: la tarjeta del selector muestra nombre y lugar. No se cubren los textos mecánicos (Wiki de juego, tutorial, consejos, bestiario), que no son de tono lore.
