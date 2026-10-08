# B-21 · Investigación de profundidad de escena

> **Reemplazada (2026-10-06):** este estudio fue preliminar. El análisis v2, con la partida real, cuatro vistas jugables y mediciones, está en [`art/b21-vista/B21-vista-v2.md`](../b21-vista/B21-vista-v2.md) (T193).

Entrega de análisis y tres prototipos reproducibles. La producción sigue con su cámara2D y sus mapas actuales.

| Alternativa | Muestra real | Qué prueba | Migración estimada |
|---|---|---|---|
| Relieve2D | profundidad_relieve2d.png | Canto del tablero, piso sin proyección nueva, sprites verticales | 3–6 días para materiales/bordes por terreno y revisión de los siete temas |
| Oblicua2D | profundidad_oblicua2d.png | Transformación afín del piso, sprites verticales y alineación de posiciones | 8–15 días, más arte si se cambia el ángulo |
| Suelo3D + sprites | profundidad_suelo3d.png | PlaneMesh real con material y tres Sprite3D con profundidad, cámara ortográfica | 15–30 días más revisión móvil/arte |

Son el mismo mapa Pradera, mismas tres posiciones lógicas y mismos iconos. Ejecutar `godot --path . res://art/redesign-m36/depth_preview.tscn`, con APPDATA aislado. El mapa es una captura del suelo/decoración actual: la decoración está horneada en el plano y todavía no tiene geometría ni oclusión propia. Los iconos muestran alineación; no demuestran apuntado con todas las vistas. No confundir esta prueba de presentación con una migración jugable.

## Evaluación

**Relieve2D recomendado como siguiente paso visual.** Conserva las coordenadas de caminos, alcance, selección y construcción. Se pueden elevar bordes bloqueados y añadir luz de contacto a los materiales existentes sin inclinar la lógica. Debe revisar si las rocas elevadas tapan enemigos y si se confunden casillas construibles; no cambiar las sombras de torre aceptadas. La muestra usa un canto único, no un nuevo sistema de alturas.

**Oblicua2D:** el prototipo conserva sprites verticales para no deformar los monstruos. La decoración horneada sí se comprime: es la limitación visible que exige separarla del suelo. Cada clic debe pasar por la inversa de Transform2D antes de convertirlo a casilla; la vista previa, alcance y caminos se proyectan con la misma transformación. Ordenar por pie proyectado, no por esquina del sprite. HUD fuera de la transformación. El ancho adicional de la proyección exige ajustar cámara/zoom, también en mapas26×12. Puede reutilizar JSON/guardados, pero requiere revisar todas las conversiones mundo/pantalla; aumenta el riesgo de selección incorrecta en bordes.

**2.5D:** la prueba dibuja un plano y sprites con prueba de profundidad real. Las bases y objetos deberían ser planos/meshes separados, y los cuerpos billboard; para no girar la iluminación pintada hay que conservar los atlas direccionales y el ángulo respecto del mundo. Selección exige raycast a un plano lógico, construcción mantiene la cuadrícula y ocupa1×1/2×2, proyectiles necesitan visualizaciones3D mientras el daño sigue en lógica. Transparencias, orden de partículas y solapamientos con la base requieren revisión: el plano actual no demuestra esas oclusiones. Guardados podrían conservar IDs/celdas, pero no serializar posiciones de cámara antiguas sin versión.

**Rendimiento:** en relieve la carga extra serían bordes; en oblicua se mantienen sprites y aumenta el área dibujada;2.5D agrega profundidad/materiales y otro flujo de cámara. Las muestras no son un benchmark200/60 ni acreditan Android: medir cada alternativa ya jugable antes de adoptarla. La prueba de rendimiento de M36 corresponde al juego2D de producción.

**Decisión propuesta:** continuar con relieve2D; descartar por ahora la migración2.5D por su costo y revisar oblicua solo si Lucas prefiere claramente esa muestra. Ninguna vista se integró. Si se elige cambiar proyección, preparar PR separado identificado como breaking change, con selección/construcción/cámara/mapas/guardados probados, y esperar aprobación explícita antes del merge.
