# M24 · Monstruos, identidad y evoluciones

Plan de diseño solicitado por Lucas, 2026-10-02. Este documento propone tandas; no reemplaza recursos del juego ni cambia su balance.

## Dirección artística

Fantasía estilizada con volumen aparente de 3D, compatible con las torres M23: cámara elevada, luz arriba a la izquierda, materiales definidos, sombras suaves y siluetas claras. Monstruos expresivos y amenazantes, sin depender de detalles diminutos para reconocerlos. Comprobar siempre al tamaño real del juego y sobre sus distintos fondos.

Los enemigos actuales son 13: Normal, Rápido, Tanque, Blindado, Volador, Jefe, Troll, Araña, Cría, Guardián, Curandero, Chamán y Espejo. Se pueden cambiar especies y nombres visuales conservando inicialmente IDs, capacidades y estadísticas. Un enemigo con mecánica nueva requiere una tanda de diseño y balance propia.

## Tanda 1 · Elegir el lenguaje visual

Producir muestras del Normal, Rápido y Tanque, para comprobar cuerpos pequeño, ágil y pesado. Propuesta: diablillo cornudo, bestia reptiliana y ogro pétreo. Dos variantes por criatura dentro del mismo estilo, comparadas junto a las torres y a escala real. No producir todavía todas las animaciones.

Preparar además una vista del menú con el logo 3D existente `art/prototypes/branding/monsters_canons_logo_3d.png`, usando el nombre aprobado **Monsters & Canons**. Revisar el archivo antes de preparar su versión de producción. Sustituir los rótulos JuegoA y Tower Defense; mantener controles legibles y espacio para los botones.

Muestra adicional: Cañón e Hielo en niveles 1, 2 y 3. Reutilizar sus ocho vistas; variar piezas y acentos de color, con brillo localizado. Comparación lado a lado que permita identificar el nivel incluso sin leer el número.

Entrega: hoja de propuestas, prueba sobre el mapa y composición del menú. La selección de Lucas define el resto de la producción.

## Tanda 2 · Primer grupo integrado

Integrar las tres criaturas elegidas y el logo. Preparar vistas que conserven la luz al cambiar de rumbo; probar cuatro direcciones antes de decidir si hacen falta ocho. Añadir un ciclo corto de caminar, reacción al daño y desaparición compatible con los efectos existentes. Conservar lectura de quemadura, ralentización, armadura, corona y barra de vida. Actualizar también Wiki e iconos de próxima oleada.

Entregar captura de combate y ejecutable de pruebas. Comprobar que la escala y el contacto con el suelo no alteren colisiones, ruta o selección. Ejecutar los tests correspondientes y revisar importación desde una copia limpia.

## Tanda 3 · Completar el bestiario

Dividir los diez restantes en grupos revisables:

- Blindado, Troll, Volador, Araña y Cría: escarabajo acorazado, troll regenerativo, gárgola y familia arácnida.
- Guardián, Curandero, Chamán, Espejo y Jefe: golem protector, criatura de hongos sanadora, hechicero monstruoso, criatura de cristal reflectante y gran demonio de asedio.

Son propuestas de identidad; las habilidades actuales siguen determinando su lectura. Usar placas, alas, bastón, cristal y tamaño como señales, además del color. Validar cada grupo en juego antes de producir el siguiente. Reservar para después posibles enemigos nuevos, con función distinta y sin duplicar roles.

## Tanda 4 · Evoluciones de las nueve torres

Tras elegir la muestra de Cañón e Hielo, extender el tratamiento a Básica, Francotirador, Incendiaria, Múltiple, Ráfaga, Eléctrica y Mortero.

- Nivel 1: acabado actual y pocos acentos.
- Nivel 2: refuerzos visibles, bandas de metal y luces discretas.
- Nivel 3: piezas más marcadas y brillo en elementos funcionales, conservando silueta y familia.

Aplicar variantes al mecanismo además de la base: actualmente cambia la base y los indicadores, pero el mecanismo comparte el mismo atlas. Mantener luz fija, contraste, ocho direcciones, retroceso y estados de aturdimiento. Evitar teñir todo el sprite o introducir halos que tapen enemigos y proyectiles.

## Revisión posterior

Con personajes y torres consolidados, revisar caminos, terreno, rocas, árboles y portales; después marcos y paneles. Su detalle y contraste deben quedar por debajo del de las unidades. Cada tanda termina con fuentes conservadas, recursos de producción separados, capturas reales y una lista explícita de lo que falta revisar.
