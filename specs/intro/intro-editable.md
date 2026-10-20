# Intro del juego: textos y tiempos

Este documento es una **vista editable** de `data/intro/intro.json`. El juego lee ese JSON, no este archivo.

**Cómo se usa** (más detalle en `CONTENIDO.md`):

1. Cambiá lo que quieras: el texto de cada lámina, los segundos, el fundido o la imagen.
2. Para ver si quedó bien sin guardar nada: `godot --headless --path . -s tools/intro_doc.gd -- import --dry`.
3. Para pasarlo al juego: `godot --headless --path . -s tools/intro_doc.gd -- import`. Si hay un error, lo dice con el número de línea y **no cambia nada**.
4. Para volver a empezar desde lo que carga el juego: `... -- export` (conserva las notas).

**Reglas** (las mismas que revisa el juego): de 5 a 8 láminas; el texto, de 1 o 2 líneas, hasta 90 caracteres por línea y 160 en total; los segundos, un número entero de 4 a 12; el fundido, de 0 a 2 segundos; la imagen, un archivo que exista (`res://assets/intro/...`).
Cada línea del texto empieza con `> `. Las **notas** son solo para vos: no se cargan al juego. La intro no tiene voces ni sonidos propios, así que «Voz o sonido» queda en «ninguno».

## Ajustes generales

- Versión del formato: 1
- Fundido entre láminas (segundos): 0.6

## Lámina 1 · La nave

- Imagen: res://assets/intro/01_la_nave.png
- Segundos: 7
- Voz o sonido: ninguno

Texto:

> La Compañía Meridiana mandó una sola nave.
> No lleva soldados: lleva gente de oficio.

Notas:

## Lámina 2 · La bodega

- Imagen: res://assets/intro/02_la_bodega.png
- Segundos: 9
- Voz o sonido: ninguno

Texto:

> Herreros, carpinteros, ingenieros, agricultores: cada uno trajo su oficio.
> Hay semillas, planos y piezas para empezar de cero.

Notas:

## Lámina 3 · Los turnos

- Imagen: res://assets/intro/03_los_turnos.png
- Segundos: 8
- Voz o sonido: ninguno

Texto:

> Fueron años de viaje. Se durmió por turnos y lo que se rompía se arreglaba a bordo.
> Era un viaje de ida.

Notas:

## Lámina 4 · La ventana

- Imagen: res://assets/intro/04_la_ventana.png
- Segundos: 7
- Voz o sonido: ninguno

Texto:

> El reconocimiento vio agua en un solo lugar de todo el planeta.
> Hacia ahí apuntó la nave.

Notas:

## Lámina 5 · El descenso

- Imagen: res://assets/intro/05_el_descenso.png
- Segundos: 5
- Voz o sonido: ninguno

Texto:

> La bajada fue brusca. El casco crujió entero, pero aguantó.

Notas:

## Lámina 6 · Los motores apagados

- Imagen: res://assets/intro/06_los_motores_apagados.png
- Segundos: 6
- Voz o sonido: ninguno

Texto:

> Los motores se apagaron al tocar tierra.
> La nave ya no va a despegar.

Notas:

## Lámina 7 · El oasis

- Imagen: res://assets/intro/07_el_oasis.png
- Segundos: 9
- Voz o sonido: ninguno

Texto:

> Un valle chico, con agua y pasto, en medio de la nada.
> Acá nos quedamos.

Notas:
