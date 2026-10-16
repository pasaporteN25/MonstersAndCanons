# T263 · Muestras de la mejora de torre en el celular

Evidencia del informe [`specs/tareas/informes/T263-mejora-torre-mobile.md`](../../specs/tareas/informes/T263-mejora-torre-mobile.md). Todo se generó el 2026-10-16 **en escritorio** (Linux, GTX 1660 Super, Godot 4.7.2) con `tools/t263_upgrade_mock.gd`, no en un celular. **Ninguna alternativa está aprobada.**

- `lamina_<situación>_<tag>.png`: la misma situación en las cuatro variantes (arriba: Antes y A; abajo: B y C). Situaciones: `normal` (torre al centro), `derecha` (torre en la columna 17, donde hoy el panel la tapa), `sin_oro` (35 de 60) y `maximo` (nivel 3).
- `lamina_estados_<a|b|c>_<tag>.png`: todos los estados de una alternativa (normal, sin oro, máximo, Vender armado, detalles abiertos, torre a la derecha).
- `<antes|a|b|c>_<situación>_<tag>.png`: cada captura a tamaño completo.
- `_20x9`: pantalla lógica de 1280 × 720 dentro del marco negro de un celular de 1080 × 2400 (405 ppi). `_16x9`: la misma pantalla sin marco (720 × 1280, 294 ppi).
- `medidas_<tag>.csv`: tamaño de cada botón en px virtuales y en mm del celular supuesto.
- `salida_<tag>.txt`: lo que imprimió la herramienta (medidas, mapa tapado, toques corridos, doble toque y flujos con toques simulados).

Antes = el panel real del juego. A, B y C = controles dibujados por la herramienta encima del HUD (el panel real se oculta); sus botones funcionan. No son arte final. Para regenerarlo, ver el §10 del informe. Los `.import` que crea Godot no se versionan.
