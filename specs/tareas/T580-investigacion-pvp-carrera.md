# T580 · Investigar el modo PvP por carrera de niveles

- Ejecutor · Opus · esfuerzo alto
- Depende de · nada · Compuerta · ninguna · Tamaño · Mediano
- Prioridad · baja · posterior a V1

## Leer

`specs/01-spec.md` §11 y §13 (B-65); `specs/tareas/informes/T578-investigacion-pvp-lan.md`, en particular el modo A «carrera en paralelo», la semilla compartida y las mediciones de FPS y ×2. Consultar las fuentes y el código que hagan falta para el informe, sin modificarlos.

## Objetivo

Investigar la idea de Lucas: cada jugador juega su propia partida, nivel tras nivel, sin pelear directamente contra el otro, hasta que uno pierde todas sus vidas. Lucas aceptó posponer el PvP. **Solo investigar: no se aplica nada al juego.**

## Alcance

**Sí:** un informe en `specs/tareas/informes/T580-investigacion-pvp-carrera.md` con alternativas, costos, riesgos y recomendación.

**No:** código, datos, escenas ni cambios al juego. No implementar el modo ni ejecutar pruebas que modifiquen el repositorio.

## Qué tiene que contestar

1. **Reglas y variantes:** comparar la carrera hasta perder todas las vidas con (a) X reinicios de vida o vidas extra por jugador y (b) vidas infinitas, con victoria para quien perdió menos vidas en total. Aclarar qué significa cada reinicio y proponer cómo termina la variante infinita.
2. **Progresión:** cómo se acumulan, trasladan o reinician las vidas entre niveles, qué niveles se juegan y cuándo termina cada variante, incluidos empates.
3. **Ritmo e interrupciones:** qué pasa con la pausa, ×2, desconexión, reconexión y segundo plano, especialmente en celular, y cómo afectan la equidad.
4. **Arquitectura:** host y cliente, responsabilidades, ENet, semilla compartida, mensajes y estado necesario entre partidas; aprovechar lo investigado en T578.
5. **Equidad:** evaluar el problema de FPS y ×2 observado en T578, sus límites de medición y qué habría que comprobar entre dispositivos; no confundir semilla compartida con resultados idénticos.
6. **Costo y riesgos:** desglosar tareas estimadas, riesgos técnicos y de diseño, y qué afectaría al juego actual.
7. **Recomendación:** elegir o posponer una variante con sus motivos y el primer paso más barato.

Citar fuentes externas con enlace y fecha, y separar lo verificado de lo estimado.

## Hecho cuando

El informe responde los siete puntos y compara las variantes con costos y una recomendación. El tablero registra honestamente lo investigado y lo que quedó sin verificar; no se modifica el juego.

## Verificación

No afirmar equidad, rendimiento o funcionamiento de red sin evidencia. Si no se probó en dos dispositivos, decirlo.

## Frenar si

Contestar exige cambiar el juego: describir lo que haría falta, sin hacerlo.
