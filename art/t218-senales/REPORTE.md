# T218 · Concepto de señales

## Estado

Concepto preparado y producido como **PROVISIONAL** porque no llegó respuesta del coordinador durante esta tarea. La integración y la captura en partida están hechas; la aprobación artística de Lucas sigue pendiente, así que la tarea no se declara visualmente cerrada.

## Concepto

Seis objetos discretos y estáticos de 64 × 64 px, dibujados en SVG con fondo transparente, contorno de decoración `#2b2233`, relleno en tres tonos y sombra suave dibujada al suelo. Se distinguen por forma a 34 px. Ninguno se parece a una torre, un enemigo ni al camino jugable. La roca del oasis y el bloque de ruina repiten exactamente el símbolo A: dos diagonales con una barra corta.

Ver [hoja conceptual HTML](concepto.html), [contacto a 220 px](hoja_220.png) y [contacto a 34 px](hoja_34.png), con fondos de pradera, bosque y ruinas: [roca marcada](sources/roca_marcada.svg), [sendero](sources/sendero.svg), [herramienta](sources/herramienta.svg), [poste con cintas](sources/poste_cintas.svg), [símbolo en ruina](sources/simbolo_ruina.svg) y [campamento vacío](sources/campamento_vacio.svg).

| Pieza | Tamaño / estado | Aparición prevista |
|---|---|---|
| `roca_marcada` | 64 × 64; estática | Niveles 1 y 5; ruinas del 8 |
| `sendero` | 64 × 64; estática | Nivel 2 |
| `herramienta` | 64 × 64; estática | Nivel 3 |
| `poste_cintas` | 64 × 64; estática | Nivel 4 |
| `simbolo_ruina` | 64 × 64; estática | Niveles 8 a 10 |
| `campamento_vacio` | 64 × 64; estática | Niveles 14 y 15 |

Todas las señales son casillas bloqueadas (`construible: false`) y funcionan solo como decoración. No se agrega `hito`: la lista acordada para T218 queda limitada a las seis señales de la ficha y la biblia.

## Revisión solicitada

Pedir a Lucas aprobación del símbolo A repetido y del lenguaje visual general. Si propone cambios, ajustar el concepto antes de finalizar. Mientras no responda, la producción continúa como provisional por instrucción del despacho.

## Integración y verificación

Los seis SVG ya están en `assets/sprites/map/` y sus fuentes originales se guardan en `sources/`. `MapDrawings` los registra como objetos del catálogo cerrado y los precarga; `LevelDecor` reutiliza el pintado existente de objetos de leyenda, encima del suelo temático. El test de catálogo comprueba que existen, miden 128 × 128 px importados (64 × 64 de origen), conservan alfa y se dibujan en niveles y temas.

La captura [capturas/partida.png](capturas/partida.png) muestra la partida con `tools/ejemplos/tema_ruinas.json` y una fila de prueba que ocupa seis casillas de pasto con `construible: false`. Se agregaron 6 objetos al catálogo, ahora hay 18 objetos y 4 suelos. Los tests completos se registran en `specs/03-tareas.md`.

No se usó generador de imágenes. La revisión visual final y la aprobación de Lucas siguen pendientes; el arte queda provisional hasta entonces.
