# M43 · B31 aprobado por Lucas

Embestidor: anatomía robusta del Curandero anterior, sin bulbo, con armadura de hierro/bronce, cuernos y frente reforzada. Curandero: silueta erguida vegetal con semilla medicinal y hierbas. Ladrón: capucha, gesto furtivo y bolsa de monedas. Mecánico: casco, engranaje y herramientas renderizados sobre las mismas bases de los cañones. Arte producido con generador integrado image_gen; [prompts normalizados](prompts.md), [fuentes originales](sources/), [manifest](manifest.json) y [empaquetador Godot](pack.gd) conservados.

## Verlos
[Vista animada de los atlas integrados](preview.html), [direcciones y lectura a112/34px](direcciones.png), [mapa con carga y reparación](partida.png), [Wiki Curandero](wiki_curandero.png) y [Wiki Mecánico](wiki_mecanico.png). La vista HTML permite elegir dirección; su reloj es de exposición, en partida el ritmo sigue distancia/pausa/hielo/carga. Las capturas instancian Enemy/Tower/Wiki de producción y colocan las figuras para exposición: no representan una estrategia jugada. Los PNG motion_* son regenerables y no se versionan.

## Integración
Enemigos: estáticas256×256, atlas1024×1024 (cuatro direcciones × cuatro fases), misma escala para todas las poses de cada especie, pies a191, mipmaps y alfa. Mecánico128×128, sin base ni sombra incrustada. Archivos *_m43 en assets/sprites/enemies/rendered y assets/sprites/towers/rendered; versiones anteriores conservadas. Solo cambiaron referencias y parámetros visuales; comparación de los cuatro .tres contra HEAD anterior confirmó todas las estadísticas y habilidades intactas.

## Verificación
948/948 GUT,8693 asserts, sin SCRIPT ERROR/Parse Error. Pruebas existentes de sprites/ciclos ahora incluyen Embestidor y Ladrón;16 poses diferentes por especie, márgenes/transparencia/anclaje, regiones por distancia/dirección, hielo y pausa. Windows (pruebas) reexportado y arranque headless exit0 con15 enemigos.

Carga de200 enemigos,60 torres con desgaste y efectos:114FPS promedio en este equipo,25.2ms peor cuadro,7/686 cuadros mayores a16.6ms; no es garantía móvil. Simulaciones mix nivel6 y7, semilla42, compra temprana de Mecánico: resultados idénticos aM41 ([JSON](balance_results.json)). Nivel6 pierde en oleada12/15; nivel7 gana con15 vidas;18 monedas robadas en ambos. El bot elimina los Embestidores antes del impacto, por lo que no demuestra balance de desgaste; las pruebas controladas existentes sí verifican impacto/reparación. La compra temprana de Mecánico en6 sigue siendo una estrategia desfavorable, pendiente de estudiar mejoras/colocación y juego humano.

## Reproducir
Desde la raíz, APPDATA aislado como en ONBOARDING:
```
godot --headless --path . -s art/redesign-m43/pack.gd
godot --headless --import
godot --path . res://art/redesign-m43/capture.tscn
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
godot --headless --fixed-fps 60 -s art/mechanics-m41/balance.gd -- mix level=6 support=1 seed=42
godot --headless --fixed-fps 60 -s art/mechanics-m41/balance.gd -- mix level=7 support=1 seed=42
godot --path . -s art/mechanics-m41/performance.gd
```
La captura usa user://test_m43_capture.json. Generadores por conectividad alfa separan16 figuras, normalizan encuadre sin pintar/modificar diseño y rechazan conteo/poses repetidas; originales intactos.

## Límites y siguiente paso
B31 cerrado: Lucas aprobó visualmente los cuatro diseños el 2026-10-04. No se declara modelado3D real: son hojas generadas con posible deriva sutil entre fases, revisadas en las cuatro vistas. No hay ciclo específico de ataque: carga usa marcha acelerada y trazos existentes, con cabeza ya baja. T190 generó ambos EXE y APK; se verificaron arranque Windows, integridad/firma/paquetes APK. No se ejecutaron Linux/Android físico ni sesión humana completa; avisos conocidos de certificados y limpieza de Godot persisten en herramientas/bot. Después de revisión visual, afinar estrategias de6/7 antes de definir8/9;1–5 intactos.
