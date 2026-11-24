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

## Lámina 1 · Story 01

- Imagen: res://assets/intro/story_01.jpg
- Segundos: 5
- Voz o sonido: ninguno

Texto:

> La Compañía Meridiana llevaba años viajando.

Notas:

## Lámina 2 · Story 02

- Imagen: res://assets/intro/story_02.jpg
- Segundos: 9
- Voz o sonido: ninguno

Texto:

> Al otro lado de las ventanas, Cántaro era apenas un punto entre las estrellas.
> Habían dejado atrás sus hogares para construir uno nuevo.

Notas:

## Lámina 3 · Story 03

- Imagen: res://assets/intro/story_03.jpg
- Segundos: 9
- Voz o sonido: ninguno

Texto:

> Durante el viaje, aprendieron a vivir entre pasillos, depósitos y cultivos. Todo
> lo que necesitaban para empezar de nuevo estaba allí.

Notas:

## Lámina 4 · Story 04

- Imagen: res://assets/intro/story_04.jpg
- Segundos: 10
- Voz o sonido: ninguno

Texto:

> Cuando por fin encontraron agua, hicieron descender la nave. A su alrededor
> levantaron los primeros refugios y comenzaron a estudiar la tierra.

Notas:

## Lámina 5 · Story 05

- Imagen: res://assets/intro/story_05.jpg
- Segundos: 9
- Voz o sonido: ninguno

Texto:

> Nos dimos cuenta de que entre las piedras había marcas que nadie de la
> expedición recordaba haber hecho. Ahí fue cuando aparecieron.

Notas:

## Lámina 6 · Story 05

- Imagen: res://assets/intro/story_05.jpg
- Segundos: 8
- Voz o sonido: ninguno

Texto:

> ¡Monstruos! Criaturas cerca del campamento. Rápidamente, los soldados levantaron
> torres para protegernos.

Notas:
