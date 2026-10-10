# T252 · Dónde entra La Cuadrilla: medición con el bot en los niveles 6 a 14

> **Estado: MEDICIÓN HECHA, PROPUESTA A LA ESPERA DEL OK DE LUCAS.** Escrito el 2026-10-10 por Claude (Sonnet 5.5), tarea **T252** (📜). Es el respaldo de **M55** (`01-spec.md`, RF-485 a RF-491) y de **D-094**. **No se tocó ningún dato ni código del juego:** todo se midió en una **copia** del proyecto fuera del repositorio, con dos archivos `.tres` de prueba y niveles generados.
>
> **Pedido de Lucas (2026-10-10):** la opción A del informe de T251, *La Cuadrilla*, entra en la V1. Con el bot de `tools/balance_sim.gd`, medir **en qué niveles del 6 al 14** conviene que entre **sin romper la regla de oro** (RF-432: `sin_recursos` gana al menos 4 de 5), con una advertencia: **el 14 termina con 3 vidas y el 15 con 2**.

## 0. Resumen (para quien lea solo esto)

1. **Propuesta: La Cuadrilla entra en los niveles 7, 10, 13 y 14**, con **cuatro apariciones por nivel** (6 Rateros + 1 Cargador, 8 + 1, 8 + 1 y 10 + 2). **Debuta en el 7.** No entra en el 6, el 8, el 9, el 11, el 12 ni el 15.
2. **La regla de oro se cumple del 7 al 14** (gana 5 de 5 con las dos formas de armar la oleada que probé) **y se rompe en el 6** (pierde **5 de 5**, en la oleada 11 de 15). Pero «gana» no alcanza: lo que decide es **cuánto margen deja**, y ahí el 8, el 9, el 11 y el 12 quedan al borde en alguna de las dos formas (§3).
3. **El 14 se queda en 3 vidas con la Cuadrilla** (3, 3, 3, 3, 3 en las cinco semillas y en las dos formas), así que **el 15 sigue siendo el más difícil** (2 vidas). El 13 termina con 5 o 3.
4. **La Cuadrilla sí muerde, y mucho más que el Ladrón:** roba **326 a 807 de oro por partida** (el Ladrón solo: 21 a 66). Es lo que el informe de T251 dudaba («no tiene dientes»): con el bot, **sí los tiene**, y por eso en el 6 (poco oro, pocas torres) rompe el nivel.
5. **Una consecuencia que Lucas tiene que decidir: el mapa 7 está en Asedio** (RF-391, «mismas oleadas»). Con la Cuadrilla, el bot pierde Asedio 7 **en la oleada 11 de 20**; sin ella lo pierde en la 19 o 20 (ya lo perdía). Los mapas 10, 13 y 14 **no están** en Asedio.
6. **Lo que no se probó** (§6): una sola intensidad por nivel, solo la estrategia `sin_recursos` en la campaña, ninguna persona jugó nada, y el arte y los textos no existen todavía.

## 1. Qué se midió y cómo

**Los dos enemigos de prueba** (los números del informe de T251 §4.1, tal cual; solo para esta medición):

| ID | Vida | Velocidad | Armadura | Oro | Vidas | Robo | Tamaño |
|---|---|---|---|---|---|---|---|
| `ratero` | 14 | 2,2 | 0 | 5 | 1 | 2 de oro cada 2 s, piso 10 | 0,20 |
| `cargador` | 110 | 0,9 | 1 | 30 | 2 | 4 de oro cada 2 s, piso 10 | 0,33 |

Con `optional_wave_limit = 0` (sin tope de uno por oleada), sin habilidad nueva y con la textura del Rápido y del Tanque (en la prueba no importa el dibujo).

**Tres versiones de cada nivel del 6 al 14** (archivos generados a partir de `data/levels/level_NN.json`, jugados con `file=`):

| Versión | Qué es |
|---|---|
| **base** | El nivel como está hoy. **Reproduce, semilla por semilla, lo anotado** por T245 (6 a 9: 9 · 16 · 14/14/14/12/14 · 11), T225 (10: 9/9/13/7/9), T229 (11: 6 ×5) y T230 (12: 5/3/3/5/3); el 13 (6) y el 14 (3) coinciden con T231 y T232. |
| **S · «suma»** | Cuatro oleadas con la Cuadrilla **agregada encima** de lo que ya traían (el peor caso: más vida total). |
| **R · «reemplazo»** | Lo mismo, pero **sacando** de esas oleadas tanta vida de relleno (Normales, Rápidos, Voladores) como suma la Cuadrilla (222 de vida base en una aparición de 8 + 1), para que la vida total sea parecida. |

**Dónde va y cuánto trae** (igual en todos los niveles, para que se pueda comparar):

- **Cuatro apariciones**, a alrededor del **40, 55, 70 y 85 %** del nivel, siempre en oleadas **sin Guardián, Curandero, Chamán, Espejo ni jefe** y nunca antes de la oleada 3 ni en la última.
- **Composición:** 6 Rateros + 1 Cargador; 8 + 1; 8 + 1; 10 + 2. Los Rateros salen cada 0,4 s y los Cargadores cada 3 s, todos desde el segundo 0 de la oleada.
- **Oleadas elegidas** por esa regla:

| Nivel | Oleadas del nivel | Oleadas con la Cuadrilla |
|---|---|---|
| 6 | 15 | 6, 8, 11, 13 |
| 7 | 20 | 8, 11, 13, 16 |
| 8 | 18 | 8, 9, 14, 15 |
| 9 | 20 | 8, 12, 14, 16 |
| 10 | 20 | 8, 12, 14, 16 |
| 11 | 22 | 10, 13, 15, 18 |
| 12 | 24 | 10, 13, 15, 18 |
| 13 | 24 | 10, 13, 15, 18 |
| 14 | 26 | 10, 13, 15, 18 |

**El bot:** estrategia `sin_recursos` (la de la regla de oro), **semillas 1 a 5**, `--fixed-fps 60`, **135 partidas** (9 niveles × 3 versiones × 5 semillas). Ningún log tuvo `SCRIPT ERROR`. Se corrieron 8 a la vez en una máquina cargada.

**Un parche del bot, solo en la copia:** cuenta el oro robado (la señal `gold_stolen` de la sesión) y lo imprime en la línea final. Con eso se midieron 16 partidas más (niveles 7 a 14, versiones base y S, semilla 1). El código está en el apéndice.

## 2. Resultados: vidas con las que termina el bot

«V*n*» = victoria con *n* vidas; «D *w*/*t*» = derrota en la oleada *w* de *t*. Una columna por semilla (1 a 5).

| Nivel | **base** | **S · suma** | **R · reemplazo** |
|---|---|---|---|
| 6 | V9 V9 V9 V9 V9 | **D 11/15 ×5** | **D 11/15 ×5** |
| **7** | V16 V16 V16 V16 V16 | V5 V12 V12 V12 V12 | V7 V13 V13 V12 V13 |
| 8 | V14 V14 V14 V12 V14 | V14 V14 V14 V14 V14 | **V3 V1 V1 V3 V1** |
| 9 | V11 V11 V11 V11 V11 | V12 V8 V8 V9 V8 | **V2 V2 V2 V4 V2** |
| **10** | V9 V9 V13 V7 V9 | V7 V11 V7 V9 V11 | V7 V7 V7 V9 V7 |
| 11 | V6 V6 V6 V6 V6 | V2 V6 V6 V6 V6 | **V4 V2 V2 V2 V2** |
| 12 | V5 V3 V3 V5 V3 | **V2 V2 V2 V6 V2** | V4 V4 V4 V4 V4 |
| **13** | V6 V6 V6 V6 V6 | V5 V5 V5 V5 V5 | V3 V3 V3 V3 V3 |
| **14** | V3 V3 V3 V3 V3 | V3 V3 V3 V3 V3 | V3 V3 V3 V3 V3 |

*(En negrita, lo que no pasa el criterio de §3. Las filas en negrita del número son los niveles propuestos.)*

**Lecturas:**

- **El 6 se rompe.** Con la primera cuadrilla (oleada 6) el bot llega a la oleada 7 con **11 torres en lugar de 13** (semilla 1: 90 de oro al cerrar la 6 contra 129); esa oleada, que en la base no cuesta vidas, le cuesta **10**, y en la 11 se queda sin ninguna. Con **cualquiera** de las dos versiones. Es lo esperable del robo en un nivel con poco oro y pocas torres, pero **no se midió** qué parte de la caída es el robo y cuál la vida extra.
- **El 8 y el 9 pasan con la versión S pero no con la R.** Con la misma vida total (R), el bot **termina con 1 a 4 vidas**: el nivel se parece a un precipicio (en el 8 es la última oleada, con el Soberano; el bot llega a 1 vida). Que S pase y R no **parece una contradicción** (R tiene menos vida total) y **no se investigó por qué**; lo que se vio en una partida del 8 (semilla 2) es que con R el bot llegó a la última oleada con **63 torres contra 67** y perdió 14 vidas en ella contra 6. Sacar relleno saca también el oro que daba.
- **El 11 y el 12 quedan a 1 vida de empatar con el 15** (que termina con 2) en alguna versión. El 12 ya terminaba en 3 a 5 (baja con S a 2). El 11 baja a 2 con S en una semilla y con R en cuatro.
- **El 14 no se mueve.** Las cuatro apariciones caen en oleadas donde el bot todavía no pierde vidas; **lo que cuesta vidas en el 14 son las oleadas del final** (T232), y esas no cambian. Aun así la Cuadrilla le **roba 528 de oro** (contra 66 del Ladrón).
- **Una advertencia sobre el ruido.** El bot juega casi igual con cada semilla en estos mapas (T229 a T234), así que **«5 de 5» es en la práctica una medida**, no cinco. Y el final de cada nivel tiene un **precipicio** (el Soberano que pasa cuesta 10 vidas de golpe): una diferencia de 3 o 4 torres decide entre V14 y V1. Por eso uso las vidas como **margen**, no como una medida fina.

## 3. El criterio y qué niveles lo pasan

Un nivel **admite la Cuadrilla** si cumple **las cuatro**, en las **dos** versiones (S y R, para que el resultado no dependa de cómo se arme la oleada):

1. **Regla de oro (RF-432):** `sin_recursos` gana **al menos 4 de 5** semillas.
2. **Margen:** termina con **al menos 3 vidas en todas las semillas** (no queda en el precipicio).
3. **Escalera (RF-475, punto 3, para el 11 al 15):** no termina con menos vidas que el siguiente nivel, así que **el 15 (2 vidas) sigue siendo el más difícil**. Con el 14 en 3 y el 15 en 2, el 14 con Cuadrilla tiene que terminar en **3 o más**; con 2 empataría con el 15.
4. **No es un nivel que ya debuta otra cosa de peso** si hay un nivel mejor (RF-475, punto 1): se prefiere debutar donde no hay otro debut.

| Nivel | Regla de oro | Margen ≥ 3 | Escalera | Otro debut | **¿Admite?** |
|---|---|---|---|---|---|
| 6 | **No** (0/5) | — | — | Ladrón, Embestidor | **No** |
| **7** | Sí | Sí (S ≥ 5, R ≥ 7) | — | **No** | **Sí** |
| 8 | Sí | **No con R** (1 a 3) | — | Guardián | No |
| 9 | Sí | **No con R** (2 a 4) | — | Curandero, Mortero | No |
| **10** | Sí | Sí (≥ 7) | — | **No** (RF-453) | **Sí** |
| 11 | Sí | **No** (2 con S en una semilla; 2 con R en cuatro) | **Empata con el 15** (2) | Chamán | No |
| 12 | Sí | **No con S** (2 en cuatro semillas) | **Empata con el 15** con S (2) | Espejo | No |
| **13** | Sí | Sí (5 con S, 3 con R) | Sí (≥ 3) | Escolta coordinada (oleadas, no enemigo) | **Sí** |
| **14** | Sí | Sí (3 y 3) | **Sí: 3, el 15 sigue en 2** | Ninguno | **Sí** |
| 15 | *no se midió: queda fuera por pedido* | | | Coloso | **No** |

## 4. Cuánto roba

Semilla 1, `sin_recursos`. «Base» es el Ladrón solo (el que ya está en el nivel).

| Nivel | Oro robado, base | Oro robado, con la Cuadrilla (S) | Veces más |
|---|---|---|---|
| 7 | 21 | 326 | ×16 |
| 8 | 36 | 391 | ×11 |
| 9 | 35 | 484 | ×14 |
| 10 | 37 | 603 | ×16 |
| 11 | 52 | 555 | ×11 |
| 12 | 45 | 515 | ×11 |
| 13 | 51 | 807 | ×16 |
| 14 | 66 | 528 | ×8 |

- **Entre 326 y 807 de oro por partida**: de 3 a 8 torres de 100. Las 4 apariciones, si el bot las mata todas, **le dan de oro** unos 310 (32 Rateros × 5 y 5 Cargadores × 30). O sea que **en neto la Cuadrilla le cuesta oro** al jugador, que es lo que se quería, pero no lo deja sin nada.
- En el **13** roba más (807); **no se investigó por qué** (sus oleadas con la Cuadrilla traen Tanques y Trolls, que tardan en morir, y el robo corre mientras viven: es una hipótesis).
- Es el total de la partida (cuatro apariciones más el Ladrón), de **una** semilla.

## 5. Asedio (el mapa 7 está adentro)

Asedio hoy tiene los mapas 1 a 9 (`data/modos/asedio/modo.json`, 115 % de vida, RF-391). Se reemplazó el nivel 7 por la versión S **en la copia** y se jugó `modo=asedio level=7`, semillas 1 a 3, con `sin_recursos` y con `mix`:

| | sin la Cuadrilla | con la Cuadrilla |
|---|---|---|
| `sin_recursos` | D 20/20, D 19/20, D 19/20 | **D 11/20 ×3** |
| `mix` | D 20/20, D 19/20, D 19/20 | **D 11/20 ×3** |

- **El bot ya perdía Asedio 7 sin la Cuadrilla** (en la última oleada o en la anterior). Con ella pierde **nueve oleadas antes**: en la 11, que es la segunda aparición, baja de 12 vidas a 0.
- **No se midieron el 8 ni el 9 de Asedio** (la propuesta no los incluye).
- **Los mapas 10, 13 y 14 no están en Asedio** (T235 quedó pendiente y Lucas aún no decidió cuáles se suman): si se suman, **heredan** la Cuadrilla porque RF-391 dice «mismas oleadas».

## 6. Qué se comprobó y qué no

**Se comprobó:**
- Que `file=` reproduce la campaña: la base del 11 con la semilla 1 da V6 y 2222 de oro sobrante, igual que `level=11`.
- Las 135 + 16 + 12 partidas, **sin `SCRIPT ERROR`** en ningún log.
- Los números libres RF-485 y D-094, M55 y T252 a T254 con `git grep` en todas las ramas locales y de `origin`.

**No se comprobó:**
1. **Una sola intensidad por nivel** (cuatro apariciones de 6+1 a 10+2, en oleadas elegidas con una regla fija). Con otra intensidad o en otras oleadas el resultado puede cambiar: T253 las ajusta. **Los números de vida, velocidad y robo son los del informe de T251, sin tocar.**
2. **Solo `sin_recursos`** en la campaña. El resto de las estrategias (RF-475 pide mirar las cinco) las mide T253.
3. **El bot no es una persona.** Nadie jugó nada. El robo, que es lo que cambia el juego, **depende de cuánto oro tenga el jugador**: el bot nunca mejora torres (T251 §2.5) y por eso deja miles de oro sin gastar al final; una persona que mejora torres tiene menos oro «parado» y siente más cada robo.
4. **El precipicio del final** hace que las vidas de la versión R en el 8 y el 9 (1 a 4) sean ruidosas: lo uso como señal de «al borde», no como medida.
5. **El arte y los textos no existen:** el Ratero y el Cargador de la prueba usan el dibujo del Rápido y del Tanque.
6. **El 15 no se midió** (fuera de la tarea). **Asedio 8 y 9 tampoco.**
7. **Las oleadas tienen una entrada única** (`"A"`): en los niveles con dos entradas (13 y 14) no se probó repartir la Cuadrilla.
8. La máquina estaba cargada con otros procesos (el promedio de carga llegó a 22 en 12 núcleos). Los resultados del bot no dependen del reloj (`--fixed-fps 60`), pero **no se volvió a correr ninguna partida** para confirmar.

## Apéndice · cómo repetirlo (nada de esto está en el repositorio)

**1. Los dos `.tres`.** `data/enemies/ratero.tres` y `data/enemies/cargador.tres` con los números de §1, `gold_drain_amount` 2 y 4, `gold_drain_interval` 2.0, `gold_drain_floor` 10 y `optional_wave_limit` 0 (el valor por omisión). Copiar `fast.tres` y `tank.tres` y cambiar `id`, `display_name`, `max_health`, `speed_tiles`, `armor`, `reward`, `lives_damage` y `size_tiles`.

**2. Los niveles** (`python3 gen.py <carpeta>`; la carpeta tiene que estar **dentro del proyecto**, porque `file=` agrega `res://`):

```python
import json,sys,os,math
SRC='data/levels'
OUT=sys.argv[1]
os.makedirs(OUT,exist_ok=True)
HP={'normal':30,'fast':18,'flyer':18,'spiderling':8}
def make(n, variant):
    d=json.load(open(f'{SRC}/level_{n:02d}.json'))
    N=len(d['oleadas'])
    AUR={'guardian','healer','shaman','mirror','boss','colossus'}
    cand=[i+1 for i,w in enumerate(d['oleadas'])
          if 3<=i+1<N and not any(g['enemigo'] in AUR for g in w)]
    pos=[]
    for p in (0.40,0.55,0.70,0.85):           # cuatro apariciones
        free=[c for c in cand if c not in pos]
        pos.append(min(free,key=lambda c:abs(c-N*p)))
    pos.sort()
    plan=[(6,1),(8,1),(8,1),(10,2)]            # (rateros, cargadores)
    if variant=='base': return d
    for (w,(r,c)) in zip(pos,plan):
        wave=d['oleadas'][w-1]
        if variant=='R':                       # reemplazo: se saca relleno
            need=r*14+c*110
            for g in sorted([g for g in wave if g['enemigo'] in HP],
                            key=lambda g:-HP[g['enemigo']]):
                if need<=0: break
                cut=min(g['cantidad'], math.ceil(need/HP[g['enemigo']]))
                g['cantidad']-=cut; need-=cut*HP[g['enemigo']]
            wave[:]=[g for g in wave if g['cantidad']>0]
        wave.append({'enemigo':'ratero','cantidad':r,'cada':0.4})
        wave.append({'enemigo':'cargador','cantidad':c,'cada':3.0})
    return d
for n in range(6,15):
    for v in ('base','S','R'):
        json.dump(make(n,v),open(f'{OUT}/L{n}_{v}.json','w'),ensure_ascii=False)
```

**3. El bot**, una partida por proceso (se pueden correr 6 a 8 a la vez):

```bash
godot --headless --import     # una vez, en la copia
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- sin_recursos file=res://levels_c/L11_S.json seed=1
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- sin_recursos modo=asedio level=7 seed=1   # con level_07.json reemplazado por la versión S
```

**4. El conteo de oro robado** (parche a la copia de `tools/balance_sim.gd`): una variable `var _stolen: int = 0`; en `_process`, donde se conecta `resources_changed`, agregar `_stolen = 0` y `session.gold_stolen.connect(func(n: int) -> void: _stolen += n)`; e imprimir `_stolen` en la línea de `RESULTADO`.
