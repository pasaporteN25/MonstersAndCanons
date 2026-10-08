# M44 · Laboratorio de balance 6/7

T191. Comparación de estrategias sobre los niveles oficiales, sin editar datos de campaña. Los resultados reproducibles están en `results.json`; `exposure.json` conserva el escenario geométrico de impacto y reparación. No es un balance definitivo ni un bot óptimo.

## Método

Godot 4.7.2, física fija de 60 Hz. Se fija tanto el RNG del spawner como el global antes de instanciar Game (D047). Cada proceso usa APPDATA aislado en build/t191. Repetición independiente del perfil upgrade_late_value, nivel7/semilla42: diccionario completo idéntico al control (repeat.json), incluyendo compras/oleadas/robos. Las primeras exploraciones que no fijaban el RNG global fueron descartadas; están archivadas localmente en build/t191/unseeded-results.json, fuera de la evidencia final.

Se mantiene el orden mix y la colocación por cobertura del bot existente. El apoyo se habilita en memoria para estudiar su utilidad; la progresión real y sus cinco avances no se modifican. El bot compra durante las oleadas; las mejoras son entre oleadas, como máximo una por oleada después de seis torres ofensivas. Prioriza cobertura terrestre × incremento de daño nominal por segundo / costo. No modela óptimamente aire, área, quemadura, ráfagas ni multiblanco; sus conclusiones dependen de esa heurística.

| Perfil | Política del Mecánico | Mejoras |
|---|---|---|
| baseline | Ninguno | Ninguna |
| early | Después de cuatro torres, máxima cantidad de aliadas dentro de radio2 | Ninguna |
| late_count | Después de doce torres, máxima cantidad de aliadas | Ninguna |
| late_damage | Después de doce torres, máximo daño nominal aliado | Ninguna |
| upgrades | Ninguno | Ofensivas |
| upgrade_late_value | Después de doce torres y daño nominal aliado ≥120; máxima suma | Ofensivas |
| upgrade_support | Después de doce torres, máxima cantidad de aliadas | Ofensivas; prioriza mejorar apoyo desde oleada10 |

El umbral120 es una hipótesis del laboratorio, no un requisito de construcción ni una recomendación demostrada. `nominal_dps` es daño × cadencia, no el daño real total. El contador `built` incluye únicamente torres ofensivas.

Presión `normal`: recursos oficiales. `none`: elimina grupos de Ladrón/Embestidor en memoria (también cambia recompensas e intervalos de oleada; no aísla daño sin confusores). `double`: duplica cantidad de Embestidores y fija probabilidad del Ladrón en0,7; esto multiplica la probabilidad por2,8 en6 y por2 en7, no duplica exactamente toda la presión. Conserva el límite de un Ladrón por grupo.

## Reproducción

Desde la raíz, con Python y Godot disponibles:

```powershell
python art/balance-m44/run.py screen
python art/balance-m44/run.py validate
python art/balance-m44/run.py pressure
python art/balance-m44/run.py repeat
$env:APPDATA=Join-Path (Get-Location) 'build/t191/exposure-user'
godot --headless --path . art/balance-m44/exposure.tscn
```

El runner usa C:/Tools/Godot/godot.cmd, dos procesos y resultados incrementales. No ejecutar fases simultáneamente: escriben el mismo JSON. Reutiliza casos existentes con global_seed; para repetir todo conservar el JSON anterior y retirar results.json. No mide FPS.

## Exposición y reparación

Se inspeccionó el camino terrestre A de cada mapa, entrada usada por los grupos actuales. Nivel6 tiene cuatro rectas de al menos tres casillas y seis celdas construibles amenazadas al final; nivel7 tiene dos rectas y cuatro celdas. El escenario controlado fuerza un Embestidor ya cargado a cruzar el extremo con una torre legal próxima: recibe20 puntos de desgaste. Un Mecánico próximo tarda10,0 /6,7 /5,0 segundos en repararlos a nivel1/2/3. Esto demuestra conexión y geometría, no frecuencia de impactos en una partida natural.

Este escenario detectó un residuo de coma flotante que mantenía el estado reparando al llegar casi a cero. RF377 normaliza el cero y permite emitir la transición terminal. Prueba de regresión: pasos0,1s y residuo pequeño; suite949/949.

## Resultados y límites

Comparación con semilla42 (vidas finales; cero significa derrota):

| Perfil | Nivel6 | Nivel7 |
|---|---:|---:|
| Sin apoyo ni mejoras |10|16|
| Apoyo temprano |0, derrota en oleada12/15|15|
| Apoyo tardío por cantidad |8|16|
| Apoyo tardío por daño nominal |3|16|
| Mejoras ofensivas sin apoyo |20|7|
| Mejoras ofensivas + apoyo con umbral nominal |20, no llega a comprar apoyo|12|
| Mejoras ofensivas + apoyo por cantidad y mejoras del apoyo |20|18|

Validación adicional con semillas7 y12345: los tres perfiles con mejoras terminan nivel6 con20 vidas; upgrade_late_value no compra apoyo en6. En7, sin apoyo termina con10/7 vidas, con apoyo por umbral11/12 y con apoyo por cantidad más mejoras19/18. Junto al control42, este último es el mejor de los perfiles con mejoras ensayados en7 (18–19 vidas), sin generalizar a otras estrategias.

La compra temprana desvía120 monedas antes de que el grupo de torres aproveche el aura. El resultado de nivel6 no justifica abaratar el Mecánico: una estrategia con mejoras ya conserva20 vidas. En7, la estrategia con apoyo tardío y mejoras del propio apoyo conserva18 frente a7 del perfil de mejoras sin apoyo, pero no demuestra que cada mejora del apoyo sea óptima ni que el bot elija bien sus mejoras ofensivas. Cambia la distribución del gasto y el grupo protegido. El control básico sin mejoras obtiene16.

Los niveles1–5 no se modifican. La siguiente etapa es diseñar8/9; la progresión10–14 y el final15 siguen fuera de esta medición.

## Frecuencia de especiales

Semilla42, vidas finales; variantes solo en memoria:

| Nivel/perfil | Sin especiales | Frecuencia oficial | Reforzada | Impactos/reparación reforzada |
|---|---:|---:|---:|---|
|6/upgrades|20|20|20|0 impactos, 0.0 puntos reparados|
|6/upgrade_late_value|20|20|20|0 impactos, 0.0 puntos reparados|
|6/upgrade_support|20|20|20|0 impactos, 0.0 puntos reparados|
|7/upgrades|14|7|15|2 impactos, 0.0 puntos reparados|
|7/upgrade_late_value|6|12|9|1 impactos, 20.0 puntos reparados|
|7/upgrade_support|19|18|18|2 impactos, 20.0 puntos reparados|

En frecuencia oficial, los perfiles medidos no registran impactos: los Embestidores mueren antes de alcanzar una torre expuesta. Con frecuencia reforzada, los tres perfiles con mejoras de nivel7 sí sufren impactos. El perfil por umbral repara20 puntos, y el de apoyo por cantidad repara los puntos consignados en la tabla; el perfil sin apoyo conserva desgaste. Existe reparación natural además del escenario forzado, pero solo en esta variante.

Las vidas no varían monótonamente con la frecuencia: más enemigos aportan oro y cambian compras, prioridades y tiempos. Por ejemplo, upgrades en7 mejora de7 a15 vidas al reforzar, aunque recibe dos impactos y más robo. Estos ensayos no justifican incrementar frecuencia por sí solos ni atribuir diferencias exclusivamente a robo/desgaste. Las combinaciones reforzadas se validaron solo con semilla42.

## Decisión T191

Conservar costos, aura, reparación y frecuencia oficiales6/7. La evidencia confirma que el momento y el grupo de torres importan, que el apoyo puede ser útil en7, y que comprarlo temprano con pocas torres básicas puede perjudicar6. No hay fundamento suficiente para abaratarlo ni aumentar especiales como ajuste universal. Los niveles1–5 quedan intactos.

38 corridas con RNG global/spawner fijados, más una repetición idéntica del control, y dos escenarios físicos de exposición. Suite949/949 (8698 asserts,74 scripts), sin SCRIPT ERROR/Parse Error. Persisten avisos conocidos de certificados y limpieza de Godot. EXE normal/pruebas arrancan0; APK debug arm64 Android7+ conservan paquetes y firma v2/v3 válida, y feature pruebas solo en la variante correspondiente. SHA256/tamaños/logs locales en build/t191. No hubo sesión humana de balance ni ejecución en dispositivo Android; B22 sigue abierto para balance avanzado y otros candidatos.

## Criterios para8/9

- Conservar6/7 como introducción. No convertir el Mecánico en compra temprana obligatoria ni ajustar costos solo para salvar una heurística deficiente.
- Dar margen para construir un grupo ofensivo y mejorar antes de comprar apoyo; enseñar su valor cerca de varias torres útiles. Priorizar posición/cobertura antes de mejorar el apoyo de forma automática.
- Diseñar rectas con extremos que tengan celdas construibles próximas. El Embestidor amenaza esas posiciones cuando sobrevive; las torres alejadas del camino siguen seguras. Si todos mueren antes del extremo, aumentar cantidades no garantiza desgaste.
- Introducir encuentros separados antes de combinar Ladrón y Embestidor. El robo debe ser visible y permitir respuesta; preservar piso10 y desaparición al matar/escapar. El ensayo de probabilidad0,7 no se adopta automáticamente.
- Nivel8: primera situación visible de defensa expuesta y recuperación con apoyo opcional. Nivel9: exigir decisiones de agrupación, reparación y prioridades con mayor presión. Los números y oleadas concretos requieren diseño y prueba aparte.
- Probar jugando con avances obtenidos y con habilitación admin. Verificar que se entienda carga, robo y reparación, y registrar si el jugador tiene tiempo/dinero para reaccionar. Los bots no reemplazan esa prueba.
