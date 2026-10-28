# T540 · Flora de Cántaro en la familia visual vigente

Abrí [`preview.html`](preview.html) o mirá [`contact_sheet.png`](contact_sheet.png). Esta galería reemplaza como propuesta a las muestras SVG de T539, que Lucas rechazó el 2026-10-27 por usar un lenguaje visual fuera de uso. Lucas aprobó las tres direcciones el 2026-10-27 para conservarlas y rotarlas; todavía no están integradas.

## Qué se propone

- **A · Trompetas enrolladas:** mata compacta de corolas carnosas y abiertas.
- **B · Cápsulas plegadas:** tres vainas de distintas alturas sobre tallos cortos.
- **C · Roseta baja:** hojas gruesas curvas con un capullo lateral.

Las tres son PNG RGBA de 128×128 y se muestran a 220 px, a 34 px y en montajes de escala sobre la captura real del nivel 1. El lienzo de integración no se define aquí. Los montajes sustituyen las flores visibles en dos sitios usando pasto recortado de una zona cercana de la captura; por eso no son capturas del motor ni composiciones exactas de integración.

## Qué corregimos del proceso

En T539 sí se consultaron los sprites renderizados, pero el encargo tomó como punto de partida técnico el histórico `flores.svg` y pidió producir SVG dibujado a mano de 64×64. La referencia vigente quedó como una mención estilística, sin impedir que el formato y las reglas vectoriales dominaran el resultado. También faltó una revisión obligatoria de la propuesta a escala real sobre una captura del juego antes de presentarla. El resultado podía ser formalmente fiel al encargo y aun así pertenecer a una familia visual obsoleta.

T540 agrega esa compuerta a `specs/05-guia-de-arte.md`: primero se identifica la familia vigente, se inspeccionan sus archivos activos y ejemplos dentro del juego; luego se produce en su técnica y formato; finalmente se revisa a escala de juego y en contexto antes de pedir aprobación. Un recurso reemplazado puede servir para saber qué función cumple, no para fijar el estilo.

## Referencias y procedencia

Se inspeccionaron visualmente `tree.png`, `rock_a.png`, `forest_idle.png` y `m79/cactus_02.png` en `assets/sprites/map/rendered/`, además de la captura vigente de nivel 1 en `art/t537-arte-campana/captures/level_01_active.png`. La referencia que guía la forma de producción es la familia pintada de volumen, luz superior izquierda y materiales mates; no el dibujo vectorial histórico.

Las fuentes generadas originales están en `sources/generated/`; los PNG RGBA de 128×128 usados en la galería, en `variants/`. Son tres propuestas nuevas generadas con la herramienta de imágenes; los originales se preservan para auditar esta reducción. Lucas aprobó las tres sin pedir redibujo. En T542 se integrarán sin recolorear y rotarán de forma estable por casilla.

## Límites y verificación

No se cambiaron sprites activos, mapas, código, niveles ni ubicaciones. No se corrieron Godot ni GUT. Se verificaron dimensiones y alfa de las tres variantes, aperturas/rutas de la galería, PNG de contacto y `git diff --check`. La aprobación visual escrita llegó el 2026-10-27; cualquier cambio posterior fuera de estas tres muestras requerirá nueva revisión.
