# 08 — Plan de cierre de Monsters & Canons V1, dividido en tareas

Fecha: 2026-10-07. Lo preparó Claude (Opus 5.5) a pedido de Lucas, a partir de [07-lore-y-cierre-v1.md](07-lore-y-cierre-v1.md), del backlog (§13 de la spec) y del estado real del repositorio.

> **Qué es:** el plan de trabajo para terminar la V1. Son 15 niveles con su lore y los sistemas que pide el 07 (demolición, recursos, extracción, colecciones y Disruptora), más la **base de la franquicia**. Está dividido en tareas `Txxx`. Cada una tiene su **ficha de delegación** en [`specs/tareas/`](tareas/), lista para pasársela a otro agente.
>
> **Qué no es:** no es la spec. Los `RF` y las `D` los escriben las tareas de spec (📜) después de que Lucas responda el cuestionario [09-decisiones-pendientes-v1.md](09-decisiones-pendientes-v1.md). Las fichas de mapa de la sección 5 son **propuestas de Claude**: no están aprobadas.
>
> **Fuera de este plan (Lucas, 2026-10-07):** M&C 3D (documento 06), M&C 2 y Épocas. Tampoco se adelanta nada técnico pensado solo para el 3D, como separar la simulación de la vista.
>
> **Estado vigente (2026-10-23, auditoría T444):** en las fases 0 a 6 están hechas las tareas de spec, código y datos, salvo el resto de T235; siguen abiertas las de arte con compuerta (T216, T218 a T221 y T233) y la partida T226. En la fase 7 están hechas T236 y T237, y la intro (fase 8) está hecha. Lo que falta para cerrar la V1, ordenado y con qué falta exactamente, está al principio de [`03-tareas.md`](03-tareas.md#qué-falta-para-cerrar-la-v1--vista-de-la-auditoría-t444-2026-10-23): las partidas de Lucas (T280, T226, T283 y T238), T266, T267 y T268 antes del reenvío, el resto de T235, el arte con compuerta y la publicación (T239). Las secciones 2, 6 y 7 conservan el plan original del 2026-10-07, con algunas marcas ✅ y el «Orden vigente» de §7 agregados; el estado de cada tarea manda en el tablero.

---

## 1. Quién hace qué

> **Prioridades actualizadas por Lucas, 2026-10-16:** antes de los pendientes históricos de menor prioridad, atender el bloque de prioridad máxima [T262 a T268 en el tablero](03-tareas.md#prioridad-máxima--mobile-presentación-y-próxima-prueba-2026-10-16): análisis y optimización mobile, mejoras de torre con menos diálogos, zoom y compra/colocación táctil, presentación de torres disponibles en niveles para ambas plataformas, progresión de dificultad y revisión de assets iniciales/finales. El arte de **T267 exige `gpt-6.1-sol` con esfuerzo medio**, por pedido de Lucas, por encima de la asignación genérica de la tabla. **No reenviar al primer tester hasta resolver y validar balance (T266) y assets (T267)**; T268 verifica su guardado y prepara esa entrega. Por ahora solo se registra el backlog: no se autoriza implementación ni producción de arte.

| Ejecutor | Para qué | Cómo se le pasa el trabajo |
|---|---|---|
| **Lucas** | Decisiones, aprobaciones (las compuertas 🚦) y partidas de prueba. | El cuestionario 09 y las fichas que dicen "Lucas". |
| **Sonnet 5.5 · alto** | Escribir specs y decisiones, y diseñar mapas y oleadas. | La ficha de la tarea. Si se puede, conviene Opus. |
| **Sonnet 5.5 · medio** | Código de sistemas, con sus tests. | La ficha: dice qué archivos tocar, qué patrón copiar y qué tests escribir. |
| **Sonnet 5.5 · bajo** | Datos, documentación, renombres e informes. | La ficha. |
| **Qwen 3.5 4B Q6 (local)** | **Solo** tareas marcadas *apto Qwen*: datos con un validador automático que atrape los errores (`tools/check_level.gd` y los tests). | La ficha más la sección "Para Qwen" de [`tareas/README.md`](tareas/README.md). Un Sonnet bajo revisa el resultado antes del PR. |
| **Codex** | **Todos los assets** (imágenes, atlas e íconos). Tiene `image_gen` integrado, como en M43. | Su ficha. **Antes de producir**, Lucas aprueba la *ficha de arte* (compuerta 🎨). Codex no toca la lógica. |

**Regla para no bloquearse:** el código **nunca espera al arte**. Cada sistema nuevo se programa con un dibujo provisional hecho en código y el asset de Codex se integra después.

---

## 2. Estado real del repositorio (relevado el 2026-10-07)

- **Tests:** 1017/1017 en verde en esta máquina, que es **Linux** con Godot 4.7.2 en `/usr/local/bin/godot`, y sin `SCRIPT ERROR`. `CLAUDE.md` describe la instalación de Windows, así que se le agregó una nota para Linux.
- **Campaña:** 9 niveles (Pradera, Desfiladero, Encrucijada, Espiral, Fortaleza, Nido, Cruce, Bastión y Taller asediado). **Ninguno usa `tema`**: los 9 se ven como pradera.
- **Debuts actuales:**
  - Niveles 1 a 5: Normal, Rápido, Blindado, Tanque, Volador y Jefe.
  - Niveles 6 y 7: Troll, Araña, Ladrón y Embestidor.
  - Nivel 8: Guardián. Nivel 9: Curandero.
- **Contenido hecho que la campaña no usa:**
  - **Chamán** (aturde torres) y **Espejo** (rebote), de M18, que no aparecen en ningún nivel.
  - El **Mortero**, reservado hoy para el nivel 10 (RF-300), que todavía no existe. Por decisión de Lucas (Q-21, 2026-10-08) pasa a debutar en el nivel 9.
- **Torres:** 8 comunes y 2 reservadas (Mortero y Estandarte mecánico). El Mecánico pide la colección de 5 avances plateados de los niveles 1 a 5.

### 2.1 Piezas que ya existen y conviene extender (no rehacer)

| Lo que pide el 07 | Pieza existente | Archivo |
|---|---|---|
| Obstáculos removibles y permanentes | La `leyenda` del nivel: letra → `dibujo` + `construible` (RF-262). | `scripts/logic/level_file.gd`, `scripts/logic/map_grid.gd` |
| Torres por mapa (rotación) | `allowed_towers` de los modos (RF-388) y `torres_extra` (RF-300). | `scripts/data/level_data.gd` (`available_towers`) |
| Colecciones por tecnología | `progression.json`, `CollectibleRun`, `SaveManager._collections` y `TowerData.required_collection`. | `scripts/logic/collectible_run.gd`, `scripts/autoload/save_manager.gd` |
| Confirmar un hallazgo | La regla RF-359: se confirma al completar la oleada y se pierde si la partida se abandona. | `CollectibleRun` |
| Oro y cobros | `LevelSession` (`spend`, `earn`, `can_afford` y la señal `gold_changed`). | `scenes/game/level_session.gd` |
| Balance | El bot `tools/balance_sim.gd` (estrategias, `modo=` y `file=`) y `art/mechanics-m41/balance.gd` (`seed=`). | `tools/` |

### 2.2 Tensiones que hay que resolver (están en el cuestionario 09)

1. **§11 de la spec excluye "Historia, diálogos o cinemáticas".** La intro ilustrada, los textos por nivel y el epílogo del 07 necesitan una **enmienda explícita** de §11 (P4). → Q-01.
2. **"Árbol y roca dan 1 recurso"** choca con **"los recursos tienen que tener un uso en el mapa donde aparecen"**. Propuesta original: los recursos aparecen recién en el 10. **Resuelto por Lucas (2026-10-08):** los recursos caen al azar (con semilla) **desde el nivel 7**, donde el Francotirador se puede comprar también con 120 de oro + 1 recurso (nunca indispensable), y el Mortero debuta en el 9. → Q-18 y Q-21.
3. **El documento 06 (§10.3) pedía hacer B-14, B-23, B-08 y B-09 antes de los niveles 10 a 15**, para no balancear dos veces. El foco nuevo es otro, así que la propuesta es pasarlos a después de la entrega. → Q-06.
4. **El ejecutable y el paquete se llaman `JuegoA`**, y el repositorio es privado. La licencia GPL obliga a ofrecer el código fuente. → Q-04 y Q-05.
5. **Nombres inconsistentes:** el Normal es "lobo de ceniza" en la guía §3 y "diablillo rojo" en M24. Para una franquicia hace falta un glosario canónico (T202).

---

## 3. Qué entendemos por "base para la franquicia"

Se arma sobre la V1. **No anticipa el 3D:**

1. **Biblia del universo** (`specs/10-universo.md`, T201):
   - El canon: planeta, expedición, regiones, especies, comunidades y tecnología.
   - Las reglas de tono: ambigüedad y no sentenciar.
   - Qué es **canon** y qué es **semilla** para entregas futuras (elegir bando, rebeldes).
   - La reusan M&C 3D y M&C 2 tal cual.
2. **Glosario canónico** (T202): un nombre por especie, torre, lugar y facción, aplicado en datos, Wiki y documentos.
3. **Lore dentro del juego** (T227 y T228): textos breves por nivel, una categoría Lore en la Wiki y el epílogo. La spec es M52 (`01-spec.md`) y los textos viven en [`11-textos-lore.md`](11-textos-lore.md).
4. **Marca** (T237): "Monsters & Canons" en ventana, ejecutables y paquete, si Lucas lo aprueba.
5. **Datos reutilizables:** los sistemas nuevos se definen por datos (leyenda, `modo.json` y `progression.json`), como ya pide P10, para llevarlos a otra entrega sin reescribirlos.

Si Lucas quiere decir otra cosa con "franquicia", se corrige en Q-02.

---

## 4. Fases y compuertas

Las compuertas 🚦 son los puntos donde **se pide intervención de Lucas**. Un agente que llega a una compuerta **se detiene** y deja la pregunta en su PR.

| Fase | Qué | Compuerta al final |
|---|---|---|
| **0 · Decidir** | Lucas responde el cuestionario 09 y aprueba o corrige las fichas de mapa (sección 5). | 🚦 **G1** (T200) |
| **1 · Base y herramientas** | Biblia, glosario, torres por mapa y bot con semillas. | 🚦 **G2**: Lucas aprueba la biblia (T201) |
| **2 · Spec de sistemas** | RF y D de removibles, demolición, demoledora, recursos, extracción y colecciones. | 🚦 **G3**: Lucas da el OK a la spec antes de programar (T205) |
| **3 · Sistemas** | El código, con arte provisional. | — |
| **4 · Disruptora** | Spec, arte y código. | 🎨 concepto de arte (T216) |
| **5 · Arte del bloque 2** | Codex: señales, removibles, extracción e íconos. | 🎨 cada ficha de arte |
| **6 · Campaña** | Retoque de 1 a 9, nivel 10, partida de Lucas, y después 11 a 15 con el lore. | 🚦 **G4**: Lucas juega del 6 al 10 (T226) |
| **7 · Candidato de entrega** | Regresión, marca, exportaciones y partida completa. | 🚦 **G5**: Lucas juega del 1 al 15 (T238) |
| **8 · Intro** | Guion, láminas e integración. **Va última.** | 🚦 **G6**: Lucas aprueba el guion (T240) |

---

## 5. Fichas de los 15 mapas · aprobadas como dirección por Lucas el 2026-10-08 (Q-34), con el reparto del bloque 2 ya incorporado

Criterios:
- No tocar el balance de los niveles 1 a 5.
- Un sistema nuevo por mapa.
- Primero se enseña la amenaza y después la herramienta.
- Usar Chamán y Espejo, que ya están hechos, antes de inventar enemigos.
- Mortero en el 9 (enmienda de RF-300, Q-21).
- Los nombres de mapa actuales se conservan y se suma un **subtítulo de lugar** (lore).

### Bloque 1 · El oasis (1–5): asegurar la posición y sobrevivir

Tema `pradera`, con agua y flores de la leyenda donde ya hay casillas `X`. **No cambia ni una casilla jugable**: las señales solo reemplazan casillas `X`, que ya estaban bloqueadas.

| # | Mapa | Lugar (lore) | Señal plantada | Enseña | Cambios |
|---|---|---|---|---|---|
| 1 | Pradera | Campamento de aterrizaje | Una roca con una **marca tallada** (símbolo A). | Construir, oleadas. | Solo decoración y textos. |
| 2 | Desfiladero | El paso del agua | **Sendero de piedras** acomodadas. | Mejorar y vender. | Ídem. |
| 3 | Encrucijada | Las huertas | Una **herramienta tallada** abandonada. | Dos entradas. | Ídem. |
| 4 | Espiral | El pozo | Un **poste con cintas**. | Recorridos largos. | Ídem. |
| 5 | Fortaleza | La empalizada | **El símbolo A otra vez**, en varias rocas. | Cierre del bloque y 5.º avance (Mecánico). | Ídem. |

### Bloque 2 · Fuera del oasis (6–10): posiciones avanzadas y abastecimiento

| # | Mapa | Lugar | Tema | Sistema que enseña | Enemigos | Torres |
|---|---|---|---|---|---|---|
| 6 | Nido | El lindero | `bosque` | **Demolición directa** con oro: 2 o 3 árboles o rocas que abren buenas casillas en una curva. Sin recursos. | Los actuales (Troll, Araña, Ladrón y Embestidor). | 8 comunes y Mecánico. |
| 7 | Cruce | El aserradero | `bosque` | **Demoledora**: 5 o 6 removibles, para que comprarla convenga. **Primer drop de recursos al azar** (con semilla) y **Francotirador con recurso** (150 de oro, o 120 + 1 recurso; nunca indispensable). Primer indicio decorativo del símbolo A. | Los actuales. | Ídem. |
| 8 | Bastión | El bastión sobre ruinas | `ruinas` | **Primera ruina:** su escombro guarda la **pieza 1/3 de la Disruptora**. Las ruinas muestran **el símbolo A** (revelación). | Los actuales (debut del Guardián). | Ídem. |
| 9 | Taller asediado | El taller | `ruinas` | Ruina con la **pieza 2/3**. **Debut del Mortero** (oro + recursos). | Los actuales (debut del Curandero). | 8 comunes, Mecánico y **Mortero**. |
| 10 | **Nuevo** | La mina vieja (primer puesto de abastecimiento) | `ruinas` → `desierto` | **Extracción:** una mina o bosque explotable con reserva finita (100 de oro, 2 recursos por oleada, reserva de 8) y removibles que dan 1 recurso. Ruina con la **pieza 3/3**, que completa la colección de la Disruptora. | Mezcla del 6 al 9, con Guardián y Curandero juntos. **Sin debuts.** | 8 comunes, Mecánico y Mortero. |

Los niveles 6 a 9 **cambian de balance** porque los removibles abren casillas. Se rebalancean con el bot (T223 y T224) y los juega Lucas (G4).

### Bloque 3 · Territorio disputado (11–15): consolidar el hogar

| # | Lugar | Tema | Enseña o exige | Debut | Torres |
|---|---|---|---|---|---|
| 11 | Puesto seco | `desierto` | **Disruptora** contra auras. Bosque o mina explotable. | **Chamán** (sabotaje: aturde torres). | Rotación: **se retira la Básica** (Q-29). Entra la Disruptora. |
| 12 | El cañadón | `desierto` | Combinar Disruptora con apoyo; auras y aturdimiento juntos. | **Espejo** (rebote). | Ídem. |
| 13 | Paso alto | `nieve` | Ataques **coordinados**: grupos mixtos con escolta (Guardián + Curandero + Chamán) y dos entradas. | — | Ídem (y el Lanzamisiles, si Q-28 lo aprueba). |
| 14 | Los poblados vacíos | `ruinas` | Todas las amenazas. Las señales culminan: las comunidades se retiraron. | — | Ídem. |
| 15 | **La Central** | `pradera` (valle) | **Final:** defender la central de energía y la cadena de abastecimiento. Mapa grande (hasta 26 × 12). El líder es un **jefe supremo nuevo**, el **Coloso** (una masa de piedra que se parte en tres Pedazos; diseño de T243 con RF-481 a RF-484 y D-092, elegido por Lucas el 2026-10-09; arte en T244) con escolta coordinada (Q-32, cambiado por Lucas el 2026-10-08). Epílogo ambiguo. | — | Todas las disponibles. |

Cada ficha detallada se completa en la tarea de cada nivel con lo que pide el 07 §3: posiciones, recursos, estrategia sin recursos, textos y transición.

---

## 6. Tablero de tareas

📜 = escribe RF o D (**solo una tarea 📜 a la vez**, para no pisar números). 🚦 = compuerta de Lucas. 🎨 = Lucas aprueba la ficha de arte antes de que Codex produzca.

### Fase 0 · Decidir
| T | Tarea | Ejecutor | Depende de | Tamaño |
|---|---|---|---|---|
| T199 | Este plan, el cuestionario y las fichas de delegación | Claude Opus | — | ✅ hecho |
| [T200](tareas/T200-decisiones-lucas.md) | 🚦 G1 · Responder el cuestionario 09 y aprobar las fichas de la sección 5 | **Lucas** | T199 | 1–2 h |

### Fase 1 · Base de la franquicia y herramientas
| T | Tarea | Ejecutor | Depende de | Tamaño |
|---|---|---|---|---|
| [T201](tareas/T201-biblia-universo.md) | 🚦 G2 · Biblia del universo (`specs/10-universo.md`) | Sonnet alto (ideal Opus) | T200, T202 | Mediano |
| [T202](tareas/T202-glosario-canonico.md) | Auditoría de nombres y propuesta de glosario | Sonnet bajo | — (puede arrancar ya) | Chico |
| [T203](tareas/T203-torres-por-mapa.md) | 📜 Torres por mapa (`"torres"` en el nivel) y aviso en la selección | Sonnet medio | T200 | Chico |
| [T204](tareas/T204-bot-semillas.md) | Bot de balance: varias semillas e informe por mapa | Sonnet medio | T200 (Q-07) | Chico |

### Fase 2 · Spec de sistemas
| T | Tarea | Ejecutor | Depende de | Tamaño |
|---|---|---|---|---|
| [T205](tareas/T205-spec-sistemas.md) | 📜 🚦 G3 · Spec, decisiones y plan técnico de removibles, demolición, demoledora, recursos, extracción y colecciones | Sonnet alto | T200, T203 | Mediano |

### Fase 3 · Sistemas (código, arte provisional)
| T | Tarea | Ejecutor | Depende de | Tamaño |
|---|---|---|---|---|
| [T206](tareas/T206-removibles-formato.md) | Removibles: formato, validación, `MapGrid` y `check_level` | Sonnet medio | T205 | Chico |
| [T207](tareas/T207-demolicion.md) | Demolición directa en la partida | Sonnet medio | T206 | Mediano |
| [T208](tareas/T208-demoledora.md) | Demoledora global | Sonnet medio | T207 | Chico |
| [T209](tareas/T209-recursos.md) | Recursos locales y torres que cuestan recursos | Sonnet medio | T207 | Mediano |
| [T210](tareas/T210-extraccion.md) | Extracción finita: minas y bosques | Sonnet medio | T209 | Mediano |
| [T211](tareas/T211-colecciones.md) | Colecciones por tecnología y hallazgos en ruinas | Sonnet medio | T207 | Mediano |
| [T212](tareas/T212-editor.md) | Editor: removibles, extracción, ruinas y torres del mapa | Sonnet medio | T203, T206, T210, T211 | Mediano |
| [T213](tareas/T213-modo-pruebas.md) | Modo de pruebas: recursos, colecciones y demolición instantánea | Sonnet bajo | T209, T211 | Chico |
| [T214](tareas/T214-bot-recursos.md) | Bot: estrategias sin recursos, demolición directa, demoledora y extracción | Sonnet medio | T204, T210 | Mediano |

### Fase 4 · Disruptora
| T | Tarea | Ejecutor | Depende de | Tamaño |
|---|---|---|---|---|
| [T215](tareas/T215-spec-disruptora.md) | 📜 Spec de la Disruptora | Sonnet alto | T200, T205 | Chico |
| [T216](tareas/T216-arte-disruptora.md) | 🎨 Arte de la Disruptora (concepto, atlas, base, ícono y pulso) | **Codex** | T215 | Mediano |
| [T217](tareas/T217-disruptora-codigo.md) | Disruptora: lógica, datos, Wiki e integración del atlas | Sonnet medio | T215, T209, T211 (T216 para el arte final) | Mediano |

### Fase 5 · Arte del bloque 2 (Codex)
| T | Tarea | Ejecutor | Depende de | Tamaño |
|---|---|---|---|---|
| [T218](tareas/T218-arte-senales.md) | 🎨 Señales de los habitantes (decoración) | **Codex** | T200, T201 (símbolos) | Chico |
| [T219](tareas/T219-arte-removibles.md) | 🎨 Removibles y ruinas: intacto, en trabajo y despejado | **Codex** | T205 | Mediano |
| [T220](tareas/T220-arte-extraccion.md) | 🎨 Mina y bosque explotable: activo, agotado y reserva | **Codex** | T205 | Chico |
| [T221](tareas/T221-arte-iconos.md) | 🎨 Íconos: recurso, piezas de colección y demoledora | **Codex** | T205 | Chico |

### Fase 6 · Campaña
| T | Tarea | Ejecutor | Depende de | Tamaño |
|---|---|---|---|---|
| [T222](tareas/T222-niveles-1-5-senales.md) | Niveles 1 a 5: señales y oasis, sin cambiar el juego | Sonnet bajo · *apto Qwen* | T200 (T218 para el arte final) | Chico |
| [T223](tareas/T223-niveles-6-7.md) | Niveles 6 y 7: bosque, removibles, primer drop de recursos y rebalance | Sonnet medio | T208, T209, T204 | Mediano |
| [T224](tareas/T224-niveles-8-9.md) | Niveles 8 y 9: ruinas, piezas 1 y 2, debut del Mortero y rebalance | Sonnet medio | T209, T211, T223 | Mediano |
| [T225](tareas/T225-nivel-10.md) | Nivel 10: la mina vieja (extracción y pieza 3/3; cierre del bloque 2) | Sonnet alto | T210, T211, T214, T224 | Mediano |
| [T226](tareas/T226-prueba-bloque-2.md) | 🚦 G4 · Lucas juega del 6 al 10 y llena el informe | **Lucas** | T225 | 2–3 h |
| T247 | 📜 🚦 Spec de la barra con pestañas (Cañones / Infraestructura) y de la flecha al menú (M53; sin ficha propia: se hizo desde el pedido de Lucas del 2026-10-08) | Sonnet alto + **Lucas** | T225 | Chico |
| [T248](tareas/T248-barra-con-pestanas.md) | Barra con pestañas y flecha al menú: código | Sonnet medio | T247 🚦, T207, T208, T210 | Mediano |
| [T227](tareas/T227-spec-lore-bloque-3.md) | 📜 Spec del lore en el juego (enmienda de §11), del bloque 3 y del final | Sonnet alto | T201, T226 | Mediano |
| [T228](tareas/T228-textos-wiki-lore.md) | Textos por nivel, pantalla de entrada y victoria, y categoría Lore en la Wiki | Sonnet medio | T227 | Mediano |
| [T229](tareas/T229-niveles-11-14.md) | Nivel 11 (y, con la misma ficha, 12, 13 y 14 como T230, T231 y T232) | Sonnet medio | T217, T227 | Mediano c/u |
| [T233](tareas/T233-arte-final.md) | 🎨 Central de energía, abastecimiento e imagen del final | **Codex** | T227 | Mediano |
| [T243](tareas/T243-spec-jefe-supremo.md) | 📜 🚦 Spec del jefe supremo del 15 (función, contramedidas, habilidad y textos) | Sonnet alto + **Lucas** | T227 | Chico |
| [T244](tareas/T244-arte-jefe-supremo.md) | ✅ 🎨 Arte del jefe supremo (aprobado por Lucas el 2026-10-16; cerrada en T444) | **Codex** | T243 | Mediano |
| [T234](tareas/T234-nivel-15.md) | Nivel 15 y epílogo | Sonnet alto | T228, T232, T243 (T233 y T244 para el arte final) | Mediano |
| [T235](tareas/T235-asedio-y-modos.md) | Asedio con 15 mapas y pulido de modos (**los 15 mapas los hizo T258**; quedan solapas y récords de modos, que piden un RF nuevo) | Sonnet bajo · *apto Qwen* (solo datos) | T234 | Chico |
| T252 | 📜 Spec de La Cuadrilla (M55, RF-485 a RF-491, D-094): los Rateros y el Cargador, y en qué niveles entran (medido con el bot). Sin ficha propia: salió del pedido de Lucas del 2026-10-10 sobre el informe de T251 | Sonnet alto | T251 | Chico |
| [T253](tareas/T253-cuadrilla-datos-y-reajuste.md) | Datos, oleadas y reajuste de La Cuadrilla (niveles 7, 10, 13 y 14), artículo de la Wiki y tests | Sonnet medio | T252 + el OK de Lucas a P1 de M55; **antes de T238** | Mediano |
| T257 | ✅ 🎨 Arte de La Cuadrilla (Ratero y Cargador, con ciclo de caminata); **no bloquea a T253**. Rehecho en T285 e integrado en T286 con Ratero B y Cargador A, elegidos por Lucas el 2026-10-16; cerrada en T444 | **Codex** | T252 | Mediano |
| T256 | 📜 Spec de Asedio con porcentaje de vida por mapa (M56, RF-492 a RF-496, D-095): los 15 mapas, 115 % global y una tabla opcional por id de mapa (medida en T255). Sin ficha propia: salió del pedido de Lucas del 2026-10-10 sobre el informe de T255 | Sonnet alto | T255 | Chico |
| [T258](tareas/T258-asedio-porcentajes-por-mapa.md) | ✅ **Hecha (2026-10-10).** Asedio con los 15 mapas y porcentaje de vida por mapa: la clave en `ModePacks`, los datos, las opciones del bot y los tests. **Resuelve los mapas de T235.** Queda **una fila a decidir por Lucas: el mapa 7 con la Cuadrilla** (ni 101 % da 3 vidas en las cinco semillas; ver el Resultado en `03-tareas.md`). *Dato posterior (T444): con el nivel 7 ajustado, T279 midió Asedio 7 al 101 %: 5 de 5 con 6 vidas; falta que Lucas lo confirme* | Sonnet medio | T256; **después de T253** (los mapas 7, 10, 13 y 14); **antes de T238** | Mediano |

### Fase 7 · Candidato de entrega
| T | Tarea | Ejecutor | Depende de | Tamaño |
|---|---|---|---|---|
| [T236](tareas/T236-regresion-rendimiento.md) | Regresión, guardados viejos, rendimiento P7 y auditoría de recursos | Sonnet medio | T234 | Mediano |
| [T237](tareas/T237-marca-exportaciones.md) | Marca (si Q-04) y exportaciones de Windows, Linux y Android | Sonnet bajo | T236 | Chico |
| [T238](tareas/T238-prueba-completa.md) | 🚦 G5 · Lucas juega del 1 al 15 desde un guardado nuevo, en PC y en celular | **Lucas** | T237 | 1–2 días |
| [T239](tareas/T239-publicacion.md) | Publicación: fuente pública y página (según Q-05) | **Lucas** + Sonnet bajo | T238 | Chico |

### Fase 8 · Intro (última)
| T | Tarea | Ejecutor | Depende de | Tamaño |
|---|---|---|---|---|
| [T240](tareas/T240-guion-intro.md) | ✅ 🚦 G6 · Guion de la intro (láminas) **· aprobado por Lucas el 2026-10-11** (`intro/guion.md`, M57, RF-497 a RF-501, D-096) | Sonnet alto + **Lucas** | T238 | Chico |
| [T241](tareas/T241-arte-intro.md) | ✅ 🎨 Láminas ilustradas con aspecto dibujado a mano (aprobadas por Lucas el 2026-10-11) | **Codex** | T240 | Mediano |
| [T242](tareas/T242-intro-integracion.md) | ✅ Intro: reproducir, omitir y volver a ver | Sonnet medio | T241 | Chico |

**Fuera del mínimo** (se anotan en §13 y van después de la entrega, salvo que Lucas diga otra cosa en el cuestionario):
- Lanzamisiles (Q-28). (El líder nuevo del 15 **sí entra** en la V1 por decisión de Lucas, Q-32: T243 y T244.)
- Transiciones de bioma extra.
- B-14, B-23, B-08, B-09, B-16, B-04, B-11, B-12, B-29 y B-30 (Q-06).

---

## 7. Orden y paralelismo

```
T200 (Lucas) ──┬─ T202 ─ T201 🚦G2 ───────────────────────────── T218 🎨 ─ T222
               ├─ T203 ─ T205 🚦G3 ─ T206 ─ T207 ─┬─ T208 ─ T223 ─ T224 ─┐
               ├─ T204 ───────────────────────────┼──────────────────────┤
               │                                  ├─ T209 ─ T210 ─ T214 ─┼─ T225 ─ T226 🚦G4
               │                                  └─ T211 ───────────────┘
               │          T205 ─ T215 ─ T216 🎨 / T217
               │          T205 ─ T219 / T220 / T221 🎨 (en paralelo, Codex)
T226 ─ T227 ─ T228 ─ T229..T232 ─ T234 ─ T235 ─ T236 ─ T237 ─ T238 🚦G5 ─ T239
                                  T233 🎨 ──┘
T227 ─ T243 🚦 ─ T244 🎨 ─ (T234)
T251 ─ T252 ─ T253 (antes de T238) ; T252 ─ T257 🎨 (en paralelo, sin bloquear)
T255 ─ T256 ─ T258 (después de T253 y antes de T238; los mapas de T235)
T238 ─ T240 🚦G6 ─ T241 🎨 ─ T242
```

**Orden vigente (2026-10-23, auditoría T444; reemplaza al diagrama para lo que falta):**
1. Una build de `main` y una sesión de Lucas con T280 (6→7→8 y variantes), T226 (6 a 10) y T283 (el 9 con el Mortero): cierra T266 o reabre el 2 o el 7, y decide RF-525.
2. Lucas revisa el arte: el resultado integrado de T277 (para T267), el arte de M71 (T362 a T369), cuyo PR #22 ya está mergeado en `main` (T489) pero con T364 y T369 sin medir y cuáles de T216, T218 a T221 y T233 pide para la 1.0.
3. Los agentes hacen lo que salga de 1 y 2, y la spec del resto de T235 si Lucas la quiere en la 1.0.
4. T268: build de envío identificada, versión y lista de salida de T375. Se retiró la validación del guardado viejo (Lucas, 2026-10-26); el análisis de guardados nuevos queda después de V1.
5. T238 🚦 G5 con guardado nuevo, en PC y celular; después, T239.

T128 queda diferida, fuera de la V1 (Q-06).

- **Ya pueden arrancar, sin esperar a Lucas:** T202 (es solo un informe).
- **Codex trabaja en paralelo** a la fase 3 en cuanto T205 fija los estados que hay que dibujar.
- **Sonnet:** como mucho dos agentes de código a la vez, en ramas separadas, y nunca dos tareas 📜 juntas.

---

## 8. Riesgos

| Riesgo | Cuidado |
|---|---|
| Que los recursos se vuelvan obligatorios de hecho. | En cada mapa con recursos, el bot gana con la estrategia `sin_recursos` (T214) y Lucas lo confirma jugando (G4 y G5). |
| Que se balancee dos veces. | Las reglas que cambian el balance (Q-06) se deciden en T200, antes de tocar los niveles. |
| Que un agente con poco contexto invente diseño. | Las fichas dicen "frenar y preguntar". Las ideas nuevas van a §13 como sugerencias. |
| Que dos agentes choquen en los números de RF o D, o en el CHANGELOG. | Una sola tarea 📜 a la vez; cada agente toca solo la entrada de su tarea y rebasa sobre `main` antes del PR. |
| Que el arte frene el código. | Arte provisional en código; Codex integra después. |
| Que Qwen 4B se equivoque en los datos. | Solo tareas con validador automático, y un Sonnet revisa el PR. |

## 9. Próximo bloque · pulido de desktop y mapa de campaña (pedido de Lucas, 2026-10-21)

La solicitud nueva queda en [B-45 a B-49](01-spec.md#pedidos-nuevos-de-lucas--escritorio-y-campaña-2026-10-21). **T425 escribe la spec primero**; las tareas de código esperan sus RF/decisiones y el OK de Lucas a las muestras de arte. La selección de niveles arranca en desktop; los cambios mobile se deciden aparte. El mapa comunica las estrellas/desbloqueos existentes: no inventa una campaña paralela.

| T | Entrega | Ejecutor previsto | Depende de | Tamaño |
|---|---|---|---|---|
| [T423](tareas/T423-revision-visual-t267a.md) | Guía visual grande para revisar las muestras T267a | Gemini · documental | Informe T267a | Chico |
| T424 | Registrar los pedidos y subdividirlos en tareas delegables | Codex · orquestación/documentación | Dirección de Lucas | Chico |
| [T425](tareas/T425-spec-pulido-desktop.md) | 📜 Spec, decisiones, plan y fichas de B-45 a B-49 | Claude · spec y arquitectura | T424 | Mediano |
| [T426](tareas/T426-selector-tarjetas-desktop.md) | Selector actual: 15 niveles visibles, sin número de oleadas, torres integradas y fondos temáticos | Gemini · UI desktop | T425 | Mediano |
| [T427](tareas/T427-mapa-planetario-arte.md) | 🎨 Muestra de mapa planetario y zonas con tres estados | Codex · concepto de arte | T425; OK de Lucas | Mediano |
| [T428](tareas/T428-selector-mapa-planetario.md) | Segundo estilo: mapa 2D con aterrizaje, zonas y progreso | Claude · lógica e integración | T425, T426, T427 aprobada | Grande |
| [T429](tareas/T429-tarjeta-entrada-nivel-desktop.md) | Tarjeta de entrada coordinada con la identidad visual por nivel | Gemini · UI desktop | T425, T426 | Chico |
| [T430](tareas/T430-panel-torre-desktop.md) | Panel de torre compacto, claro, translúcido y accesible | Gemini · UI desktop | T425 | Mediano |
| [T431](tareas/T431-caminata-izquierda.md) | Auditoría y propuesta de bajo costo para las caminatas a izquierda | Codex · arte y estimación | Inventario de sprites; OK antes de producir | Chico |
| [T432](tareas/T432-variedad-torres-estrellas.md) | Informe de uso de torres, vidas y estrellas de niveles 1–4 | Claude · análisis | Datos disponibles; feedback de Lucas | Chico |

### Paralelismo y límites de los agentes

1. **En serie al inicio:** Lucas ya dio la dirección; T424 quedó registrado. Claude completa T425 y fija los contratos; no se escriben RF desde dos agentes al mismo tiempo.
2. **En paralelo tras T425:** Gemini trabaja T426; Codex prepara T427 y T431 en worktrees separados; Claude analiza T432. T427 se presenta a Lucas antes de integrar su arte.
3. **Después de T426:** Gemini hace T429 y T430 en ramas separadas; Claude integra T428 cuando las bases están aprobadas. Evitar que dos ramas modifiquen simultáneamente las escenas compartidas del selector.
4. **Opencode con modelo local** queda limitado a tareas rutinarias de Git (revisión simple, commit o push bajo instrucciones), nunca para diseño, spec, balance o refactors. Gemini, Claude y Codex son los ejecutores del trabajo sustantivo.
5. Cada tarea tiene su propio worktree, rama `feature/`, commit y PR. La integración permanece a cargo de Lucas; ningún agente mergea.
## 10. Decoración de campaña y posible editor de estandartes (2026-10-21)

B-50 se implementa en T437: rehacer tronco, helecho y poste en el acabado dimensional de T277, y cambiar la variante del poste del nivel 6 según SaveManager.is_completed() de la campaña. La muestra queda en el PR para que Lucas la revise; D-183 está propuesta, no se declara aprobación artística. No se agrega progreso ni se exige una cantidad concreta de estrellas.

B-51 queda como análisis futuro. Opus recomienda alcance y decisiones para un editor cosmético acotado; no se construye el editor hasta que Lucas decida el MVP. La skill genérica de Godot se mantiene en el repositorio Godot-Skills y en un PR independiente.

## 11. Hub de herramientas y editor de banderines (M74; pedido de Lucas, 2026-10-22)

| T | Entrega | Ejecutor previsto | Depende de | Tamaño |
|---|---|---|---|---|
| T439 | ✅ Spec, decisiones, plan y fichas para editor de banderines + hub (PR #41) | Codex · documental, Opus ya analizó | Autorización de Lucas | Chico |
| T440 | ✅ Muestra visual del catálogo cerrado a 220/34 px (PR #44; aprobada por Lucas) | Codex · arte | T439; aprobación antes de arte final | Chico |
| T441 | ✅ Hub Herramientas y continuidad del editor de mapas (PR #42) | Sonnet · UI/flujo | T439 | Chico |
| T442 | ✅ Catálogo, receta validada y persistencia aislada (PR #43) | Sonnet · lógica | T439 | Mediano |
| T443 | ✅ UI del editor, preview y aplicación al poste del nivel 6 (PR #45) | Sonnet · integración; revisión Codex | T440 aprobada, T441 y T442 | Mediano |

**Estado (2026-10-23, auditoría T444):** M74 está completo e integrado en `main` (`c120ac3`). Fuera de su alcance quedan el celular, el mapa planetario, el texto libre y compartir recetas.

**Orden:** T439 define los contratos. T441 y T442 pueden implementarse en ramas independientes desde su base especificada. T440 puede preparar muestras en paralelo; T443 espera aprobación visual de Lucas y las dos piezas funcionales. Cada tarea conserva su propia rama `feature/`, commit y PR a `main`; ningún agente mergea. Opus ya completó el análisis T438. Claude Sonnet implementa UI/lógica, Gemini puede hacer revisión independiente cuando esté disponible, Codex revisa arte, pruebas e integración. Opencode local se limita a Git rutinario.


## 12. Enmienda vigente · selector, modos y postes (T459; 2026-10-23)

M76 registra las decisiones finales de T449 con RF-687–698/D-198–203, tras la numeración reservada de T458. T459 entrega spec/plan/fichas y espera OK de Lucas antes del código. T469 muestra planeta nuevo e insignias (Codex, compuerta de arte); T470 implementa mapa inicial/interacción/migración PC y celular; T471 integra geografía tras aprobación; T472 implementa acceso a Asedio y migración; T473 absorbe el resto de T235 (solapas/récords); T474 unifica insignias/números; T475 incorpora postes solo con OK por cada uno de los 15 mapas. T235 queda retirada como ejecución independiente, sin declarar implementado su remanente.

Las recomendaciones anteriores de T449 de excluir celular o diferir el acceso por campaña fueron reemplazadas por Lucas. No se aprueba el grupo Desafíos por inferencia. Geografía/insignias requieren muestra, las posiciones siguen propuestas. El mapa inicial puede actualizarse con la geografía nueva cuando esté aprobada. T470/T471/T473/T474 se serializan por archivos del selector; T472 coordina SaveManager/GameFlow con T461/T458 y T475 espera el propietario libre de game.gd. No más de dos agentes de código y una tarea 📜 a la vez.

T453 (T280/T226/T283), teléfono real T454, mediciones limpias T364/T369, versión T268 y G5 T238/publicación T239 mantienen sus compuertas humanas. Asedio 7 al 101 % lo confirma Lucas en G5, sin cambiar balance. Esta enmienda no cierra ninguna partida ni aprobación de arte.

## 13. Enmienda vigente · franjas y carga (T460; 2026-10-23)

M77 fija RF-699–707/D-204–206 tras los rangos T458/T459, sin reutilizar propuestas provisionales de T450. T460 es documental, espera revisión/OK antes de código. T476 propone superficie física y marco lógico fijo (no expand jugable), T477 muestra fondos por terreno (Codex, compuerta), T478 los integra después de aprobación. T479 (láminas de intro rotativas) espera además **anexo al informe T454 con medición en celular real y aprobación escrita de Lucas con esos datos**. No se afirma que la elección condicionada ya autoriza implementar.

T476/T478/T479 se serializan por GameFlow/SceneTransition/Game/cámara y con jefes T461, cámara T464, postes T475 y versión T268 cuando corresponda. Fondo fijo y zoom máximo 1,0 preservan mecánicas. Los cambios de root/host/input requieren revisión pesada y regresión; no se compensan agrandando mapa/HUD. T454 puede medir primero las láminas actuales/intro en build de main identificada, sin integrar la función bloqueada. Ninguna captura simulada ni medición PC sustituye teléfono, T453 o G5.
