# T477 · Muestra de fondos de franjas

**Estado:** Lucas aprobó las siete muestras al mergear el PR #66 (2026-10-24). T478 integra esos PNG sin modificar su composición.

Abrir `index.html` en un navegador. Permite alternar siete temas, cambiar entre 16:9, 16:10, 21:9, 4:3 y 20:9, y acercar el esquema del mapa sin mover el fondo. El marco lógico y el mapa esquemático sirven para conversar sobre las franjas; no son una captura ni representan un nivel existente.

Los temas de campaña se verificaron contra `data/levels/level_01.json` a `level_15.json` y `scripts/logic/map_themes.gd`, en `origin/main` `debef6c` (merge #65): pradera 1–5 y 15; bosque 6–7; ruinas 8–9 y 14; desierto 10–12; nieve 13. Volcán y pantano son válidos en `MapThemes` y aparecen como opciones de editor, sin niveles oficiales de campaña. El nivel 15 conserva `pradera` según su JSON.

Las imágenes se generaron con ImageGen integrado en Codex, usando como referencias los suelos activos de `assets/tiles/rendered/` y, donde corresponde, `assets/sprites/map/rendered/tree.png`. Son estudios iniciales de color, material y densidad; no se asumen como aprobación del estilo final. Algunas generaciones agregan formas rocosas en los bordes (por ejemplo, ruinas y volcán); Lucas debe decidir si sirven o se rehacen, y no representan estructuras o geografía canónicas. Los PNG miden 1672×941 (relación 16:9) y viven solo en esta carpeta de arte. No se importaron en Godot, no se tocaron assets runtime y no se ejecutaron tests.

La muestra no crea geografía, casillas, caminos, estructuras, símbolos de facción ni canon. En especial, no presenta T477 como reescritura del mapa planetario T427/T428/T469. El recorte es cálculo CSS para discutir encuadre; la validación real depende de T476/T478.

El visor original se conserva como referencia de los recortes revisados. Las siete imágenes aprobadas son las que T478 copia a `assets/backgrounds/stripes/` para uso de runtime.
