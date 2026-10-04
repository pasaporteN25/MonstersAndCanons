# M28 · Muestras antes de aplicar

Pedido de Lucas: revisar migración, tamaños, movimiento, escritorio1080 y unión de torreta/base antes de producir o aplicar el rediseño completo. **Nada de esta tanda cambia la partida de producción.** Fuentes generadas con image_gen y prompts en prompts.json; montajes, capturas y GIF producidos en Godot.

## Qué comparar

- `previews/sizes.png`: fila actual, A con diseños físicos aprobados y cuerpo+20%, B con cuerpo+35%. Los13 enemigos se comparan lado a lado. Volador, Blindado, Troll, Araña y Cría siguen pendientes de migración; ya existe el arte aprobado de M25/M26, no hace falta rediseñarlo otra vez. Recomendación: A general y revisar B para Rápido/Cría, preservando jerarquía de tamaños.
- `previews/motion.gif`: comparación del bamboleo actual (deformación8%) con ciclos de patas M25 sin deformación del cuerpo entero; incluye prototipo de aleteo de cuatro poses. Reproducción lenta, bucle de muestra con reinicio de posición; no es una ruta real ni animación de producción. Cabeza del volador estabilizada al empaquetar. El visor ground usa una sola vista E como ejemplo; M25 tiene cuatro direcciones. Se conservan los PNG originales. Pendiente para implementación: ritmo ligado al avance real, pausa/ralentización y transiciones de dirección; también animaciones propias para las otras criaturas. Hay variaciones entre poses generadas y el ciclo corto requiere aprobación visual.
- `previews/desktop_1920x1080.png` y `desktop_1280x720.png`: misma composición y opción de enemigos A, ventana física diferente con canvas_items. El lienzo lógico sigue1280×720, por lo que mapa y UI se adaptan juntos; la captura1080 realmente mide1920×1080 y conserva el mapa lleno. Aumentar solo el lienzo lógico dejaría más espacio sin corregir el tamaño percibido. Propuesta para Windows/Linux: ventana Full HD adaptada al monitor, conservando escalado de composición. Se debe verificar el tamaño útil del monitor y los controles en la implementación. No se cambió project.godot ni se probó Linux o celular. `desktop_combat_1920x1080.png` muestra efectos reales durante el combate; la captura principal detiene torres para ver las siluetas.
- `previews/mounts.png`: montaje actual vs A, corrimiento vertical8px a tamaño de partida y contacto sobre el aro. Cañón, Básica e Hielo en E/SE/N; los sprites actuales se conservan. Es una aproximación: si se aprueba, hay que calibrar por familia/vista y mantener punto de salida, giro y retroceso. El mecanismo actual tiene su apoyo muy cerca del borde inferior del pedestal, lo que debilita el encastre.
- `previews/concepts.png`: B con aro giratorio bajo y asiento de madera; C con abrazaderas y soporte integrado. Dos conceptos generados de una sola vista. No son atlas ni deben integrarse como sprites giratorios: requieren separar base fija/mecanismo y producir ocho vistas después de elegir.

## Reproducir

`godot --path . art/redesign-m28/preview.tscn -- --sample=sizes` (también mounts, concepts y motion). Motion guarda24 PNG; el GIF conserva esa secuencia de Godot. `prepare_flight.gd` normaliza las cuatro poses del vuelo. Para escritorio: `godot --path . --resolution 1920x1080 art/redesign-m28/capture_desktop.tscn`. Las muestras usan copias temporales de datos; no alteran balance ni archivos de producción. Los subdirectorios de imágenes tienen .gdignore.

## PR y alcance

Todo se sube a m22-modo-pruebas, PR#1. Lucas indicó que se encarga de editar la descripción del PR; no se intentará modificarla. Changelog registra esta tanda como muestras pendientes de aprobación. No se generó.exe.

Verificación:875/875 tests,6975 asserts, sin SCRIPT ERROR/Parse Error en suite ni capturas. Los24 PNG intermedios quedan locales e ignorados; se versiona el GIF final.
