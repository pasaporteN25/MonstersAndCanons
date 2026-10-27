# T523 · Pedido y dirección usada

Fecha: 2026-10-26. Autor: Codex, OpenAI. Herramienta: Python 3 + Pillow, sin servicio generativo de imágenes. No se usó un prompt oculto de generación ni material de terceros. El generador visual lo ejecutó Codex `gpt-6.1-sol` con esfuerzo medio; las imágenes se renderizaron con Pillow.

## Resumen del pedido de Lucas

Preparar únicamente muestras, nunca integración, de los seis adornos añadidos a M79: cactus, roca roja, columna, bloque, estatua y campamento vacío. Dos variantes de cada uno, 12 PNG RGBA de 128×128 para casilla de 64×64 y lectura a 34 px. Seguir T277: volumen pintado, materiales creíbles y facetados, luz superior izquierda, transparencia y sombra suave de apoyo. No copiar la simplificación SVG T260. Referencias: rock_a, rock_b, rubble_idle, propuestas integradas, nieve M79 y rocas M80.

Cactus y roca roja pertenecen al desierto. Columna, bloque y estatua deben mostrar compatibilidad con ruinas/volcán. La estatua representa una torre del juego tallada en piedra gris erosionada sobre pedestal, nunca una persona. Campamento: restos sin ocupantes, bandera ni canon inventado. Sin textos, señales, glifo H, personajes ni aspecto de enemigo. Lo bloqueado debe comunicar obstáculo. No modificar assets, mapas, grillas, leyendas, código, datos, specs ni changelog.

Entregar fuentes reproducibles, parámetros, manifiesto con autor/modelo/herramienta/fecha/tamaño/alfa/hashes, hojas transparentes y con fondo a 220/34 px, revisión a 34/64 px, composiciones sobre capturas reales rotuladas como muestras externas y reporte en español. Lucas aprueba o rechaza cada pieza antes de T524. No correr Godot/GUT ni afirmar pruebas móviles o rendimiento. Frenar ante confusión efectiva con torre/enemigo o cambios necesarios de mapa/canon.

## Instrucciones adicionales efectivamente usadas

- Priorizar la herramienta nativa solicitada: Pillow. Renderizar geometría propia a 384×384, con reducción Lanczos a 128×128. No reflejar imágenes para no invertir la luz. Aplicar desenfoque únicamente a la sombra.
- Derivar roca roja 01 de rock_a y 02 de rock_b: conservar volumen, fracturas y alfa; convertir piedra y musgo a una paleta mineral rojiza apagada. Estratos muy leves. No agregar señales ni reservar una cara para H.
- Derivar estatua 01 de statue_cannon_moss y 02 de statue_basic_moss, esculturas ya existentes del proyecto. Quitar verde y color de metal, comprimir brillos, agregar variación mineral mate y polvo discreto. Conservar pedestal erosionado. No usar una torre activa como fuente del dibujo nuevo.
- Cactus 01: tronco central dominante y dos brazos a distinta altura. Cactus 02: brazo izquierdo alto, tronco más bajo y brazo derecho corto. Cápsulas con luz calculada, costillas y grano vegetal, sin ojos ni flores de color llamativo.
- Columna 01: fuste acanalado roto sobre base fragmentada y lascas. Columna 02: tambor acanalado caído; no completar su extremo como un cañón ni agregar boca circular.
- Bloque 01: mampuesto único astillado y fragmentos bajos. Bloque 02: dos mampuestos desplazados con faltantes y fisuras. Añadir desgaste y esquinas faltantes al revisar la primera tanda, para evitar una plataforma lisa.
- Campamento 01: lona ocre caída sobre apoyos rotos, fogón de piedra apagado y cenizas. Campamento 02: lona oliva grisácea más extendida y plegada, mismo lenguaje de fogón. Sin fuego, botín, emblema, personaje ni mástil erguido.
- Revisión de la primera tanda: reducir brillos de las estatuas, aumentar grano mineral y roturas de bloques, reforzar costillas y facetas de luz del cactus. No declarar equivalencia pictórica con T277 cuando la construcción procedural resulta más geométrica.
- Hojas a 220, 64 y 34 px: cada sprite conserva su lienzo completo y el tamaño nominal; rótulos fuera de las piezas. Transparencia real en la hoja transparente. Suelos reales del repositorio; el fondo liso secundario de desierto es una muestra neutra, no una captura del camino.
- Composiciones de niveles 10, 14 y 15: superponer exclusivamente sobre casillas ya bloqueadas o con decoración correspondiente; reponer su suelo dentro del montaje. No proponer posiciones nuevas. Dejar el resto de la captura intacto y rotular la intervención. Compatibilidad con volcán solo en hoja sobre textura existente: no inventar un nivel volcánico.
- Añadir comparación de estatuas con cañón/básica activos y Estandarte a 34/64 px, como comparación de lienzos, sin simular escalas reales del motor.

La implementación exacta y todas las constantes, coordenadas, semillas, colores y transformaciones están en `sources/generate_samples.py`; las coordenadas de montajes se exportan a `sources/compositions.json`. No hay selección aleatoria de resultados.
