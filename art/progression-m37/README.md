# M37 · Colección y Estandarte mecánico

Primera etapa funcional T183, RF-358–361, D-064. Un avance por cada fuente oficial1–5; portador original seleccionado al azar, al morir entrega automáticamente la pieza. Completar su oleada confirma la pieza; victoria/derrota posterior la guarda. Abandonar/reintentar/cerrar antes del resultado descarta lo recogido. Fuentes repetidas no suman y fuentes ajenas no participan. Guardados anteriores conservan progreso y empiezan la colección vacía.

Desde6 se necesita permiso del nivel y5 fuentes. Admin F1→Habilitar estandartes agrega el catálogo de apoyo sin colección, incluso en otros niveles, solo en modo pruebas. Apoyo de cadencia10/15/20%, radio2/2,5/3, costos120/100/160; no dispara, no se apila y se desactiva aturdido. Mejora/venta recalculan apoyo; no quedan referencias a torres vendidas. Estatua fija e icono genérico plateado son diseño vectorial inicial revisable por Lucas, sin reemplazar atlas existentes. Reparación todavía no implementada.

## Muestras
- [Estatua y avance](estandarte.png)
- [Habilitación admin](admin.png)
- [Drop pendiente](avance_pendiente.png)
- [Oleada confirmada](avance_confirmado.png)

## Verificación y límites
918/918 GUT,8251 asserts,71 scripts; sin SCRIPT ERROR ni Parse Error. Pruebas de datos de colección, guardado viejo/malformado, abandono, checkpoint/derrota, fuentes oficiales/originales, construcción bloqueada, admin repetido, aura límite/no apilar/venta/aturdimiento/mejora y Wiki.106FPS promedio con200 enemigos/60 torres incluyendo seis estandartes;33,3ms peor cuadro y6/638 cuadros sobre16,6ms en RX6900XT. Medición local, no garantía móvil.

Windows normal/pruebas y Linux exportados. Ambos Windows arrancan con código0. No se ejecutó Linux ni Android. Aviso previo de certificados persiste; algunas corridas GUT/herramientas muestran avisos de recursos al cerrar. No se usó el guardado real para pruebas ni capturas.

[Comparación de combate6/7](balance_results.json): bot mix y semilla12345, solo cañones nivel1. Nivel6: sin apoyo gana con10 vidas; comprándolo temprano pierde en12/15. Nivel7: gana con16/13 vidas sin/con apoyo. El apoyo no es obligatorio y tiene costo/espacio; esos números requieren otra etapa de balance, estrategias con mejoras y colocación, varias semillas y juego humano. No se rebalanceó la campaña ni se agregaron amenazas a1–5. Se descartó una corrida inicial del laboratorio con error de inicialización.

## Reproducir
APPDATA aislado en build/t180-user. Desde la raíz:
- godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_progression_support.gd -gexit
- godot --path . res://art/progression-m37/capture.tscn
- godot --path . res://art/progression-m37/progress_capture.tscn
- godot --path . -s tools/perf_test.gd -- apoyo
- godot --headless --fixed-fps 60 -s art/progression-m37/balance_support.gd -- mix level=6 support=0 (nivel6/7, support0/1)

## Etapas posteriores (completadas en M39–M41)
T184 Ladrón periódico, T185 Embestidor/desgaste al final de rectas cerca del camino, T186 reparación del mecánico. Campaña objetivo1–15 con pruebas6/7, intensidad8/9 y combinaciones10–14/final15; solo1–7 existen. B-22 permanece abierto. Vida/destrucción/reconstrucción, reparación paga y economía/UI nueva son alternativas futuras, no parte de esta primera etapa.

Actualización: T184–T186 completos; ver ../mechanics-m41/README.md para pruebas, balance y capturas actuales. Los resultados de este archivo documentan la primera entrega M37, anterior al desgaste/reparación.
