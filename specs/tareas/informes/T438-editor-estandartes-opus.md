# T438 · Análisis Opus del editor cosmético de estandartes

**Fecha:** 2026-10-21. **Modelo:** Claude Opus. **Modo:** lectura solamente; no modificó archivos ni usó Git.

## Recomendación

Hacer ahora el cambio visual pedido para el poste del nivel 6. Mantener dos variantes fijas y cambiar al emblema del jugador cuando el nivel tenga una victoria registrada; se actualiza al volver a entrar. No sumar todavía el editor cosmético.

## Evidencia del repositorio

- El nivel 6 usa la letra de leyenda «p» para poste_cintas; el recurso actual no tiene emblema y T434 lo clasificó como pieza provisional.
- MapDrawings precarga una textura por dibujo y LevelDecor elige su textura; Level no sabe el progreso guardado.
- SaveManager.is_completed ya responde si un nivel se ganó. GameFlow distingue campaña, modo, comunidad y prueba del editor.
- Las preferencias settings solo admiten números y booleanos. UiPrefs es el patrón existente para estructuras pequeñas validadas.
- Ya hay un editor de mapas para desktop, pero no edita dibujos de decoración: estos siguen en JSON.
- El nombre «Estandarte» ya identifica una torre del juego. Conviene llamar «banderín» o «emblema» al elemento decorativo.
- En el lore, el poste de cintas es una señal de los Moradores, el símbolo A aparece en niveles previos y la colonia todavía no tiene emblema. Los estandartes con símbolo propio pueden sumar canon y requieren revisión de Lucas.

## Propuesta mínima del editor futuro

Un panel chico dentro de Opciones con vista previa grande y a tamaño de mapa. Permitir elegir entre listas cerradas de fondo, borde y emblema; guardar una receta pequeña con ids estables, no una imagen final ni archivos arbitrarios. Ofrecer confirmar, cancelar y restaurar el emblema predeterminado.

Persistirlo separado del progreso de campaña. settings no acepta un diccionario; para estructura, tomar UiPrefs como antecedente y validar versión, ids y valores. Un guardado viejo o dañado debe cargar el emblema predeterminado sin afectar otros datos. No subir SAVE_VERSION sin una razón demostrada.

Desktop: mouse y teclado con foco visible, selección y Escape para cancelar. Mobile: controles grandes, sin depender de hover y con blancos táctiles de MobileUiConfig. La experiencia móvil se puede separar en otra etapa.

## Pruebas para cuando se implemente

Cubrir receta predeterminada, combinaciones válidas, ids desconocidos, valores fuera de paleta, archivo ausente/corrupto/versión vieja, migración, editar/preview/cancelar/confirmar/restaurar, navegación por teclado y touch donde aplique, contraste y que el cosmético no cambie progreso ni identidad de facción. Verificar la silueta a 34 px y la vista previa en el tamaño real.

## Riesgos y decisiones pendientes

1. Si el estandarte enemigo debe usar el símbolo A de los Moradores o una marca neutral. El nivel 6 todavía no presenta a ese grupo; Opus recomienda no anticiparlo sin decidir su efecto narrativo.
2. La colonia todavía no tiene un emblema canónico; aprobar el diseño también incorpora canon si se usa en otros lugares.
3. El emblema se debe distinguir sin depender solo del color, y el poste no debe confundirse con la torre Estandarte.
4. Para el futuro editor, Lucas deberá decidir las listas de formas/colores, alcance desktop/mobile, persistencia y si el diseño también se usa en el mapa planetario. Recomendación: Opciones, desktop primero; no incluir texto libre, imágenes importadas ni compartir diseños en el MVP.

## Estimación

- Cambio del poste según victoria: **S**.
- Editor solo desktop: **M**.
- Editor con celular completo, arte final y uso en mapa planetario: **L**.

## Límites del análisis

Opus leyó el onboarding, las reglas/guía de arte, las decisiones y secciones relevantes de spec, y el código de progreso/dibujos. No inspeccionó el código del editor de mapas ni ejecutó Godot o capturas. Su inferencia sobre el lore y el alcance debe leerse como recomendación, no como decisión aprobada.
