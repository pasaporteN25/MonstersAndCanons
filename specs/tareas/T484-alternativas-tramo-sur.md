# T484 · Dos alternativas localizadas para el tramo sur

- **Ejecutor:** GPT‑6.1‑sol, esfuerzo alto; Impeccable 4.5.2 para refinamiento y análisis visual.
- **Depende de:** T483 como dirección aceptada por Lucas; aprobación visual de una alternativa antes de integrar T469/T471.
- **Rama:** `feature/t483-recorrido-organico`, mismo PR #79; un commit propio `T484: …`, sin reescritura ni merge.
- **Refs:** RF-691, T469/T471, T483; nueva devolución de Lucas sobre «la parte de abajo».

## Interpretación y alcance

La devolución se interpreta como el rodeo sur del recorrido (5–9). La costa inferior es la original T428 y se conserva. Si Lucas se refería a otro elemento, la lámina permite señalarlo. Se mantienen exactamente el aterrizaje, los puntos 1–4 y 10–15, el fondo, los estados y la interfaz de T483. Solo se proponen otras posiciones de 5–9 y las conexiones entre 4 y 10; no se integra arte ni se cambia runtime, mapa jugable, biomas, canon o reglas.

## Análisis previo y decisiones geométricas

T483 recuperó la identidad del atlas y abrió el recorrido, pero su centro baja hasta y=427 mientras los accesos están entre y=262 y y=321. El gran arco tiene una concavidad continua y concentra el punto 7 en el extremo inferior. Cambiar solo la costa no atendería ese gesto del recorrido y alteraría el fondo que Lucas tomó como dirección.

Se preparan dos soluciones sobre el mismo mapa:

- **A · Rodeo menos profundo:** 5–9 se aproximan a la franja central; el extremo pasa a y=366. Un giro amplio y tenue conserva la continuidad del trazo. Las distancias se mantienen desiguales y se evita una nueva alternancia arriba/abajo.
- **B · Rodeo por tramos desiguales:** una entrada diagonal, un pequeño quiebre en el 6 y un corredor central más tendido forman una concavidad asimétrica hasta y=389. El regreso se resuelve con una diagonal más larga entre 8 y 9. Son descripciones compositivas: no crean caminos jugables ni afirman una geología o altitud canónicas.

Ambas anclan en las mismas coordenadas de 4 y 10 y conservan sus segmentos externos, sin modificar el resto de la composición.

## Hecho cuando

Hay dos fuentes SVG editables, puntos JSON, capturas 1280×720, lámina comparativa y HTML junto a la T483 actual. La revisión comprueba fondo y anclajes sin cambios, ruta sobre tierra y ausencia de solapes visuales. Un crítico independiente revisa ambas antes de publicar. Lucas puede elegir A/B o precisar a qué parte inferior se refería. No se considera aprobada una variante por producirla.

## Verificación y resultado

Muestras A y B listas para que Lucas elija; **sin aprobación de variante ni integración**. El crítico independiente recomienda B: reduce el rodeo sin aplanar los niveles 5–11 tanto como A. No detectó solapes, costa invadida ni ruta atravesando símbolos de montaña; 5/9 se acercan a los ríos, legibles sin inventar puentes. La elección queda abierta. La interpretación de «parte de abajo» se declara tanto en HTML como en el PR: la costa/silueta sur todavía no se alteró.

**Verificado:** render SVG con Godot 4.7.2 en una carpeta temporal aislada y composición con Pillow; inspección visual de A/B y revisión crítica independiente. Comparación XML confirma siete bloques geográficos, aterrizaje, nodos 1–4 y 10–15 y sus estilos sin cambios. Se conservaron también los guiones originales fuera del centro mediante recorte de la ruta base. Comparación de píxeles con T483: las diferencias quedan limitadas a x=492…782 / y=286…428 en A y x=492…779 / y=286…428 en B; el resto del PNG es idéntico. Muestreo de 1.500 puntos por ruta: todos en tierra y X creciente, sin vuelta al oeste ni autocruce. Discos visibles completos en tierra, separación mínima de centros 49,3 unidades SVG frente a diámetro 40 de bloqueados. No se validan objetivos táctiles con este control.

Impeccable detect se ejecutó una vez: ocho avisos por asumir fondo blanco en elementos que heredan el fondo oscuro #181d20; los contrastes declarados superan 9,9:1. No se considera un detector limpio. Enlaces locales del HTML comprobados; no se verificó el visor interactivo en navegador porque CUA no tiene navegadores disponibles en esta sesión.

**No se probó:** juego, importación, GUT, bots, interacción, celular, rendimiento ni integración. No hay nuevos RF/D porque esta tarea no cambia requisitos ni decisiones del juego. El PR #79 contiene un commit T483 y otro T484; no se reescribe ninguno. #78 permanece como referencia histórica sin modificar ni cerrar.
