# T599 · Auditoría técnica y cierre de V1

Revisión del 24-11-2026 sobre `origin/main` en `73e58f4`, después de la nueva intro (T598). El tablero tiene 38 entradas con casilla abierta. Incluyen publicación, ensayos pospuestos, arte y propuestas para otras entregas. La recomendación es congelar funcionalidades, preparar una única candidata y dedicar la próxima prueba a un Android físico.

## Qué falta para publicar

| Prioridad | Trabajo | Evidencia y criterio de salida |
|---|---|---|
| Candidata · T268 / T375 / T596 | Fijar un commit de `main` con la versión y los textos de Novedades aprobados. Ejecutar la lista de T596. Generar los paquetes acordados y registrar commit, versión, firma y hashes. | Hoy el proyecto declara `beta` y Novedades 1.0 sigue como borrador. T592–T595 y la intro T598 están integradas. T595 conservó el oro por bajas y el bono después de medir los niveles altos. |
| Android físico · T596 y parte de T454 | Instalar la candidata y verificar el recorrido corto de abajo. Registrar modelo, Android, resolución, build y problemas. | T454 tiene auditoría estática, con K1–K22 y medición de PC pendientes. T579 probó 16:9 y 20:9 con interfaz simulada. Quedaron pendientes 19,5:9 y 21:9. |
| Google Play · T597 / T239 | Crear o configurar la clave de subida de Lucas, firmar el AAB de entrega, verificar sus metadatos y probar la distribución por un canal de prueba antes de producción. Completar la ficha con capturas de teléfono y revisar acceso a producción en la consola. | T597 ya dejó presets, gráficos, privacidad y un AAB de depuración. La APK de esta auditoría usa código 4 y versión `beta`. Confirmar el código disponible en Play para el AAB final. |
| Arte · T267 | Revisar el aspecto de los niveles 1, 14 y 15. Resolver antes de V1 solo las piezas que Lucas mantenga como requisito de salida. | Hay una comparación del arte integrado. La selección y aprobación visual siguen pendientes. |

Para el recorrido corto en el teléfono, usar la [lista de T596](../T596-candidata-de-prueba.md) y los casos de [T454](../T454-reauditoria-mobile.md):

1. **Nivel 1:** leer y saltear la nueva intro, jugar el tutorial, construir, mejorar, vender y reabrir para comprobar el guardado.
2. **Niveles 7 y 9:** demoler, alternar «Solo oro» y «Usar recursos», confirmar y comprobar el cargo. Probar pinza y cancelar con el fantasma abierto. Revisar que el rótulo del carrito y Pausa se lean sin pisarse, un punto abierto de T579.
3. **Nivel 15:** probar zoom, pausa, ×2 y «Atrás» durante una carga. Registrar tirones, toques perdidos y lectura del HUD al final de una oleada pesada.
4. **Instalación y actualización:** comprobar una instalación limpia. Si hay una versión anterior del mismo paquete y firma, probar que conserve el progreso al actualizar. El cambio de identificador de T597 hace que la APK de prueba vieja quede como otra aplicación.

La verificación de la tienda incluye el SDK objetivo del bundle y el empaquetado de bibliotecas nativas. Play exige API 36 para nuevas apps Android y actualizaciones a la fecha de este informe. Si la cuenta personal se creó después del 13 de noviembre de 2023 y todavía no tiene acceso a producción, el requisito es una prueba cerrada con al menos 12 testers inscritos 14 días seguidos. Son condiciones del canal de publicación. [SDK objetivo](https://support.google.com/googleplay/android-developer/answer/11926878) · [Pruebas en cuentas personales](https://support.google.com/googleplay/android-developer/answer/14151465)

## Backlog posterior

| Grupo | Pendientes |
|---|---|
| Pruebas y rendimiento | Campaña manual y balance humano (T238, T453, T266, T280, T226, T283), que D-216 ubica después de V1. Completar el resto de T454, T364 y T369 por separado del recorrido corto de T596. |
| Pulido mobile | T479 (rotar imágenes durante la carga) depende de medición en teléfono y aprobación de Lucas. T532 (brillo de las franjas), T534 (inglés), T576/T581 (ampliar tutorial y lecciones), B-64 (mapas más largos en celular) y B-69 (confirmar reintento) pueden esperar. |
| Arte, herramientas y lore | T128 (tema y leyenda en editor), T216, T218–T221 (arte), T367/T463 (fondos de jefes) y T545 (revisión de lore). Priorizar solo problemas concretos de lectura que aparezcan en la candidata. |
| Nuevas mecánicas y alcance | T577 y T582–T585 (agua, recursos y economía), T580 (investigación de PvP), T590 (música). T586–T589 (avances y apoyos del Estandarte) quedan para M&C 2 / 3D según el plan de cierre. |

## Diagnóstico técnico

- **Juego y arquitectura.** Godot 4.7.2, GDScript y renderizador GL Compatibility, con el mismo proyecto para escritorio y Android. Hay 15 niveles, Asedio, editor, Wiki, tutorial, guardado y modo de pruebas. `data/` concentra configuración y balance. El flujo se apoya en `GameFlow`, `SceneTransition` y `PresentationHost`. Compra, guardado y controles tienen cobertura de regresión.
- **Complejidad.** `mobile_hud.gd` (~1.470 líneas) concentra gestos, composición y controles táctiles. `game.gd` (~1.280) coordina buena parte de la partida, y el HUD de escritorio sigue un camino propio. Los cambios que cruzan HUD, rieles y mapa merecen pruebas en ambas interfaces. Posponer refactors hasta después de la candidata salvo un defecto reproducible.
- **CI y empaquetado.** GitHub Actions importa el proyecto, verifica la sintaxis de herramientas y corre GUT en Linux headless en pushes a `main` y PR. Pasaron **2.760/2.760** en `73e58f4`. Tras la limpieza también pasaron 2.760/2.760 pruebas en Windows, sin errores de scripts ni de sintaxis. La CI actual no mide FPS ni verifica instalación Android. [Corrida de main](https://github.com/pasaporteN25/MonstersAndCanons/actions/runs/45338066968)
- **APK de auditoría.** Godot exportó el preset `Android` desde `73e58f4`. APK debug de 88.302.649 bytes, SHA-256 `02091a66f37fed13032abb1796b388da0d357c0ac672a61cbbe5efac27d6bd2a`, paquete `com.monsterscanonsv1.game`, solo arm64, SDK mínimo 24 y objetivo 36. Pasaron `apksigner verify` y `zipalign -c -P 16 4`; los segmentos de carga de las dos bibliotecas nativas también están alineados a 16 KiB. El manifiesto no declara permisos. `aapt2` avisó sobre un recurso de ícono temático ausente en la plantilla. Revisar el ícono visible al instalar la candidata. La alineación ZIP de esta APK no certifica por sí sola el bundle de Play. ADB no detectó dispositivos.
- **Tamaño del árbol.** `art/` suma 858,49 MiB y `Capturas/` 136,80 MiB. El árbol versionado ronda 1,06 GiB, previo al historial de Git. Los presets excluyen ambos directorios, además de pruebas, herramientas, specs y GUT. Las cinco láminas nuevas importadas pesan unos 4,6 MiB dentro del APK. Reducir el tamaño del clon requeriría una estrategia distinta a retirar un par de archivos obsoletos.

## Limpieza

- Se trasladó la skill de pantalla de carga a Godot-Skills. En el juego quedan la implementación, la spec y sus pruebas. [PR de Godot-Skills](https://github.com/pasaporteN25/Godot-Skills/pull/6)
- Se retiraron la lámina vieja de la nave, que solo servía como fixture, y un log idéntico a `contact_final.log`. Las pruebas de intro usan una imagen vigente. La galería histórica vuelve a enlazar los PNG fuente. El oasis sigue siendo el fondo del gráfico destacado de Play y se conserva.
- Se alineó el borrador de la ficha de Play con la expedición científico-militar de T598. El resto del archivo de arte conserva fuentes, comparativas y evidencia de tareas.
