# T483 · Recorrido continental orgánico sobre el atlas T428

## Encargo y límites

Iteración visual pedida por Lucas el 2026-10-24 tras rechazar las muestras T482/PR #78. T483 está libre en origin/main y en ramas/PRs al iniciar. Parte de origin/main `cb748459`. Es una muestra para decidir la dirección de T469/T471: no integra recursos, no modifica geografía jugable, canon, reglas, guardados ni datos. El original T428 es la autoridad visual; se conserva su costa, mar, tierra, relieve y ríos.

## Análisis previo al dibujo

El original tiene una masa continental reconocible, buen contraste entre mar y tierra, relieve secundario y marcadores con jerarquía. Sus dos fallos señalados por Lucas son localizables: el recorrido vuelve hacia el oeste por el borde inferior y cierra visualmente un óvalo; el aterrizaje queda fuera de la costa occidental.

T482 A mantiene una costa parecida pero estira la silueta, agranda los marcadores y colorea de rojo todas las regiones bloqueadas. Coloca las quince X cada 75 unidades, dentro de una banda vertical de solo 80 unidades en un lienzo de 450. La ruta repite tres ondas y utiliza curvas suaves parecidas sin relación con relieve o pasos: se lee como una guirnalda. La mitad superior del continente queda ociosa. T482 B añade una ensenada, pero conserva ese mismo esqueleto: no corrige la causa.

## Decisiones geométricas antes de editar

1. Conservar exactamente el SVG geográfico de T428. Cambiar costa y recorrido juntos hace más difícil evaluar qué mejora; la costa existente ofrece tierra suficiente para la nueva dirección.
2. Mover el aterrizaje al llano occidental, dentro de tierra y separado del primer marcador; conectarlo con el acceso.
3. Usar cuatro tramos visuales: acceso, avance al interior occidental (1–4), un único rodeo amplio hacia el sur (5–9) y continuación hacia el este (10–15). Son descripciones geométricas de la muestra, no nombres canónicos ni biomas nuevos.
4. Separar las X con distancias diferentes. La secuencia avanza siempre al este; ningún tramo vuelve al borde occidental ni cierra un lazo. Los cambios verticales se estiran en pasos, sin alternar arriba/abajo en cada nodo.
5. Evitar que la ruta atraviese símbolos de montaña. La ruta puede cruzar las líneas de río cartográficas; no se agregan símbolos ni una mecánica de puentes.
6. Recuperar escala, anillos, estrellas y sobriedad del original. Los estados bloqueados mantienen tratamiento gris en esta comparación; el diseño de estandartes de T469/T474 sigue siendo otra compuerta y no se pretende resolverlo aquí.
7. Comparar el original, T482 A rechazada y una única propuesta T483 a la misma resolución. Añadir una lámina de lectura que explique los giros sin convertir esas marcas en arte del juego.

## Hecho cuando

Hay fuente SVG editable, captura a 1280×720, lámina de lectura, visor HTML comparativo y procedencia reproducible. La revisión verifica que aterrizaje y recorrido están sobre tierra, que los círculos visibles no se superponen y que se conserva el atlas T428; los objetivos táctiles no se validan con esta imagen. Lucas puede aprobar la dirección o señalar un tramo; T469/T471 siguen abiertas hasta su OK.

## Método

Ejecutor GPT‑6.1‑sol con esfuerzo alto. Se usó Impeccable 4.5.2: context, principios de refinamiento y craft-floor; no se cambió configuración del proyecto ni se actualizó la skill. Revisión visual independiente coordinada por el orquestador. La generación se hace sobre una copia de muestra del SVG y la captura de T428, fuera de runtime.

## Resultado

Muestra lista para revisión de Lucas, **sin aprobación ni integración**. Hay SVG editable y puntos separados en JSON, composición 1280×720, lámina 1280×760 y visor HTML comparativo con el original T428 y T482 A rechazada.

La primera revisión independiente encontró que la primera versión todavía repetía tres arcos (crestas 3/8/14) y que los rótulos 2/3 rozaban nodos. Se corrigió en un lote: un rodeo central largo, continuidad hacia el este, círculos bloqueados menores, etiquetas separadas y 15 a la derecha de la sierra oriental. La segunda revisión crítica independiente la consideró lista para que Lucas decida; mantiene como límite el margen relativamente chico del extremo este, visible en la captura.

**Verificado:** render de SVG con Godot 4.7.2 en una carpeta temporal aislada (sin abrir/importar el proyecto), composición estática con Pillow e inspección de ambas imágenes. Comparación XML confirma los siete bloques geográficos originales intactos (solo cambia el espacio de separación antes de los elementos nuevos). Muestreo de 1.500 puntos de la ruta: todos en tierra y X estrictamente creciente, por lo que la ruta no vuelve al oeste ni se autocruza. El disco del aterrizaje y los círculos visibles completos están dentro de la costa. Separación mínima entre centros: 49,3 unidades SVG frente a diámetro 40 de los bloqueados. Esto valida dibujo estático, **no** objetivos táctiles.

Impeccable detect se ejecutó una vez sobre el HTML: nueve avisos de contraste que asumen fondo blanco al no resolver las variables CSS. El fondo declarado es #181d20; el cálculo directo da 13,16:1 para texto principal, 10,00:1 para secundario y 9,90:1 para enlaces. No se presenta el detector como limpio. Se intentó abrir el visor con CUA, pero no hay navegadores disponibles en esta sesión; por eso **no se verificó el HTML interactivo ni sus quiebres en navegador**. Se verificaron sus enlaces locales y la estructura estática.

**No se probó:** juego, importación, GUT, bots, controles/input, teléfono, desplazamiento móvil, rendimiento ni integración. No se añaden RF/D porque no cambia un requisito ni una decisión: se muestra una dirección pedida dentro de T469. No se cambia CHANGELOG ni ONBOARDING porque no hay comportamiento ni procedimiento del juego nuevo. T469 y T471 continúan abiertas hasta la decisión de Lucas.
