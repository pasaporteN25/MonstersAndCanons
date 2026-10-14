# T202 · Auditoría de nombres y propuesta de glosario canónico

**Fecha:** 2026-10-08 · **Ejecutor:** Sonnet 5.5 · **Estado:** informe para que Lucas elija en G2 (junto con T201). **No se cambió ningún archivo del juego ni de la spec.**

## Cómo se hizo y qué límites tiene
- Se leyeron `data/towers/*.tres`, `data/enemies/*.tres`, `data/wiki/*.json`, `scripts/logic/wiki.gd`, `scripts/logic/map_themes.gd`, `data/levels/level_0*.json`, `CONTENIDO.md`, `README.md`, `ONBOARDING.md`, `CHANGELOG.md`, la guía de arte (§3, §4, §7, §8, M37–M43), la spec (RF-151, RF-276, RF-286, RF-326, RF-358 a 365, M37) y el lore (06, 07, 08).
- **Qué no se hizo:** no se abrió el juego ni se miraron los PNG uno por uno. Dónde "el dibujo ya no coincide" se dedujo de lo que dicen los documentos de arte (M24, M25, M27, M31, M43) y de las aprobaciones de Lucas; **no está verificado a ojo**. Lo dudoso va como pregunta (§5).
- "Nombre en el juego" = el `display_name` del `.tres` (es lo que ve el jugador en la Wiki, el HUD y los paneles).
- Regla para proponer: **gana el nombre que hoy ve el jugador**, salvo que choque con el lore del 07.

---

## 1. Torres (10)

| Id en código | Nombre en el juego | Otros nombres encontrados (archivo:línea) | Propuesta canónica | Motivo |
|---|---|---|---|---|
| `basic` | Ametralladora | "Básica" (`specs/05-guia-de-arte.md:77`, `art/redesign-m27/preview.gd:6`); "ametralladora" en `data/wiki/armadura_y_dano.json` | **Ametralladora** | Es lo que lee el jugador; "Básica" es el id viejo. Corregir la guía y los títulos de arte. |
| `burst` | Ráfaga | "burst" en `CONTENIDO.md` (es el id, no un nombre) | **Ráfaga** | Sin conflicto de nombre. |
| `cannon` | Cañón | "Canón" / "cañon" sin tilde en `specs/05-guia-de-arte.md:100` y `CONTENIDO.md:430` (ahí es "canónico", falso positivo; ver §4 sobre "Canons" del título) | **Cañón** | Solo hay que revisar la ortografía. |
| `fire` | Incendiaria | "Fuego" / "fuego" (`art/redesign-m27/preview.gd:6`, guía §7 línea 77, `data/wiki/efectos.json`, `armadura_y_dano.json`) | **Incendiaria** (la torre); **fuego** (el efecto de quemadura) | El nombre de la torre y el del efecto son cosas distintas y hoy se mezclan. |
| `frost` | Hielo | "Hielo" también como efecto/material (`efectos.json`, `enemigos_especiales.json`) | **Hielo** (la torre y su efecto de frenar) | Aceptable: en la Wiki la torre y el efecto se llaman igual. Solo anotar la decisión. |
| `mechanical_standard` | Estandarte mecánico | "Mecánico" (`README.md:8,255`, `ONBOARDING.md:406`, `CONTENIDO.md:412`, guía M37/M43, `data/enemies/rammer.tres:9`); "Estandarte" (`specs/01-spec.md:1227`, `README.md:243`); "estatua" (descripción del `.tres`, `README.md:256`); "reparador" (`README.md:255`) | **Estandarte mecánico** (nombre completo) y **Estandarte** (corto). Dejar de usar "Mecánico" como sustantivo de la torre | Hoy hay cuatro nombres para la misma torre. "Mecánico" suena a enemigo o personaje; además el Embestidor dice "el Mecánico repara el desgaste". Id en código: ver pregunta Q-3. |
| `mortar` | Mortero | — | **Mortero** | Sin conflicto. |
| `multi` | Múltiple | — | **Múltiple** | Sin conflicto. |
| `sniper` | Francotirador | — | **Francotirador** | Sin conflicto. |
| `tesla` | Eléctrica | "Tesla" (guía §7 línea 78, `specs/07-lore-y-cierre-v1.md:221,223,340`, `art/redesign-m27/preview.gd:6`) | **Eléctrica** en el juego; "Tesla" queda solo como id y apodo interno | El 07 la compara con la futura Disruptora usando "Tesla". Conviene que el 07 diga "Eléctrica (id `tesla`)" para no tener dos torres con nombres parecidos. |

**Futura (no existe aún):** **Disruptora** (`specs/07-lore-y-cierre-v1.md:195,224,340`, tareas T215 a T217). Sin conflicto por ahora.

## 2. Enemigos (15)

"Especie" = lo que escribe la guía §3. "Dibujo actual" = lo que dicen los documentos de arte posteriores.

| Id en código | Nombre en el juego | Otros nombres encontrados (archivo:línea) | Propuesta canónica | Motivo / ¿el dibujo coincide? |
|---|---|---|---|---|
| `normal` | Normal | "Lobo de ceniza (gris azulado)" (guía §3 línea 34); "lobo gris con crin" (`specs/03-tareas.md:385`); "diablillo rojo" (guía §8, `specs/01-spec.md:1478`, `CHANGELOG.md:44`, `art/redesign-m25/HANDOFF_CLAUDE.md:9`); "Diablillo" (`art/redesign-m29/capture.gd:7`) | **Normal** (nombre) · especie **diablillo rojo** | **Desfasado:** la guía §3 describe un lobo gris azulado, pero M24 lo reemplazó por un diablillo rojo. La paleta de §3 ya no corresponde al dibujo. |
| `fast` | Rápido | "Lagarto corredor (ámbar)" (guía línea 35); "bestia turquesa" (guía §8, `CHANGELOG.md:44`); "Bestia" (`art/redesign-m29/capture.gd:7`); "bestia reptiliana" (`art/PLAN_REDISENO_M24.md:13`) | **Rápido** · especie **bestia turquesa** | **Desfasado:** ámbar en la guía, turquesa en el dibujo. |
| `tank` | Tanque | "Behemot acorazado (marrón)" (guía línea 36); "ogro de piedra y piel verde" (guía §8, `specs/01-spec.md:1478`); "ogro verde" (`art/FORMATO_PROXIMA_ENTREGA_M24.md:7`); "behemot" (`specs/06-monsters-canons-3d.md:275`) | **Tanque** · especie **ogro de piedra** | **Desfasado:** marrón en la guía, verde en el dibujo. Ojo: ahora comparte verde con el Troll (verde musgo); la guía §4 pide revisar que no se confundan. |
| `armored` | Blindado | "Escarabajo rinoceronte (azul acero)" (guía línea 37); "escarabajo/Blindado" (`art/redesign-m25/README.md:12`) | **Blindado** · especie **escarabajo acorazado** | Coincide en lo esencial. Unificar "rinoceronte" / "acorazado". |
| `flyer` | Volador | "Wyvern (violeta)" (guía línea 38); "murciélago de alas en punta" (`specs/03-tareas.md:385`, versión vieja); "dragón alado violeta" (`03-tareas.md:388`); "gárgola" (`art/PLAN_REDISENO_M24.md:31`, `art/redesign-m25/README.md:12`) | **Volador** · especie **wyvern** | Cuatro bichos distintos según el archivo. No sé cuál tiene hoy el PNG de M25 (ver Q-5). |
| `boss` | Jefe | "Soberano (carmesí)" (guía línea 39, `specs/tareas/T234-nivel-15.md`, `specs/08-plan-cierre-v1.md:140`); "soberano cornudo" (`art/redesign-m27/preview_specials.gd:5`); "gran demonio de asedio" (`art/PLAN_REDISENO_M24.md:32`); `hud.tscn:42` "¡Llega el Jefe!" | **Jefe** (rol, en pantalla) · **el Soberano** (personaje del lore, nivel 15) | `specs/06-monsters-canons-3d.md:286` y T201 dejan "quién es el Soberano" sin definir. Conviene definir si cada nivel tiene "un jefe" o si el Soberano es **uno solo** (Q-4). |
| `troll` | Troll | "Troll de musgo (verde)" | **Troll** | Sin conflicto. |
| `spider` | Araña | "Matriarca (verde azulado)" (guía línea 41); "araña madre" (`06-monsters-canons-3d.md:275`) | **Araña** · especie **araña madre** | "Matriarca" y "araña madre" son lo mismo; elegir uno para el lore. |
| `spiderling` | Cría | "Cría de araña" (guía línea 42) | **Cría** | Sin conflicto. |
| `guardian` | Guardián | "Gólem de piedra (marfil) con escudo dorado" (guía línea 43, RF-276) | **Guardián** · especie **gólem de piedra** | Coincide. |
| `healer` | Curandero | "Criatura con un bulbo luminoso (verde amarillento)" (guía línea 44, RF-276, `art/redesign-m27/preview_specials.gd:5` "bulbo vital"); "criatura de hongos sanadora" (`PLAN_REDISENO_M24.md:32`); M43: "criatura erguida vegetal, semilla medicinal" (guía línea 100) | **Curandero** · especie **criatura vegetal erguida con semilla medicinal** (la de M43) | **Desfasado:** M43 (aprobado por Lucas el 2026-10-04) cambió el aspecto; la guía §3 y RF-276 siguen con el bulbo, y la Wiki/`CHANGELOG.md` ya hablan de la semilla. |
| `shaman` | Chamán | "Encapuchado con bastón que chispea (rosa magenta)" (guía línea 45, RF-286) | **Chamán** | Coincide. Pero **dos enemigos "encapuchados"** (Chamán y Ladrón): conviene que el glosario los distinga (ver Ladrón). |
| `mirror` | Espejo | "Tortuga de cristal facetado (cian frío)" (guía línea 46, RF-286); "criatura de cristal reflectante" (`PLAN_REDISENO_M24.md:32`) | **Espejo** · especie **tortuga de cristal** | Coincide. |
| `rammer` | Embestidor | "Bestia B reservada de M24" (guía línea 97, M39–M41); "anatomía pesada del antiguo Curandero" (guía línea 100, M43) | **Embestidor** · especie **bestia acorazada con casco de cuerno** | **Desfasado:** la guía M39 habla de una bestia reservada; M43 lo rehízo desde el Curandero viejo. **No está en la tabla de colores de la guía §3.** |
| `thief` | Ladrón | "vector nativo encapuchado con bolsa" (guía línea 97); M43: "encapuchado gris violeta desaturado" (línea 100); `specs/07-lore-y-cierre-v1.md:35` ("criaturas especiales o mágicas independientes") | **Ladrón** · especie **encapuchado gris violeta** | **No está en la tabla de §3.** El 07 lo trata como criatura **independiente** (no bestia); el glosario debería fijar una categoría (ver §3). |

**Hueco general de la guía §3:** la tabla tiene **13 filas** y el juego tiene **15 enemigos**: faltan **Embestidor y Ladrón**. Además §8 dice "los otros diez enemigos siguen con las reglas de §1–2" y eso quedó viejo: `README.md:220,226` dicen que ya son trece los renderizados.

**Conteos que no coinciden entre documentos:** `README.md:217,220,223` dicen "nueve torres" y "trece monstruos"; `specs/01-spec.md:1467` (RF-326) dice "las nueve torres". Hoy son **10 torres y 15 enemigos** con el Estandarte, el Embestidor y el Ladrón. Si "nueve" se refiere a "las nueve de oro" (sin el Estandarte), conviene escribirlo así.

## 3. Categorías de enemigos (propuesta)
Hoy el 07 usa "bestias", "criaturas especiales o mágicas independientes" y el README "monstruos". Propuesta para el glosario:
- **Bestia:** Normal, Rápido, Tanque, Blindado, Volador, Troll, Araña, Cría, Embestidor, Jefe.
- **Criatura (especial/independiente):** Guardián, Curandero, Chamán, Espejo, Ladrón.
- **"Monstruo"** queda como palabra genérica de los textos de marketing/README.
Esto es una **propuesta**: el 07 no cierra la lista y es decisión de Lucas (Q-6).

## 4. Temas del mapa (7)

Los ids son los de `scripts/logic/map_themes.gd:14-20`. Los nombres de nivel salen de `data/levels/*.json`. **Ningún nivel de la campaña usa `tema` todavía** (`specs/08-plan-cierre-v1.md:31`); el jugador hoy no ve el nombre del tema en ningún lado.

| Id en código | Nombre en el juego | Otros nombres encontrados | Propuesta canónica | Motivo |
|---|---|---|---|---|
| `pradera` | (no se muestra) | "Pradera" es también el **nombre del nivel 1** (`level_01.json`) y "valle" en el plan 08 (`:140`, nivel 15) | **Pradera** (tema) | Choque de nombre tema/nivel: el nivel 1 "Pradera" y el tema `pradera` se confunden. Aceptable si se escribe "tema Pradera" / "nivel Pradera". |
| `desierto` | (no se muestra) | "zonas secas" (`07-lore…:60`) | **Desierto** | Sin conflicto. |
| `nieve` | (no se muestra) | "pasos" (`07-lore…:60`); guía §4 "nieve" | **Nieve** | Sin conflicto. |
| `volcan` | (no se muestra) | `README.md:149` "volcán" (con tilde) | **Volcán** (el id queda sin tilde) | Solo ortografía del texto. |
| `bosque` | (no se muestra) | "lindero", "aserradero" (nombres de nivel en el plan 08) | **Bosque** | Sin conflicto. |
| `pantano` | (no se muestra) | — | **Pantano** | Sin conflicto. Ningún nivel de los planes 08 lo usa todavía. |
| `ruinas` | (no se muestra) | "Ruinas" como obstáculo y como colección (07 §6, §8) | **Ruinas** (tema) · **ruina** (objeto explotable del mapa) | El 07 usa la palabra para tres cosas: tema visual, obstáculo y colección. Conviene separarlas (Q-7). |

Nombres de los 9 niveles actuales: Pradera, Desfiladero, Encrucijada, Espiral, Fortaleza, Nido, Cruce, Bastión, Taller asediado. No hay duplicados entre niveles.

## 5. Conceptos

| Concepto | Nombre en el juego | Otros nombres encontrados (archivo:línea) | Propuesta canónica | Motivo |
|---|---|---|---|---|
| El juego | `config/name="JuegoA"` (`project.godot:13`), ejecutable `JuegoA.exe` | "Monsters & Canons" (`README.md:8,139`, `CHANGELOG.md:44`, logo); "Torres y Bestias" (nombre del modo, `specs/01-spec.md:1202`); "M&C 3D" (`06-monsters-canons-3d.md`) | **Monsters & Canons** (título público); `JuegoA` solo como nombre interno de proyecto | Tres nombres para el mismo producto. Además **"Canons"** en inglés significa "cánones/reglas"; el arma es "cannons" (Q-1). |
| Pieza de tecnología | "Avances tecnológicos" (HUD: `scenes/game/hud.gd:100,385`); "Avance de este nivel" (`level_select.gd:310`) | "avances científicos" (`07-lore…:159,169`); "fuente" (`scripts/autoload/save_manager.gd:29`, `art/progression-m37/README.md`); "pieza" (`07-lore…:188,195`; plan 08 "pieza 1/3"); "drop" (`art/progression-m37/README.md`) | **Avance** (lo que ve el jugador) · **fuente** solo en código (de dónde sale) · **pieza** = una unidad de una colección | Tres palabras para lo mismo. Ver Q-8. "Científico" (07) contra "tecnológico" (HUD): elegir uno. |
| Colección | "Colección" (`scripts/logic/collectible_run.gd:1`, `data/progression.json`) | "avances" (cuando se habla del total), "colecciones por tecnología" (`07-lore…:245`) | **Colección** = conjunto de piezas que desbloquea algo; **avance** = una pieza | Hoy el HUD dice "Avances" para la colección entera (`level_select.gd:310`: "cinco avances"). |
| Estandarte | Ver torre `mechanical_standard` | Ídem §1 | **Estandarte mecánico** | Ídem. |
| Desgaste / reparación | "desgaste" (`data/enemies/rammer.tres`, README M41) | "daño" a la torre (`README.md:256`) | **Desgaste** (lo que le hace el Embestidor a una torre); **daño** solo para enemigos | Mantener las dos palabras separadas. |
| Aturdimiento | "aturdir" (Chamán, Espejo) | "apagar la torre" (`data/enemies/shaman.tres`); "stun" en código | **Aturdimiento** (la torre aturdida) | El Chamán dice "apaga", el Espejo "aturde", el 07 también: es el mismo estado. |
| Modo de pruebas | "Modo de pruebas" (Opciones, RF-383) | "modo prueba" (`art/progression-m37/README.md:5`), "Pruebas" (`level_select.gd:220`), "admin F1" | **Modo de pruebas** | Solo texto. |

## 6. Preguntas para Lucas (G2)
- **Q-1.** "Monsters & Canons": ¿"Canons" es a propósito (juego de palabras con "cánones") o debería ser "Cannons" / "Cañones"? Afecta logo, README y todos los textos.
- **Q-2.** ¿Se aprueba el criterio "gana el nombre que ve el jugador" (ej.: Ametralladora, Incendiaria, Eléctrica, aunque la guía y el 07 digan Básica, Fuego, Tesla)?
- **Q-3.** El Estandarte: ¿se llama **Estandarte mecánico** en todos lados y se abandona "Mecánico"? Cambiar el id `mechanical_standard` **no** hace falta.
- **Q-4.** El **Soberano**: ¿es **un solo** personaje (el Jefe del nivel 15, líder de las bestias) o el nombre de la especie de todos los Jefes? Lo pide T201.
- **Q-5.** El **Volador**: ¿el dibujo actual (M25) es el wyvern violeta, la gárgola o el dragón? La guía §3 dice wyvern; M24/M25 dicen gárgola. Hay que mirar el PNG.
- **Q-6.** ¿Aprobás las categorías Bestia / Criatura (§3 del informe)? El Ladrón está en el 07 como "independiente".
- **Q-7.** "Ruinas": ¿tema visual, obstáculo explotable y colección pueden compartir la palabra, o se separan ("ruina", "yacimiento", "colección de la Disruptora")?
- **Q-8.** "Avance" / "pieza" / "fuente": ¿qué palabra ve el jugador? Propuesta: **avance** (la pieza) y **colección** (el conjunto); "tecnológico" en lugar de "científico".
- **Q-9.** ¿Se actualiza la tabla de colores de la guía §3 a lo que se dibujó (diablillo rojo, bestia turquesa, ogro verde, Curandero M43) y se agregan Embestidor y Ladrón? No hay que tocar ningún PNG.

## 7. Archivos que habría que cambiar si Lucas aprueba (no se tocaron)
**Documentos:**
- `specs/05-guia-de-arte.md`: tabla §3 (filas Normal, Rápido, Tanque, Volador, Curandero, Jefe, Araña; agregar Embestidor y Ladrón); §7 (Básica → Ametralladora, Fuego → Incendiaria, Tesla → Eléctrica); §8 ("los otros diez enemigos" ya quedó viejo).
- `specs/01-spec.md`: RF-276 (descripción del Curandero), RF-326 ("nueve torres"), RF-151 (bestias) y las tablas de enemigos de §7 si cambian categorías. **Solo una tarea 📜 puede editar RF** (protocolo del README de fichas), así que esto lo hace T201 o T227, no esta tarea.
- `specs/07-lore-y-cierre-v1.md`: "Tesla" (líneas 221, 223, 340), "avances científicos" (159, 169), "ruinas" (§6, §8) y el Soberano.
- `specs/06-monsters-canons-3d.md`: lista de especies (línea 275) y "quién es el Soberano" (286).
- `specs/08-plan-cierre-v1.md` y `specs/tareas/T234-nivel-15.md`: Soberano / Jefe.
- `README.md` (líneas 8, 217, 220, 223, 226, 243–256) y `ONBOARDING.md` (394–415): "Mecánico" → "Estandarte mecánico", conteo de torres y monstruos.
- `CONTENIDO.md` (252, 401, 412): "Mecánico", "estatua".
- `CHANGELOG.md`: solo si cambia algo que ve quien juega.

**Datos y código (solo textos, ningún número):**
- `data/enemies/rammer.tres` (descripción: "el Mecánico repara" → "el Estandarte repara").
- `data/towers/mechanical_standard.tres` (descripción: "Estatua de ingeniería").
- `data/enemies/shaman.tres` ("apaga" → "aturde", si se aprueba "aturdimiento" como palabra única).
- `scenes/ui/level_select.gd:310` y `scenes/game/hud.gd:100,385` si cambia "Avances tecnológicos".
- `art/redesign-m27/preview.gd:6` y `preview_specials.gd:5`, `art/redesign-m29/capture.gd:7`, `art/redesign-m30/capture.gd:7` (rótulos de capturas; no afectan al juego).

**Arte:** ningún PNG ni SVG hay que rehacer por nombres. Sí hay que **revisar a ojo** (Q-5, Q-9) el Volador y confirmar que Tanque (verde) y Troll (verde musgo) se distinguen sobre el bosque y el pantano.
