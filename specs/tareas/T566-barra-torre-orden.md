# T566 · Barra de la torre: × a la izquierda y «Vender» lejos de «Empezar oleada»

- Ejecutor · Sonnet · esfuerzo medio
- Depende de · nada · Compuerta · ninguna · Tamaño · Chico a mediano

## Leer

`specs/01-spec.md`: RF-736, RF-512, RF-513, RF-722. `specs/04-decisiones.md`: D-226 y D-214. El Resultado de `specs/tareas/T514-barra-torre-celular-b.md`.

## Objetivo

Que cerrar quede pegado a la izquierda y que un toque de más en «Empezar oleada» no pueda caer en «Vender».

## Alcance

**Sí:** `_build_status_bar` en `scenes/game/mobile_hud.gd:127` (orden de los hijos y lo que dependa de él), `tests/test_mobile_tower_bar.gd` y los `test_mobile_*` que fijen el orden, y `CHANGELOG.md`.

**No:** tamaños, los dos toques de «Vender» y «Mejorar», sus textos, ni los estados «vacía» y «con fantasma» en lo que no sea la posición de la ×. Los rieles son T570.

## Pasos

1. Pasar el orden del estado «torre» a: ×, texto, «Vender», separación, «Apuntar», «Mejorar». Los anchos de hoy suman 1263 de 1264 px, así que entra sin achicar nada.
2. Revisar `_fit_status_font`, que mide la columna de texto, y que el tilde y la cruz del estado «con fantasma» sigan bien.
3. Dejar la lógica lista para que T570 saque «Vender» de la barra: un solo lugar donde se decide su padre o visibilidad. No agregar rieles todavía.
4. Tests: la × empieza en el margen izquierdo; orden de los hijos; el rectángulo de «Vender» no se cruza con el de `StartWaveButton` (nodo real, en coordenadas de pantalla); la separación mínima de RF-512 entre «Vender» y «Mejorar»; ningún hijo fuera de la barra en las 11 torres × 3 niveles; Estandarte y Disruptora, sin «Apuntar».
5. Capturas del celular simulado a 1280 × 720, antes y después.

## Hecho cuando

El orden es el de RF-736. Hay un test de no cruce con «Empezar oleada» y otro de separación. Los dos toques, el bloqueo de 0,35 s y los tamaños mínimos no cambian. Hay capturas.

## Verificación

Suite completa sin `SCRIPT ERROR`. **No se puede probar acá:** el pulgar en un teléfono ni los 35 mm reales.

## Frenar si

Mover la × rompe el orden táctil de `_handle_status_touch`, o no entra sin bajar de RF-550.
