# M23 · Producción visual de torres

Referencias aprobadas por Lucas: [A](../prototypes/tower-concepts/A-fantasia.png), [B](../prototypes/tower-concepts/B-industrial.png), [C](../prototypes/tower-concepts/C-arcano.png).

## Distribución

| Familia | Torres | Materiales |
|---|---|---|
| A, artillería de fantasía | Cañón, mortero | Hierro oscuro, bronce, madera |
| B, máquinas industriales | Básica, francotirador, incendiaria, múltiple, ráfaga | Acero, blindaje y detalles ámbar |
| C, tecnología arcana | Hielo, eléctrica | Metal claro, bronce y cristal celeste/violeta |

Las fuentes de imagegen están en `sources/`. Cada mecanismo tiene ocho vistas en dos filas: E, SE, S, SO; O, NO, N, NE. Cámara elevada y luz arriba a la izquierda. La piedra se generó aparte para permanecer fija al apuntar.

## Reproducir los recursos

Desde la raíz del proyecto:

```powershell
godot --headless --path . -s tools/prepare_tower_sprites.gd
python tools/apply_rendered_art.py
godot --headless --path . --editor --import
python art/redesign-m23/make_contact_sheet.py
```

El recorte detecta las figuras completas por alfa, comprueba sus cantidades y mantiene la escala común en cada hoja. Los originales se conservan; el generador escribe únicamente los derivados de `assets/sprites/*/rendered/`. No reconstruir estos PNG con los generadores SVG de pruebas anteriores.

## Comprobación

- `conjunto_m23.png`: recursos que consume el juego, ampliados y a 64/34 px.
- `direcciones_m23.png`: todas las vistas con la misma base.
- `en_juego.png`: captura real de Godot con las nueve torres de nivel 1.
- `combate.png`: captura de partida tras mejorar las torres y comenzar una oleada.
- `efectos_en_juego.png`: comparación de impactos invocados en la escena real; esta fila de impactos es una muestra preparada, no cuatro disparos simultáneos de una partida.
- `capture_game.tscn`: genera las capturas con el motor gráfico. Ejecutar con datos de usuario aislados, nunca con el guardado habitual.

Las imágenes son sprites 2D renderizados. Ocho vistas implican pasos de 45 grados y pequeñas variaciones de detalles generados entre cuadros. La puntería lógica continúa siendo continua. No se cambiaron cifras de balance ni se reemplazaron enemigos o terreno.

## Próximos grupos a rediseñar

1. Suelo y caminos: textura sobria, contraste de recorrido y conexión con la piedra de las bases.
2. Rocas, árboles, portales y obstáculos: volumen y luz comunes; siluetas que nunca se confundan con torres.
3. Enemigos: conservar especies, proporciones, colores y lectura de estados, sumar el volumen de las torres; probarlos sobre los siete temas.
4. Paneles de mejora, Wiki y selector: marcos/materiales comunes, con prioridad para texto y botones legibles.

Estos grupos requieren sus propias muestras antes de aplicarse; la autorización de M23 produjo torres, bases, proyectiles y efectos.
