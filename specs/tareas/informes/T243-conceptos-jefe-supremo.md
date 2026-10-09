# T243 · Conceptos del jefe supremo del nivel 15 (para que elija Lucas)

> **Estado: RESUELTO el 2026-10-09. Lucas eligió el concepto C, «El Coloso»**, y aceptó las propuestas del §6: **12 de 20 vidas**, oleadas **26, 28 y 30** (escolta completa solo en la 30), nombre **«Coloso»** y pertenencia **ambigua**. Quedó escrito como **RF-481 a RF-484**, **D-092** y el plan «M54 / T243». Lo que sigue es el informe original, sin cambios, tal como lo leyó Lucas (incluidas frases como «Lucas todavía no eligió» y «los números libres son RF-481 y D-092», que eran ciertas ese día).
>
> *(Texto original:)* Escrito el 2026-10-09 por Claude (Sonnet 5.5), tarea **T243**. Acá **no hay RF ni D**: se escriben recién cuando Lucas elija un concepto (los números libres son **RF-481** y **D-092**, verificados con `git grep` en todas las ramas `feature/*` y `origin/feature/*`: la más alta es RF-480 y D-091, y esos dos números solo aparecen nombrados como «el siguiente libre»). Los números de abajo son **iniciales y no se midieron con el bot**: los ajusta T234.

## 1. Lo que ya está decidido (no se discute acá)

- **Lucas (Q-32 ✎):** el 15 no trae al Soberano; trae un **jefe supremo nuevo** con la **escolta coordinada** (Guardián + Curandero + Chamán) en las últimas oleadas, en formación y por varias entradas (§7.17, RF-480).
- **Biblia, 10 §4.4:** (1) la amenaza más grande del juego y un **cierre**, no «un jefe más»; (2) tono sobrio, **nada de villano caricaturesco** (10 §8: sin diálogos, sin sentencias, voz de informe); (3) lo natural es que pertenezca al lado de las comunidades (**Moradores**), pero es opción mía a proponer.
- **Ficha del 15, punto 5:** el nivel no enseña nada nuevo, **junta lo aprendido**. Y punto 8: la contramedida tiene que estar **entre las torres comunes**, porque `sin_recursos` (sin Disruptora, sin Mortero, sin Mecánico) tiene que ganar al menos 4 de 5 también contra el jefe.
- **Ficha de T243, «Frenar si»:** el concepto **no** puede exigir un sistema nuevo (otro tipo de daño, otro tipo de mapa). Por eso los tres conceptos usan campos que `EnemyData` ya tiene; el único que necesita un dato más lo dice claro (concepto B).

## 2. Con qué se compara (datos de hoy, `data/enemies/`)

| Enemigo | Vida | Velocidad | Armadura | Vidas que quita | Habilidad |
|---|---|---|---|---|---|
| **Soberano** (`boss`) | 300 | 0,6 | 3 | 10 | Resiste la mitad de la ralentización |
| Guardián | 200 | 0,7 | 1 | 3 | Aura de 2 casillas: +2 de armadura a los demás (no se suma, vale la más fuerte) |
| Curandero | 60 | 1,1 | 0 | 1 | Aura de 2,5 casillas: cura 3 % de la vida máxima por segundo |
| Chamán | 90 | 0,9 | 0 | 2 | Cada 8 s aturde 3 s a la torre más cercana (hasta 4 casillas) |

**Vida por oleada en el 15** (22 % lineal, RF-36): oleada 26 → ×6,5 · 28 → ×6,94 · 30 → ×7,38. El Soberano (300) sería de unos **2200** en la última oleada. **Torres comunes** que importan: Francotirador (40/70/120 por tiro, alcance 6), Cañón (20/32/…, área), Incendiaria (la quemadura **ignora** la armadura y corta la cura), Hielo, Tesla (cadena, +30 % a los quemados), Múltiple y Ráfaga (golpes chicos: la armadura los anula, daño mínimo 1).

## 3. Los tres conceptos

### A · «El Custodio» — el muro que avanza *(el más simple)*

- **Qué es.** Un gólem de piedra colosal, de la misma piedra que los Guardianes: el que sostiene la formación. Los colonos lo llaman **Custodio** porque la escolta se acomoda a su alrededor.
- **Función.** **Ancla de la formación:** mucha vida y armadura, y un aura **más grande y más fuerte** que la del Guardián (así «manda» sobre la del Guardián, que no se suma).
- **Habilidad (campos que ya existen).** Aura de armadura de **3 casillas, +3**; aura de cura de **1 % por segundo** a los demás.
- **Números iniciales.** Vida **700** · velocidad **0,5** · armadura **4** · resistencia a la ralentización **0,5** · **12** vidas · recompensa **250** · tamaño visual de 1,5×.
- **Contramedida.** Pegarle fuerte por golpe (Francotirador, Cañón) y **quemarlo** (la quemadura ignora la armadura y le corta la cura al Curandero). La **Disruptora** le apaga el aura 3 s, pero es un atajo: en `sin_recursos` no está.
- **Con la escolta.** Armadura 4 + aura 3 = 7 de armadura para los demás: la Múltiple y la Ráfaga dejan de servir. El Curandero sostiene, el Chamán apaga el Francotirador. Se resuelve **matando la formación de atrás hacia adelante**.
- **Qué puede salir mal.** Es **un Soberano con aura** y repite la función del Guardián (la ficha pide no repetir ninguna). Se siente como «el jefe de siempre, más grande»: la restricción 10 §4.4 (1) queda floja.
- **Costo.** Solo datos: un `.tres` y un dibujo. Sin código nuevo.

### B · «El Vocero» — el gran sabotaje *(conecta con la central)*

- **Qué es.** El Chamán mayor: un encapuchado alto, con un bastón que chispea más y más lejos. Los colonos lo llaman **Vocero** porque los otros tres se mueven cuando él se mueve. Hace de la central de energía (el objetivo del mapa) algo personal sin caricaturizar a nadie: busca **frenar la infraestructura**, no matar colonos (10 §4.3).
- **Función.** **Apagar la defensa:** no es un tanque, es el que desarma el perímetro.
- **Habilidad.** Como el Chamán, pero **cada 8 s aturde 3 s a las 4 torres más cercanas** (hasta 4,5 casillas). Hoy el hechizo (RF-281) apaga **una** torre; hace falta **un dato más en `EnemyData`** (`stun_targets`, con 1 por defecto, o sea que el Chamán actual no cambia). **No es un sistema nuevo**, pero **sí un cambio de código** en T234.
- **Números iniciales.** Vida **450** · velocidad **0,6** · armadura **1** · **10** vidas · recompensa **250** · alcance del hechizo **4,5** (menos que el Francotirador, 6, como pide RF-282).
- **Contramedida.** (1) **Alcance:** el Francotirador lo golpea 1,5 casillas antes de que apague nada. (2) **Señuelos:** el hechizo va a las torres **más cercanas**, así que 4 torres baratas (Hielo) pegadas al camino se «comen» el apagón. (3) **Cobertura repetida**: que ninguna zona dependa de una sola torre. La Disruptora **no** lo afecta (RF-444). Todo está entre las comunes.
- **Con la escolta.** Su apagón se suma al del Chamán de la escolta; el Guardián y el Curandero protegen a los dos mientras la defensa está a oscuras. Es el concepto que más se **siente** como «coordinados».
- **Qué puede salir mal.** Con poca vida es **más molesto que peligroso** (a 450 de base cae rápido si las torres lo alcanzan); para ser «la amenaza más grande» hay que subirle la vida y se parece a un Chamán gordo. Repite la función del Chamán. Y es el único con **código nuevo**.

### C · «El Coloso» — el que se parte *(el que recomiendo)*

- **Qué es.** Un gólem de piedra del tamaño de dos Guardianes. Los colonos lo llaman **Coloso** (igual que «Soberano», es un nombre de informe, por el tamaño). **No se sabe** si los Moradores lo guían o si solo comparten camino con él, como pasa con el Espejo (10 §4.2): la ambigüedad es intencional. No habla ni tiene gesto de nada: avanza.
- **Función.** **Castigar a quien juega con una sola idea.** Tiene **dos cuerpos**: primero una masa blindada y lenta; cuando cae, **se parte en tres pedazos** chicos, rápidos y sin armadura que siguen camino hacia la salida. Lo que rompe el primer cuerpo (golpe fuerte) no sirve para los pedazos, y lo que barre los pedazos (área, ralentización) no le hace nada al primero. Es la lección del Blindado («no sirve todo contra todo»), pero a lo grande.
- **Habilidad.** Se hace con lo que ya existe: **`death_spawn`** (RF-166, el mismo mecanismo de la Araña y sus Crías). **Ningún campo nuevo en `EnemyData`, ningún sistema.** Solo **dos archivos de enemigo**:

  | ID | Vida | Velocidad | Armadura | Vidas | Recompensa | Resto |
  |---|---|---|---|---|---|---|
  | `colossus` (cuerpo) | **600** | **0,5** | **5** | **12** | **200** | Resiste la mitad de la ralentización; al morir por daño suelta **3** `colossus_shard` |
  | `colossus_shard` (pedazo) | **180** | **1,0** | **0** | **4** | **30** | Sin habilidad. Si el cuerpo **llega** a la salida, no suelta nada (RF-166) |

  Con el 22 % de la oleada 30: cuerpo ≈ 4400 de vida y cada pedazo ≈ 1300 (≈ 4000 entre los tres). Es unas **2×** el Soberano en el cuerpo, y los pedazos son una segunda amenaza completa. T234 ajusta con el bot.
- **Contramedida.** Cuerpo (armadura 5): **Francotirador, Cañón, Tesla y quemadura** (la Múltiple y la Ráfaga hacen daño mínimo). Pedazos: **Hielo** (no resisten la ralentización), **Cañón/Múltiple/Ráfaga/Tesla** (área y cadena). Una defensa de solo Francotiradores deja pasar los pedazos; una de solo Múltiples no le hace nada al cuerpo. **Matarlo lejos de la salida** es una jugada: los pedazos tienen más camino por delante. Todo entre las **torres comunes**, así que `sin_recursos` lo puede ganar.
- **Con la escolta.** La escolta convierte la mezcla en rompecabezas: el **Guardián** (+2) le da 7 de armadura al cuerpo y 2 a los pedazos si se quedan cerca, el **Curandero** cura 3 % por segundo (con 180 de vida, un pedazo se recupera rápido), el **Chamán** apaga justo la torre que hace falta. Pero los pedazos corren a 1,0 contra 0,7 del Guardián: **la formación se estira** y eso abre una ventana para pegarles sin aura. T234 puede alinear los tiempos de entrada (`desde`, RF-203) para que la ventana exista, o no.
- **Qué puede salir mal.** (1) Dos fases significan dos dibujos (cuerpo y pedazo) y dos ciclos de caminata para T244. (2) Si la vida de los pedazos queda mal, el bot los puede dejar pasar en masa: es lo primero a medir. (3) La presentación de la Wiki (RF-134) la dan los dos enemigos; hay que decidir si el pedazo tiene su propia ficha (propongo que sí, como la Cría).
- **Tono.** Un cuerpo que se parte no tiene intención ni mensaje; no hay villano, ni jefe que hable, ni «malvado». La Wiki puede decir: *«Los colonos lo llaman el Coloso. Es de la misma piedra que los Guardianes. Cuando cae, se parte en tres y los pedazos siguen camino.»* (ni juzga ni explica).

## 4. Comparación

| | A · Custodio | B · Vocero | C · Coloso |
|---|---|---|---|
| **Función propia** (no repite a otro) | Floja (repite al Guardián) | Media (repite al Chamán) | **Nueva: castiga lo unilateral** |
| **«Cierre», no «un jefe más» (10 §4.4 (1))** | Floja | Media | **Sí: junta Blindado, área, hielo y alcance** |
| **Tono** (sin villano) | Bien | Bien | Bien |
| **Pertenece a las comunidades** | Sí (gólem) | Sí (Chamán mayor) | Ambiguo, como el Espejo (o sí: gólem) |
| **Contramedida en torres comunes** | Sí | Sí (alcance y señuelos) | **Sí (dos jugadas distintas)** |
| **Código nuevo** | No | **Sí** (`stun_targets`) | **No** (`death_spawn`) |
| **Dibujos** | 1 | 1 | **2** (cuerpo y pedazo) |
| **Riesgo de balance** | Bajo | Medio | **Medio** (la vida de los pedazos) |

## 5. Recomendación

**Concepto C, «El Coloso».** Es el único que cumple a la vez los tres pedidos de la biblia: es un **cierre** (obliga a usar todo lo aprendido, que es lo que dice la ficha del 15), tiene **función propia** y **no necesita ningún sistema nuevo ni una línea de código de reglas**: son dos archivos de datos, como la Araña. A queda como plan B barato si T244 no llega a dibujar dos cuerpos; B queda como alternativa descartada en la D (y, si Lucas quiere un Chamán mayor, se puede anotar en §13 para una entrega futura).

## 6. Lo que necesito que decida Lucas

1. **¿A, B o C?** (o una mezcla; por ejemplo, el Coloso con el aura de A).
2. **Cuántas vidas quita si llega** (propongo **12 de 20**: una sola fuga lo deja en el límite, dos pierden).
3. **Cuándo aparece** (propongo una vez por oleada en la **26, la 28 y la 30**, con la escolta completa solo en la 30; lo cierra T234 con el bot).
4. **El nombre** («Coloso», «Custodio» y «Vocero» son nombres de informe; se puede cambiar).
5. **Si pertenece a las comunidades** (propongo que quede **ambiguo**, como el Espejo; que sea un gólem vuelve la escolta más natural pero acerca el jefe a «el líder de ellos»).

## 7. Qué pasa después de la elección (para que sea claro)

- **T243** escribe **RF-481** (con «Dado / Cuando / Entonces»), **D-092** (con A, B y C como alternativas descartadas) y la sección del plan técnico (vida, velocidad, habilidad, recompensa, Wiki y texto del lore), y actualiza spec §7.17, `CONTENIDO.md` y `CHANGELOG.md` si corresponde.
- **T244** dibuja lo que diga el RF (para C: el cuerpo y el pedazo, con atlas de caminata).
- **T234** programa/ajusta (para C: los dos `.tres`, las oleadas finales y la comprobación de que `check_rule` deja que el jefe **debute** en el 15; RF-480 ya prevé que no trae al Soberano).

## 8. Qué se comprobó y qué no

- **Se comprobó:** que `death_spawn`, las auras, el hechizo del Chamán y la resistencia a la ralentización existen en `scripts/data/enemy_data.gd`; los números de la tabla de §2 salen de `data/enemies/*.tres`; la fórmula de vida por oleada, de `scripts/logic/rules.gd`; y que RF-481 y D-092 están libres en todas las ramas.
- **No se comprobó:** ningún número de vida, velocidad ni cantidad con el bot ni en partida (la tarea no programa); tampoco que `check_level`/`check_rule` acepte un debut en el 15 ni que el pedazo se vea bien con el atlas actual. Todo eso queda para T234 y T244.
