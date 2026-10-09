# 08 — Plan de cierre de Monsters & Canons V1, dividido en tareas

Fecha: 2026-10-07. Lo preparó Claude (Opus 5.5) a pedido de Lucas, a partir de [07-lore-y-cierre-v1.md](07-lore-y-cierre-v1.md), del backlog (§13 de la spec) y del estado real del repositorio.

> **Qué es:** el plan de trabajo para terminar la V1. Son 15 niveles con su lore y los sistemas que pide el 07 (demolición, recursos, extracción, colecciones y Disruptora), más la **base de la franquicia**. Está dividido en tareas `Txxx`. Cada una tiene su **ficha de delegación** en [`specs/tareas/`](tareas/), lista para pasársela a otro agente.
>
> **Qué no es:** no es la spec. Los `RF` y las `D` los escriben las tareas de spec (📜) después de que Lucas responda el cuestionario [09-decisiones-pendientes-v1.md](09-decisiones-pendientes-v1.md). Las fichas de mapa de la sección 5 son **propuestas de Claude**: no están aprobadas.
>
> **Fuera de este plan (Lucas, 2026-10-07):** M&C 3D (documento 06), M&C 2 y Épocas. Tampoco se adelanta nada técnico pensado solo para el 3D, como separar la simulación de la vista.

---

## 1. Quién hace qué

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
| [T244](tareas/T244-arte-jefe-supremo.md) | 🎨 Arte del jefe supremo | **Codex** | T243 | Mediano |
| [T234](tareas/T234-nivel-15.md) | Nivel 15 y epílogo | Sonnet alto | T228, T232, T243 (T233 y T244 para el arte final) | Mediano |
| [T235](tareas/T235-asedio-y-modos.md) | Asedio con 15 mapas y pulido de modos | Sonnet bajo · *apto Qwen* (solo datos) | T234 | Chico |

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
| [T240](tareas/T240-guion-intro.md) | 🚦 G6 · Guion de la intro (láminas) | Sonnet alto + **Lucas** | T238 | Chico |
| [T241](tareas/T241-arte-intro.md) | 🎨 Láminas ilustradas con aspecto dibujado a mano | **Codex** | T240 | Mediano |
| [T242](tareas/T242-intro-integracion.md) | Intro: reproducir, omitir y volver a ver | Sonnet medio | T241 | Chico |

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
T238 ─ T240 🚦G6 ─ T241 🎨 ─ T242
```

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
