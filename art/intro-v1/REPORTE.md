# T241 · Informe de producción y verificación

**Fecha:** 2026-10-11. **Herramienta:** Codex con `image_gen` integrado. **Rama:** `feature/t241-arte-intro`.

Se entregaron siete ilustraciones en estilo A «Cuaderno de bitácora», PNG RGB de **1920 × 1080**, sin texto incorporado, con la zona inferior tranquila y oscura. Los finales están en `assets/intro/`; fuentes originales, prompts normalizados, manifest, empaquetador, miniaturas, recortes de continuidad y comparación HTML están en `art/intro-v1/`. La producción sigue el guion aprobado y no incluye la versión B.

## Evidencia

- **Imágenes:** se decodificaron las siete con Pillow y se comprobó formato PNG, dimensiones, peso y SHA-256 contra el manifest. Total: **24.354.763 bytes (23,23 MiB)**. Cada peso está en `README.md`, `manifest.json` y el HTML.
- **Revisión visual:** se inspeccionaron originales completos y las dos hojas. No se encontraron letras incorporadas ni marcas semejantes al símbolo A; se contrastó con la marca de `assets/sprites/map/roca_marcada.svg`. El calendario tiene rayas paralelas y el mapa círculo/punto de grafito. Se corrigió con `image_gen` un punto verde extra que había aparecido en el mapa de la lámina 4; se conserva esa primera salida, identificada como no final. La nave mantiene tres cúpulas y dos toberas, y los personajes conservan sus rasgos identificadores. La lámina 6 muestra cuña, cadena y candado cerrado. El oasis conserva horizonte sin señales, campamento ni criaturas.
- **Godot:** `godot --headless --import` terminó con código **0**, sin `SCRIPT ERROR`, `Parse Error` ni `ERROR:` del motor. Se comprobó que las siete importaciones `.ctex` existen. No se modificaron SVG ni otros assets anteriores.
- **GUT, corrida final:** `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit` terminó con código **0**: **113 scripts, 1569/1569 tests, 18.659 asserts**, en 61,278 s. **0 `SCRIPT ERROR`, 0 `Parse Error` y 0 `Unexpected Errors`**. La salida incluye el `push_error` esperado del test que intenta abrir el nivel `no_existe`, comprobado con `assert_push_error`.
- **Advertencia de cierre:** después del resumen verde, Godot informó `2 ObjectDB instances were leaked at exit` y `1 resources still in use at exit`. No se investigó esa advertencia ni se comprobó su presencia en una línea de base sin estos assets; no se presenta la salida como completamente libre de advertencias del motor.
- **Auditoría de recursos:** la primera corrida completa después de importar dio **1568/1569**, porque las siete imágenes todavía no son referenciadas por el juego. Se agregaron sus siete rutas exactas a `KNOWN_UNUSED` en `tests/test_resource_audit.gd`, con comentario para que **T242 las quite al integrarlas**. La corrida final pasó completa, incluida esa auditoría. No se relajó la comprobación para carpetas enteras ni se tocó la lógica del juego.
- **HTML:** se comprobó que todos los enlaces e imágenes relativos apuntan a archivos existentes. Las hojas PNG se inspeccionaron visualmente. No se pudo probar el HTML en navegador porque la herramienta de UI no tenía ningún navegador disponible.
- **Git:** `git diff --check` sin errores. Se prepara un único commit `T241: láminas de la intro`; no se hace push ni se abre PR desde este despacho.

## Incidencias de ejecución

La primera suite arrancó antes de que terminara la importación inicial: falló al cargar audios todavía no importados. Se descartó esa corrida. Hubo un segundo arranque solapado que también se detuvo; ambas ejecuciones se terminaron antes de ejecutar de nuevo la suite completa de forma secuencial. Los números de verificación citados arriba pertenecen únicamente a la corrida final, después de terminar la importación y de registrar los recursos pendientes de T242.

## Pendiente

**Lucas debe revisar y aprobar las siete imágenes.** La tarea continúa sin marcarse `[x]` en el tablero porque su criterio exige esa aprobación; la producción y el commit pedidos sí están entregados. Abrir `art/intro-v1/comparison.html` permite comparar las siete, activar la guía inferior y ver la continuidad ampliada.

No se integró la pantalla de intro, no se verificó el texto real en el juego ni en celular, no se exportó ni se midió la APK y no se retocó el epílogo. Son comprobaciones de T242 o de un encargo posterior. `CHANGELOG.md` no cambia porque estas imágenes todavía no modifican lo que ve quien juega.
