# M39–M41 · Ladrón, Embestidor, desgaste y reparación

Etapas T184–T186 de B07/B22 autorizadas por Lucas, más el contador de avances de T187. Todo en feature/avances-estandarte, separado de PR1. Colección y permisos se conservan; los niveles 1–5 mantienen sus oleadas y cifras.

- Ladrón: 3 monedas cada 2 segundos, piso 10, vuelve a drenar con ingresos posteriores; muerte/salida/fin cortan. Nivel 6 oleada 9 al 25%; nivel 7 oleadas 7/12/17 al 35%, máximo uno por oleada opcional. Editor guarda probabilidad y HUD identifica encuentros opcionales.
- Embestidor: después de 3 casillas rectas acelera ×1.8. En cada extremo alcanza solo una torre cuyo centro esté a ≤1.25 casillas. Ralentización mayor al 20% interrumpe la carga. Nivel 6 oleada 10; nivel 7 oleadas 9/14/18. Reutiliza Bestia B reservada, como pose inicial.
- Desgaste: +20 puntos por impacto, máximo 50%; reduce cadencia y prestaciones de apoyos. No destruye; mejora mantiene desgaste y stun es independiente. Marca ámbar en base y valor en panel.
- Mecánico: repara 2/3/4 puntos por segundo; mayor tasa activa en radio, sin autorreparación ni acumulación. Otro Mecánico sí lo repara. Aturdimiento/venta del reparador corta efecto; reparar no despierta la torre. Ícono de herramienta cian cuando hay reparación efectiva. Costos 120/100/160 y rangos 2/2.5/3 conservados.

## Evidencia

[Desgaste y reparación](desgaste_reparacion.png), [panel del Mecánico](panel_mecanico.png) y [probabilidad en editor](editor_probabilidad.png) son capturas reales de instancias aisladas. Posiciones de muestra: no representan una partida ganada. Arte del Ladrón y símbolos nativos vectoriales iniciales, pendientes de revisión visual de Lucas; no se declaran diseños definitivos.

943/943 pruebas GUT, 8459 asserts, 74 scripts; sin SCRIPT ERROR ni Parse Error. Incluyen piso e ingresos, muerte/desaparición/escape, sorteo/cupo por oleada, editor/undo/validación, geometría/proximidad, impactos/reparación sobre caminos reales 6/7, topes/upgrade/stun/venta, pausa y velocidad reales, Wiki/panel y contador persistente/pendiente/confirmado. Los últimos cambios de ayuda/editor también pasaron 35 pruebas de UI, oleadas y contenido. Niveles 6/7 validan con check_level.

Rendimiento RX6900XT: 200 enemigos, 60 torres con seis Mecánicos, todas inicialmente desgastadas; 10 Ladrones y 10 Embestidores con relojes/carga activos. 103 FPS promedio, peor cuadro 30.3ms, 17/617 cuadros sobre 16.6ms. Las marcas geométricas iniciales bajaban a 43–56 FPS; reemplazarlas por texturas de iconos compartidas y evitar diccionarios por receptor corrigió el costo. La carga normal sin desgaste rindió 114 FPS. No es garantía móvil.

Windows normal y pruebas y Linux exportados con la corrección final. Ambos Windows arrancan en modo headless y terminan con código 0. No se ejecutaron Linux ni Android. Aviso previo de certificados y algunos avisos de recursos al cerrar herramientas persisten. Pruebas/capturas/bot usan APPDATA aislado build/t180-user; cambios Android locales M34 se preservan fuera de estos commits.

## Balance inicial y límites

[Resultados](balance_results.json): bot mix, solo torres nivel 1, semillas 12345/42/7, con/sin compra temprana de un Mecánico tras cuatro cañones. Nivel 6 sin apoyo gana siempre con 10 vidas; con compra temprana pierde en oleada 12/15. Nivel 7 sin apoyo gana con 16 vidas; con apoyo gana con 15/15/13. Robo observado 0–18 monedas por partida. Ladrones efectivamente ausentes/presentes según semilla; Embestidores presentes 1/3 en niveles 6/7.

El bot mata a los Embestidores antes de impactar: sus partidas registran cero desgaste/reparación. Por eso las reglas de impacto y recuperación se verifican además en escenarios controlados sobre los caminos oficiales 6/7 y en las pruebas de estrés. No presentar este laboratorio como balance definitivo, ni como prueba de que conviene comprar el Mecánico temprano. Faltan estrategias con mejoras, colocación y juego humano. No se rebalancean 1–5.

## Reproducir

Con APPDATA apuntando a build/t180-user, desde la raíz:

```powershell
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
godot --path . res://art/mechanics-m41/capture.tscn
godot --path . -s art/mechanics-m41/performance.gd -- apoyo
godot --headless --fixed-fps 60 -s art/mechanics-m41/balance.gd -- mix level=7 support=1 seed=42
```

El laboratorio también admite level=6, support=0 y otras semillas. performance admite sin_desgaste/sin_especiales para aislar costos. Los scripts de tools/balance se compilan antes de autoloads: sus señales usan Node2D, sin referencias estáticas a Enemy/Tower/Game que arrastren SaveManager.

## Pendiente

Balance y arte definitivos, crear niveles 8/9 con mayor presencia y 10–14 con combinaciones, final 15. B22 sigue abierto por estos ajustes y candidatos no seleccionados (Ballesta/Alquimista/Excavador); B21/B23 conservan sus estudios preliminares. Vida/destrucción/reconstrucción y reparación pagada con economía/UI nueva quedan como alternativa futura D067, no implementada.
