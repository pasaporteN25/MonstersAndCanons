# T249 · Instrucciones de producción

Todo es **PROVISIONAL**: el pedido de mejora habilita esta iteración, no equivale a aprobación artística definitiva. SVG retocados directamente, con `refine_vectors.py`; PNG de la Disruptora editados con la herramienta integrada `imagegen`, no con una API externa.

## Vectores

Conservar nombres, ids, lienzos, transparencia y apoyos; contorno `#2b2233`, materiales con tres paradas, una línea de luz por pieza, sin filtros. Decoración con sombra suave dibujada; íconos y torre sin sombra. Aumentar contraste del símbolo A y repetir exactamente su geometría en roca, ruina y escombro; separar siluetas y agrandar las marcas ámbar. Cintas gastadas asimétricas; herramienta con cabeza de hueso más clara; tres pasos separados en el sendero; lona vencida y fogón apagado en el campamento. Restos despejados bajos y sin borde de isla. Mina facetada con estados distinguibles; bosque agrupado con troncos marcados y madera apilada. Colección como disco de mecanismo, sin órbitas que parezcan un átomo; lingotes simples; demoledora con ariete hacia la derecha.

## Disruptora · edición principal

Imagen objetivo: `sources/before/assets/sprites/towers/rendered/turret_disruptor.png`. Preservar identidad, bronce y hierro oscuro, cámara ortográfica elevada, luz superior izquierda y fondo realmente transparente. Mejorar lectura a 34/64 px: anillos más anchos respecto de la altura, biseles grandes y bandas simples, disco superior plano y ancho con cristal blanco azulado. Eje de hierro oscuro; columna robusta. Sin cañón, bobinas de Tesla, violeta, rayos amarillos, brillo exterior, sombra de suelo, pedestal ni texto. Objeto entero centrado con margen transparente. Resultado original conservado en `sources/disruptor_generated.png`.

## Disruptora · niveles 2 y 3

Referencia: `sources/disruptor_generated.png`. Mantener cámara, materiales, luz, proporciones y transparencia. Nivel 2: refuerzo de abrazaderas oscuras y bandas anchas. Nivel 3: además, pequeño disco emisor elevado sobre el disco superior. Evitar los mismos elementos que en el prompt principal. Las dos imágenes originales quedan en `sources/disruptor_level_2_generated.png` y `sources/disruptor_level_3_generated.png`.

El generador conservó muy poca diferencia entre niveles 1 y 2; se registra como límite, no como mejora de progresión conseguida. `pack.gd` solamente recorta alfa, escala proporcionalmente a 112 px de alto y empaqueta; no repinta. Las ocho direcciones siguen siendo copias estáticas como en T216.
