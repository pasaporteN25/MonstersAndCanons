# T596 · Candidata 1.0 para probar

Leer RF-755, T268/T375, plan 08 §15 y ONBOARDING. Identificar una revisión con los cambios aprobados, correr GUT y validadores, preparar la lista corta de prueba en PC y Android y anotar los resultados. Verificar versión y configuración de exportación. Exportar desde main actualizado cuando se cumplan las condiciones de entrega, registrar hashes y entregar los archivos a Lucas para su validación. T239 queda a cargo de Lucas.

## Estado de la candidata

Los cambios jugables están en `d3350fd`. GUT en un checkout limpio de ese commit pasó 2.754 de 2.754 pruebas en Windows (Godot 4.7.2). Pasaron el arranque y el validador de Novedades, con la entrada 1.0 en borrador y la versión del juego en beta. Al cerrar la ejecución headless se reprodujo el aviso ya registrado en T579 sobre los rieles.

En PC se puede abrir el proyecto de la rama y probar con F5. La APK y el ejecutable de entrega se preparan cuando los cambios estén en `main`. El equipo tiene las plantillas de exportación, JDK y SDK de Android. La prueba táctil y la prueba de actualización de APK quedan para esa build.

## Prueba corta para Lucas

1. **Arranque, nivel 1.** Abrí una partida nueva. Recorré el tutorial, construí una torre, mejorala y vendela. Ganá el nivel y volvé a abrir el juego para confirmar que guardó el avance.
2. **Nivel 6.** En un guardado sin avances del Estandarte, abrí un mapa que ofrece la torre. Construí una y comprobá su apoyo a una torre vecina. Mirá que el HUD no muestre un contador de avances.
3. **Niveles 7 y 9.** Demolé un objeto que indica una cantidad de recursos. Con el Francotirador, compará «Solo oro» y «Usar recursos», alterná sin confirmar y comprobá el cargo al colocar. En el 9, intentá comprar el Mortero y anotá en qué oleada lo lograste.
4. **Nivel 15.** Jugá un tramo tardío con zoom y ×2. Anotá cuánto oro tenés antes de la oleada final, si todavía habría algo útil para comprar y si hubo tirones o toques perdidos.
5. **Android.** Repetí el paso de pago con el dedo, verificá que la tilde y el control de pago queden a la vista. Si actualizás una instalación anterior del mismo paquete y firma, comprobá el guardado al primer arranque.

Podés usar Opciones → Modo de pruebas para saltar a un mapa u oleada al comprobar controles y rendimiento. Hacé las comprobaciones de desbloqueo y guardado en juego normal. Registrá plataforma, modelo de teléfono, build y nivel/oleada del problema.
