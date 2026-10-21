---
paths:
  - "assets/sprites/**"
---

# Reglas para el arte (`assets/sprites/`)

Todo dibujo sigue **`specs/05-guia-de-arte.md`**: leerla antes de dibujar. En resumen:

- SVG de **64×64**, fondo transparente, vista lateral **mirando a la derecha**.
- Contorno `#202330` de ancho 2 (enemigos); `#2b2233` en torres y mapa. No se mezclan en un mismo dibujo.
- Relleno con un **degradé de 3 paradas** (luz, medio, sombra) y **una sola** línea de brillo por pieza grande.
- Nada de texto, filtros, desenfoques ni **sombras dibujadas** (la sombra la pone el juego).
- **Bestias con carácter, nunca infantiles.** Se tienen que distinguir por la silueta a **34 px**.
- Un enemigo nuevo usa un color que **no** esté en la tabla de la guía.
- Un dibujo nuevo se aprueba con una **hoja de contacto** (a 220 px y a 34 px) y una captura del juego; Lucas las ve antes de darlo por terminado.
- En el código, los dibujos van con **`preload`** (no `load`): así es como los usa el juego. En una prueba con ventana, un `load()` de un SVG recién importado se ve blanco.
- La decoración del mapa (rocas, árboles, cactus…) lleva **una sombra suave en el suelo** dibujada, como las existentes; los enemigos y las torres no (esa sombra la pone el juego).
- **Excepción para la familia renderizada del mapa:** si la tarea sigue la dirección T277, consultar la sección 4 de specs/05-guia-de-arte.md y usar los PNG RGBA de **128×128** en assets/sprites/map/rendered/ como referencia de volumen, material, perspectiva y luz. No aplicar las simplificaciones SVG a esa familia. Las propuestas requieren igualmente hoja a 220/34 px y captura real para que Lucas las revise.
- El comentario del SVG va **en castellano**, en una línea, al principio.
