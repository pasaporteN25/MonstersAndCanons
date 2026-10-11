# Borrador de la página del juego (itch.io)

**Estado:** borrador de T239, sin publicar. Lo revisa y lo publica **Lucas**. Los textos describen lo que el juego hace hoy (versión 1.0.0); donde algo no se probó, queda marcado con **[confirmar]**.

- **Título:** Monsters & Canons
- **Tipo en itch.io:** juego descargable (Windows, Linux, Android). Gratis.
- **Etiquetas sugeridas:** tower defense, estrategia, 2D, software libre, GPL, Godot, un jugador.
- **Idioma:** español.
- **Enlace al código:** https://github.com/pasaporteN25/TDv1 *(hoy privado; pasa a público cuando Lucas lo decida, ver `revision-repo.md`)*.

## Descripción corta

Tower defense 2D en español: construí torres, mejorá la defensa y frená a los monstruos en 15 niveles. Gratis y de código abierto.

*(Variante de una línea para la tarjeta: «Defendé el oasis con torres y recursos limitados. 15 niveles, gratis, código abierto.»)*

## Descripción larga

**Monsters & Canons** es un juego de defensa de torres en 2D. Los monstruos entran por uno o varios caminos y tu tarea es que no lleguen a la salida: elegís dónde poner cada torre, cuándo mejorarla y con qué oro y recursos cuidás el resto de la partida.

**Qué tiene**

- **Campaña de 15 niveles**, con mapas que van de la pradera a las ruinas y un final con jefe. Cada nivel se abre al ganar el anterior y guarda sus estrellas.
- **Torres distintas** (básica, ráfaga, cañón, francotirador, mortero, hielo, fuego, Tesla, entre otras), que se mejoran de nivel y se combinan entre sí.
- **Enemigos con comportamientos propios**: los hay rápidos, blindados, voladores, que curan, que apagan torres, que roban oro o que se parten al caer. La Wiki del juego los va explicando a medida que aparecen.
- **Una intro corta** de siete láminas con la llegada a un planeta seco, que se puede omitir y volver a ver desde la Wiki.
- **Modo Asedio**: los 15 mapas con monstruos más duros y progreso propio.
- **Mapas y modos de la comunidad**: un editor de mapas (en PC) y la posibilidad de jugar mapas y modos hechos por otras personas.
- **Wiki integrada** con guía, torres, enemigos, lore y licencias.
- **En PC y en el celular**, en pantalla horizontal.

**Sobre la dificultad.** El juego está pensado para aprenderse jugando: los primeros niveles son tranquilos y los últimos exigen combinar torres y mirar con atención de dónde viene cada ola. La dureza del modo Asedio salió de un bot de pruebas y puede necesitar ajustes **[confirmar tras la partida completa de Lucas, spec T258]**.

**Software libre.** El juego es gratuito y su código, datos, dibujos y sonidos propios se distribuyen bajo la GPL 3 o posterior. Podés leerlo, modificarlo y compartirlo.

## Capturas sugeridas

Entre 5 y 8, en 1280×720 o 1920×1080, con el juego en partida (no en el editor de Godot). La primera es la que aparece en la tarjeta. Las capturas de T236/T238 en `art/` son material de trabajo, no están pensadas para la página: conviene sacarlas de nuevo con la versión final.

| # | Qué mostrar | Momento |
|---|---|---|
| 1 | **Nivel 1, «Campamento de aterrizaje»** | Oleada 3 o 4 con 4–5 torres básicas colocadas y enemigos recorriendo el camino; el HUD completo a la vista. |
| 2 | **Nivel 2, «El paso del agua»** (Desfiladero) | Una torre abierta con su panel de mejoras, para mostrar que se mejoran. |
| 3 | **Nivel 7, «El aserradero»** (Cruce) | Oleada con la Cuadrilla (Ratero y Cargador) y torres de área barriendo. |
| 4 | **Nivel 12, «El paso hacia el norte»** (El cañadón) | Camino en zigzag con el Espejo en pantalla y torres de largo alcance disparándole. |
| 5 | **Nivel 13, «El camino al resto de la región»** (Paso alto) | Dos entradas activas a la vez, mapa de nieve con la laguna de hielo. |
| 6 | **Nivel 15, «La Central»** | Oleada 30 con el Coloso en el camino y muchas torres puestas; es el mapa más grande. |
| 7 | **Intro**, lámina 4 o 7 (el planeta seco con el punto verde / el oasis) | Con el texto visible abajo. |
| 8 | **Wiki → Enemigos** (opcional) | Una entrada abierta, para mostrar la enciclopedia. |

Notas: evitar capturas con el modo de pruebas activo (muestra opciones que no son del juego normal) y con pantallas de victoria de niveles que revelen el final si se quiere cuidar la sorpresa del 15.

## Requisitos

**Windows (PC)**
- Windows de 64 bits (el ejecutable es x86_64). **[confirmar versión mínima: no se probó en una máquina Windows real; el `.exe` fue exportado desde Linux]**
- Placa gráfica con OpenGL (el juego usa el renderizador *Compatibility* de Godot, pensado para equipos modestos).
- Unos 110 MB de disco. No hay instalador: es un solo archivo.
- Teclado y mouse.

**Linux (PC)**
- Procesador de 64 bits Intel/AMD, escritorio con X11 o Wayland y OpenGL.
- Unos 75 MB de disco. Un solo archivo (`MonstersCanons.x86_64`).
- Teclado y mouse. Probado en la máquina de desarrollo.

**Android**
- Android 7 o superior, procesador de 64 bits (arm64). **[confirmar: la APK no se probó en un dispositivo real; el SDK recién se preparó en T237]**
- Pantalla táctil, en horizontal.
- El editor de mapas solo se maneja bien con mouse y teclado, por eso no aparece en el celular salvo con el modo de pruebas.
- La APK es de firma de depuración, no de Play Store: hay que permitir «instalar apps de origen desconocido».

## Guardado

El progreso queda en el dispositivo (carpeta de datos de usuario del juego). No hay cuenta, ni conexión a internet, ni anuncios, ni compras.

## Licencia y código fuente

*Monsters & Canons* es software libre, bajo la **GNU General Public License, versión 3 o posterior** (GPL-3.0-or-later). El texto completo está en el archivo `LICENSE` del repositorio.

- **Código fuente:** https://github.com/pasaporteN25/TDv1 (etiqueta `v1.0` para esta versión, una vez creada por Lucas).
- Quien reparta una versión modificada debe hacerlo con la misma licencia y ofrecer su código fuente.

## Hecho con Godot (aviso MIT, RF-387)

Hecho con **Godot Engine** (https://godotengine.org), bajo la licencia MIT:

> Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md).
> Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

El mismo aviso está dentro del juego, en **Wiki → Guía → Licencias** (`data/wiki/licencias.json`). La herramienta de tests GUT (MIT) no va dentro de los ejecutables.

## Notas de la versión 1.0

Ver `notas-version-1.0.md`.
