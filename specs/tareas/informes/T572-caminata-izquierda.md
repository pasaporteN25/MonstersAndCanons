# T572 · Caminata hacia la izquierda

**Fecha:** 2026-11-02. **Método:** lectura de `EnemyVisual`/`Enemy` y medición de las hojas PNG fuente con Pillow en resolución original (1024 × 1024; cuadros de 256 × 256). No se alteraron sprites ni recursos de juego.

## Qué dibuja el juego

`Enemy.visual_frame_region()` pasa la distancia recorrida y `_heading` a `EnemyVisual.walk_region()`. La fila 0 es derecha y la fila 2 izquierda; `walk_frame()` avanza cíclicamente de 0 a 3 según distancia recorrida. `_animate()` interpola `_heading`, así que al doblar entre el tramo derecho y el tramo izquierdo del nivel 1 puede seleccionar temporalmente la fila 1 (abajo); al asentarse hacia la izquierda debe quedar en fila 2. No hay una rama especial que detenga o invierta el avance de cuadros hacia la izquierda. Los tests existentes de `EnemyVisual` comprueban orientación, avance por distancia y atlas completos.

## Medición por enemigo

Cada rango resume los cuatro cuadros de esa orientación: ancho × alto del contenido no transparente en píxeles fuente, seguido de la coordenada inferior exclusiva del contenido (`@`). En cada cuadro las poses son distintas. El apoyo inferior es estable salvo los valores indicados.

| Enemigo | Derecha (fila 0) | Izquierda (fila 2) | Lectura |
|---|---:|---:|---|
| Blindado | 171–186 × 132–135 @191 | 177–179 × 134–137 @191 | Pose distinta |
| Jefe | 145–148 × 134–135 @191 | 143–148 × 131–139 @131–139* | Pose distinta |
| Cargador | 149–156 × 151–154 @192 | 150–154 × 151–152 @192 | Pose distinta |
| Coloso | 128–154 × 155–158 @191 | 128–143 × 155–158 @191 | Pose distinta |
| Fragmento del Coloso | 116–139 × 131–136 @191 | 119–127 × 135–141 @135–141* | Pose distinta |
| Rápido | 151–158 × 117–120 @191 | 146–160 × 114–116 @114–116* | Pose distinta |
| Guardián | 168–174 × 146–149 @191 | 166–176 × 156–158 @156–158* | Pose distinta |
| Sanador | 140–151 × 148–149 @148–149 | 142–157 × 144–150 @144–150 | Pose distinta |
| Espejo | 180 × 137–149 @137–149 | 176–182 × 140–147 @140–147 | Pose distinta |
| Normal | 124–139 × 152–154 @190–191 | 117–138 × 151–153 @190–191 | Pose distinta |
| Cargador de ariete | 177–180 × 121–123 @191 | 177–180 × 121–122 @191 | Pose distinta |
| Ratero | 137–158 × 122–129 @192 | 145–153 × 123–128 @192 | Pose distinta |
| Chamán | 157–164 × 149–152 @191 | 156–163 × 146–149 @191 | Pose distinta |
| Araña | 160–184 × 150–157 @191 | 171–178 × 155–158 @191 | Pose distinta |
| Arañita | 166–177 × 138–147 @191 | 169–176 × 144–154 @191 | Pose distinta |
| Tanque | 142–164 × 150–152 @190 | 153–157 × 146–150 @146–150* | Pose distinta |
| Ladrón | 151–161 × 135–146 @191 | 155–172 × 139–148 @139–148* | Pose distinta |
| Troll | 133–144 × 145–149 @191 | 135–143 × 147–150 @147–150* | Pose distinta |

\* En esos atlas, alguna vista deja más píxeles por debajo que otras; el valor se midió tal cual, no se interpreta automáticamente como flotación porque el `used_rect` mide alfa del dibujo y no un punto anatómico de apoyo. Los recursos colocan los pies en la fila 191 o 192 en casi todos los ciclos; las excepciones deben cotejarse visualmente antes de corregirse.

## Conclusión y límites

No se encontró evidencia de que falte la orientación izquierda ni de un error de selección de fila/cuadro en el código. La hipótesis más consistente con T431 es **pose distinta**, en particular donde la fila izquierda muestra más frente o cambia la silueta. No se propone arte en esta tarea: la medición sola no permite decidir cuáles poses conviene redibujar, y cualquier arte necesitaría aprobación de Lucas.

La traza solicitada en partida real no se pudo hacer: en este entorno solo hay ejecución headless y no se dispone de ventana/captura. Por esa razón no hay capturas de partida ni de zoom 2,0, y no se afirma haber comprobado visualmente el tramo 4 del nivel 1, las transiciones en pantalla ni el apoyo de los pies. Las pruebas existentes cubren la lógica de selección de dirección, ciclo de cuatro cuadros y atlas, pero no sustituyen esa revisión en una ventana real.
