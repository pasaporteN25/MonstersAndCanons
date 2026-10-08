# T219 · Entrega provisional de arte

Se entregan once dibujos vectoriales: tres clases de objeto con variante de trabajo, cuatro suelos despejados y una marca plateada de pieza pendiente. Las fuentes originales se conservan en `sources/`; los finales están en `assets/sprites/map/`. La hoja de contacto muestra todos los estados a 220 px y 34 px sobre fondos de pradera, bosque y ruinas.

**Integración:** el árbol y la roca permanentes siguen usando sus dibujos actuales. Estos recursos nuevos esperan los nodos de obstáculos de T206/T207, todavía no presentes, así que no se tocaron escenas ni lógica. Tampoco es posible capturar una demolición en partida hasta que T207 conecte esos estados; la captura de esta entrega se limita a la presentación visual de los recursos.

**Estado:** provisional; aprobación de Lucas pendiente. No bloquea la implementación de código.

**Verificación:** `godot --headless --import`; suite GUT **1034/1034**, 9365 asserts, 0 `SCRIPT ERROR`/`Parse Error`. No se pudo probar la integración ni capturar una demolición real porque T206/T207 todavía no existen; tampoco se probó la exportación de Windows. El resultado está en `specs/03-tareas.md`.
