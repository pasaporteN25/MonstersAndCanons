# T267 · Comparación antes y después (niveles 1, 14 y 15)

Sirve para que Lucas valide **visualmente** el arte integrado de T267b/T277 (más T508, T524 y T542) sin jugar una partida. No cambia nada del juego.

## Abrir

`revision.html` en cualquier navegador (PC o celular). Funciona sin conexión: las imágenes están en esta carpeta. Cada nivel tiene un control deslizante antes/después, ampliaciones por pieza, qué cambió, qué sigue viejo y un espacio de decisión.

## Qué se compara

- **Antes:** commit `377fd65`, el último anterior a la integración del arte renderizado (T277, `c30c91c`).
- **Después:** `origin/main` (`adc88d7`), que suma T508 (rocas), T524 (adornos M79), T542 (flora) y T544.
- Mismo script en los dos: `capture.gd` + `capture.tscn`, 1280×720, estados reales del campo de infraestructura (mina/bosque habilitados, escombro en trabajo, reservas agotadas). No son partidas jugadas.
- Nivel 1: una sola captura, porque no tiene mina, bosque ni escombro y los otros estados salían idénticos. Niveles 14 y 15: tres estados que sí difieren.
- Las ampliaciones se generan con `make_crops.py`. Se omitió el escombro despejado del 14 (se ve igual) y el abastecimiento del 15 se muestra una sola vez (sigue siendo el de T233).

## Reproducir

```bash
# en cada checkout (antes y después), tras `godot --headless --import`
godot --path . --resolution 1280x720 res://art/t267-comparacion/capture.tscn -- out=/ruta/salida/
python3 -I art/t267-comparacion/make_crops.py /ruta/antes /ruta/despues
```

Necesita ventana real (no `--headless`).

## Límites

Imágenes fijas: sin animaciones ni capturas en celular real. No se corrieron tests de GUT (solo documentos y arte de revisión). La aprobación de T267 sigue siendo de Lucas.
