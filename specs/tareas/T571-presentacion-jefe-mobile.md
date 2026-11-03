# T571 · Presentación del jefe a pantalla completa en el celular

- Ejecutor · Sonnet · esfuerzo medio
- Depende de · T569 (mismo host) · Compuerta · ninguna (arte nuevo: T367) · Tamaño · Mediano

## Leer

`specs/01-spec.md`: RF-738, RF-666 a RF-673, RF-726. `specs/04-decisiones.md`: D-224. `scenes/ui/boss_presentation.gd`, `scenes/game/game.gd:1022-1045`, `scripts/data/boss_presentation_art.gd`, `data/ui/boss_presentation.json`.

## Lo que se sabe

Lucas dijo que «la imagen de llega el jefe no está optimizada para el celular», sin más detalle, y **nadie la vio en un teléfono**. Por el código: la capa vive dentro del marco de 1280 × 720, así que en 20:9 se ven las franjas; solo el Coloso tiene fondo; el Jefe usa su retrato sobre un color liso, y la columna de textos usa un ancho fijo de 900 px.

## Objetivo

Que en cualquier teléfono la presentación ocupe toda la pantalla y se lea entera.

## Alcance

**Sí:** `scenes/ui/boss_presentation.gd`, `scripts/host/presentation_host.gd` (fondo temporal sin el apagado de RF-726), `scripts/autoload/game_flow.gd` y `scenes/game/game.gd` si hace falta para pedirlo, `data/ui/boss_presentation.json`, tests, `CHANGELOG.md`.

**No:** tiempos, pausa, salteo, cuándo aparece, ni producir arte.

## Pasos

1. **Primero**, capturas de cómo se ve hoy en 16:9, 19,5:9, 20:9 y 21:9, con Jefe y Coloso, en celular simulado. Anotar lo que se encuentre.
2. Al abrir en modo celular, el host muestra el fondo del jefe (o el color teñido) en toda la superficie, sin el material de las franjas. Al cerrar, por cualquier camino, vuelve el fondo del terreno.
3. Revisar que la composición entre en 720 px: título, retrato, nombre, descripción y pista. Si hace falta, otra disposición para el celular (por ejemplo, retrato a un lado y texto al otro), con los valores en datos.
4. Letra de al menos 16 px lógicos. Descripciones largas: comprobar en español y en inglés.
5. Tests: abre y restaura el fondo por tiempo, por salteo y por «Atrás»; sin fondo usa el color; ningún rótulo se sale del marco, en todos los jefes; la PC se ve igual.
6. Capturas después, en las mismas proporciones.

## Hecho cuando

En las cuatro proporciones no se ven franjas del terreno y el texto entra. Al cerrar vuelve el fondo correcto. Tiempos, pausa y salteo siguen con sus tests en verde. Hay capturas de antes y después.

## Verificación

Suite completa sin `SCRIPT ERROR`. **No se puede probar acá:** un teléfono real. Si Lucas se refería a otra cosa, por ejemplo al recorte del fondo, lo va a ver en las capturas: dejarlas en el PR.

## Frenar si

Las capturas muestran que lo que falla es la ilustración misma: es T367 y necesita arte aprobado.
