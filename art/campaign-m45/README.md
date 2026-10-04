# M45 · Bastión y Taller asediado

T192 integra niveles8/9 en campaña. No se generaron EXE/APK. Las estadísticas globales y los archivos1–7 se conservan.

## Diseño

| Nivel | Mapa | Oro/vidas | Oleadas | Vida extra por oleada |
|---|---|---|---|---|
|8 · Bastión|20×9, entradaA,58 casillas|300/20|18|32%|
|9 · Taller asediado|20×9, entradasA/B,56/47 casillas|320/20|20|40%|

8 introduce Guardián en4, Ladrón opcional en6, Embestidor en8. Luego combina protección/embestidas y robo; el cierre aumenta grupos sin modificar stats de enemigos.9 presenta Guardián en3 y Curandero en5; Ladrón en6 y Embestidor en8, separados antes de combinar auras y prioridades. Cada oleada admite como máximo un Ladrón opcional: probabilidades0,4–0,5 en8 y0,45–0,55 en9. Piso10, drenaje3/2s, carga y reparación existentes. No agrega fuentes tecnológicas: Mecánico requiere las cinco de1–5 más permiso de8/9; admin lo habilita para probar.

Las rectas tienen posiciones construibles al final y espacio para colocar una fuente de reparación distinta. Exposición forzada sobre caminoA: ambos mapas reciben20 de desgaste y lo reparan en10/6,7/5s según nivel del apoyo. Los tests inspeccionan todas las entradas usadas por Embestidores, incluidaB de9. Esto verifica geometría; no prueba por sí solo dificultad ni frecuencia natural.

Un guardado anterior que ganó7 puede abrir8 por victoria previa, incluso sin entrada unlocked para un nivel que antes no existía. Consultar acceso no reescribe el guardado, y9 sigue cerrado hasta ganar8. Récords y colección se preservan.

## Laboratorio

Se fijan RNG global/spawner, física60Hz y APPDATA por proceso. Bot base mix mantiene orden de compras y colocación. Se mantienen tres controles M44: baseline (sin mejoras/apoyo), upgrades (mejoras de cobertura terrestre) y upgrade_support (apoyo después de12 torres, por cantidad de aliadas, mejoras del apoyo desde10).

También se ensaya late_damage: compra apoyo después de12 torres por suma de daño nominal, sin mejoras ofensivas ni del apoyo.

Dos perfiles nuevos del laboratorio añaden cobertura aérea al puntaje de mejora para torres capaces de disparar a voladores: adaptive_upgrades y adaptive_upgrade_late_value. El segundo compra apoyo después de12 torres solo si la suma de daño×cadencia aliada dentro de radio2 alcanza120. Ese umbral es una hipótesis del bot, no un requisito del juego. Se conserva la limitación del daño nominal: no representa área/quemadura/ráfaga, y tampoco decide como una persona ni optimiza futuras oleadas.

La versión inicial con22% terminaba ambos niveles con20 vidas en los tres controles. El ensayo40% mostró presión real: en8 se volvió excesivo para el perfil de apoyo, por eso se ajusta8 a32%;9 mantiene40%. iterations.json conserva las exploraciones con sus escalas; results.json corresponde únicamente a los datos finales. No interpretar las diferencias como efecto puro del Mecánico: cambian compras, daño y orden temporal.

## Encuentro oficial de desgaste y reparación

encounter.tscn inicia la oleada8 oficial con semilla42, una Ametralladora nivel1 en posición expuesta y un Mecánico nivel1 en otra celda legal dentro de radio. No fuerza carga, desgaste, daño, posición de enemigos ni reparación: el spawner y la física normales producen dos impactos,40 puntos recibidos y40 reparados. Después de30 segundos la torre tiene desgaste0 en ambos mapas.8 conserva20 vidas al corte y9 queda en4: es una defensa mínima para comprobar el sistema, no una estrategia ganadora ni una partida completa. En9 se usa entradaB, complementando exposiciónA.

En los bots completos, comprar el apoyo por daño agrupado puede situarlo lejos de los extremos expuestos. Eso no demuestra que falte reparación: su posición debe cubrir la torre realmente amenazada. Las capturas y este encuentro separan geometría/funcionamiento de efectividad de estrategia.

## Reproducción

```powershell
python art/campaign-m45/run.py screen
python art/campaign-m45/run.py validate
python art/campaign-m45/run.py repeat
$env:APPDATA=Join-Path (Get-Location) 'build/t192/exposure-user'
godot --headless --path . art/campaign-m45/exposure.tscn
godot --headless --path . --fixed-fps 60 --quit-after 4500 art/campaign-m45/encounter.tscn
```

Runner usa C:/Tools/Godot/godot.cmd, dos procesos y JSON incremental. No ejecutar fases de escritura simultáneas; retirar/archivar results.json para repetir o si cambian los datos. El protocolo de salida conserva M44_RESULT. Los logs quedan en build/t192. No es benchmark de FPS.

Capturas level_08.png/level_09.png obtenidas con capture.tscn en Godot a1920×1080; revisadas visualmente. Son escenas de integración con posiciones legales/enemigos congelados y apoyo habilitado en admin, no partidas humanas. Muestran HUD, disponibilidad, camino y siluetas juntas. No regeneran arte.

## Validación

La suite comprueba progresión antigua/nueva, permiso+colección, ausencia de avances posteriores, debuts y preparación, límite de Ladrón, geometría de todas las entradas, carga de archivos/campaña y texto canónico del editor. ## Resultados finales

24 corridas sobre la configuración final, tres semillas42/7/12345 y seis perfiles (todos con42; baseline/adaptive_upgrades/late_damage en las tres). Repetición independiente de9/baseline/42: diccionario completo idéntico al control, incluidas compras, oro, robos e impactos (repeat.json).

| Perfil | Vidas8, semilla42 | Vidas9, semilla42 |
|---|---:|---:|
|baseline|20|11|
|upgrades|20|0|
|upgrade_support|20|0|
|adaptive_upgrades|20|3|
|adaptive_upgrade_late_value|20|3|
|late_damage|18|8|

Cero indica derrota. El perfil con umbral120 no compra Mecánico en42 en ninguno de los dos mapas: su resultado es un control sin apoyo, no evidencia de su aporte.

| Perfil validado | Vidas8 en42/7/12345 | Vidas9 en42/7/12345 |
|---|---|---|
|baseline|20/20/20|11/11/11|
|adaptive_upgrades|20/20/20|3/0/3|
|late_damage|18/16/18|8/8/8|

8 conserva un margen amplio en estos bots; la compra tardía sin mejoras gana16–18 vidas y el control variado20.9 es más exigente: la defensa variada sin mejoras gana11 en las tres semillas y la compra tardía por daño gana8. La política de mejoras, incluso con cobertura aérea, puede perder: cobertura×daño/costo no optimiza auras, regeneración, gasto futuro ni momento de compras. No concluir que mejorar torres sea malo ni que toda estrategia de apoyo deba ganar.

En8, baseline registra un impacto en las tres semillas. En9, baseline registra cuatro y late_damage cinco. Los bots que compran apoyo por daño no reparan esos impactos: su grupo elegido queda lejos de torres expuestas. El encuentro oficial antes descrito demuestra reparación natural40→0 cuando se elige la ubicación correspondiente. No convertir el apoyo en compra obligatoria para salvar una política del bot.

La frecuencia opcional produce variación de robos, registrada en results.json; los encuentros reforzados M44 no se trasladaron automáticamente. Se eligieron32%/40% locales como primera calibración, conservando preparación, números globales y1–7. Hace falta jugar para revisar claridad de avisos, tiempo de reacción, agrupación/ubicación del Mecánico y dificultad percibida.

Suite954/954,8939 asserts,75 scripts; tras ajustar solo escala8 a32%,62/62 pruebas de contenido/campaña/editor/geometría (1241 asserts). Importación, dos recorridosA/B del9 y A del8 válidos sin avisos de ambigüedad; dos escenas de exposición, dos encuentros oficiales y dos capturas revisadas. Sin SCRIPT ERROR/Parse Error en la evidencia final. Persisten avisos conocidos de certificados/limpieza de Godot. Se verificaron hashes idénticos de los archivos1–7 y de los cuatro paquetesT191; no exportaciones ni prueba física Android/Linux.


Queda pendiente jugar para evaluar comprensión, sensación de presión, respuesta al robo/desgaste y balance humano. No se crearon niveles10–15 ni se seleccionaron Ballesta/Alquimista/Excavador. B22 sigue abierto. Los paquetes existentes conservan T191 y se regenerarán más adelante por instrucción de Lucas.
