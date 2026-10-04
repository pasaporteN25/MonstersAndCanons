# M25 · Locomoción y segunda tanda de criaturas

Pedido por Lucas: continuar los nuevos assets y preparar animaciones de los tres diseños seleccionados. Trabajo artístico separado de la integración de Claude en M24.

## Entregado

- Tres atlas RGBA de 1024×1024: Normal rojo, Rápido turquesa y Tanque de piedra verde. Cuatro direcciones por cuatro cuadros de desplazamiento: **48 cuadros**.
- Cuadros de 256×256, pies en (128,191), cuerpo máximo al 63,3 % de alto. Compatible con `art/FORMATO_PROXIMA_ENTREGA_M24.md`.
- `manifest.json`: filas, pivote y duraciones iniciales por criatura.
- `walks_preview.gif`: pasos en bucle a ritmo común para comparar.
- `walks_godot.png`: captura del visor real de Godot. `preview_walks.tscn` reproduce con los tiempos individuales sugeridos.
- `physical_monsters.png`: propuestas de Blindado/escarabajo, Troll, Volador/gárgola, Araña y Cría.
- `HANDOFF_CLAUDE.md`: guía de integración, escala, direcciones, pausa, estados e iconos.
- `sources/` y `prompts.json`: originales y prompts de la herramienta integrada image_gen. Fuentes aprobadas de M24 intactas.

## Preparación y comprobación

Las hojas generadas contienen las 16 figuras, pero no una cuadrícula exacta. `pack_walks.gd` separa figuras conectadas por alfa, exige 16, ordena cuatro filas por cuatro columnas y empaqueta con una escala común. Conserva bordes suaves junto al cuerpo y descarta motas aisladas; no regenera o recolorea figuras.

Se revisaron fuentes, regiones, márgenes y reproducción en Godot. No se arrastran fragmentos de filas vecinas. Los 48 cuadros tienen contenido y los cuatro cuadros de cada fila son diferentes. Hay pequeñas variaciones de detalle y amplitud entre poses; queda comprobarlas en una ruta real al integrar.

Para reproducir, con APPDATA aislado:

```powershell
godot --headless --path . -s art/redesign-m25/pack_walks.gd
python art/redesign-m25/make_previews.py
godot --path . art/redesign-m25/preview_walks.tscn -- --capture
```

Sin `--capture`, el visor sigue abierto. `sources/` y `atlases/` tienen `.gdignore`: copiar los atlas a `assets/` antes de cargarlos como recursos de producción. El visor los lee directamente como Image.

Validación: **872/872 tests**, 6726 asserts, sin SCRIPT ERROR ni Parse Error; empaquetador y visor ejecutados con salida 0. Persisten avisos previos del motor de certificados y dos objetos/un recurso al cerrar. No se ocultan ni se atribuyen a una animación sin evidencia.

## Límites y siguientes tandas

Esta tanda entrega el desplazamiento inicial de los tres elegidos y muestras de cinco monstruos físicos. No modificó escenas, datos ni código de producción, ni la integración de Claude. No se exportó otro ejecutable: falta conectar las animaciones al Enemy real.

Daño, fuego, frío y desaparición siguen siendo efectos del juego; no se entregan ciclos independientes de ataque, golpe o muerte. El reposo puede sostener un cuadro de la dirección actual. **Los cinco conceptos fueron aprobados por Lucas el 2026-10-02.** Sus copias enmarcadas se entregan en `art/redesign-m26/monsters/`; siguen pendientes animación e integración.

Quedan para próximas tandas Guardián, Curandero, Chamán, Espejo y Jefe, y los atlas de evoluciones de las torres. Bestia violeta y Tanque volcánico quedan reservados; Diablillo A descartado.
