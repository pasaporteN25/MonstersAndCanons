# Fichas de delegación · cierre de la V1

Cada archivo `Txxx-*.md` es una tarea del [plan 08](../08-plan-cierre-v1.md), escrita para **pasársela tal cual a un agente** (Sonnet, Codex o Qwen). Esta página es el **protocolo común**: toda ficha lo da por leído.

**Cómo delegar:** abrir una sesión nueva en la carpeta del proyecto y decir:

> Leé `specs/tareas/README.md` y hacé la tarea `specs/tareas/Txxx-….md`.

---

## 1. Antes de empezar (todos)

1. **Comprobar las dependencias.** Mirar en `specs/03-tareas.md` que las tareas de "Depende de" estén en `[x]`. Si una no está, **no empezar**: avisar.
2. **Comprobar la compuerta.** Si la ficha dice 🚦 o 🎨 y la aprobación de Lucas no está registrada (en `specs/09-decisiones-pendientes-v1.md`, en `specs/04-decisiones.md` o en la entrada de la tarea), **no empezar**.
3. **Leer**, en este orden:
   - `CLAUDE.md`
   - `specs/00-constitucion.md`
   - las reglas de `.claude/rules/` de las carpetas que se van a tocar
   - las secciones que pide la ficha, y nada más: la spec es larga (1600 líneas), así que leer solo los `RF` nombrados.
4. **Rama:** `git checkout main && git pull` y después `git checkout -b feature/txxx-nombre-corto`. Siempre con el prefijo `feature/`, nunca `codex/` (regla de Lucas).

## 2. Entorno de esta máquina (Linux)

`CLAUDE.md` describe la instalación de Windows. En esta máquina:

```bash
godot --version                                                         # 4.7.2.stable (/usr/local/bin/godot)
godot --headless --import                                              # si hay archivos o class_name nuevos
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit   # todos los tests (~30 s)
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_x.gd -gexit
godot --headless --path . -s tools/check_level.gd -- data/levels/level_10.json   # revisar un nivel (ver el encabezado del script)
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix level=3  # bot de balance
```

- **Línea de base (2026-10-07):** 1017/1017 tests, sin `SCRIPT ERROR`. Una tarea **no puede terminar con menos tests en verde que al empezar**.
- Un test que pasa pero imprime `SCRIPT ERROR` o `Parse Error` **es un fallo**. Revisar la salida completa: `… 2>&1 | grep -c "SCRIPT ERROR\|Parse Error"` tiene que dar 0.
- `--import` a veces reescribe los SVG de `assets/sprites/`. Antes del commit, correr `git status` y devolver con `git checkout -- <archivo>` lo que no se tocó a propósito.
- Los tests que escriben guardados usan `user://test_*.json`. Nada de tests que cambien de escena (`.claude/rules/tests.md`).

## 3. Cómo se trabaja (SDD, resumido de `CLAUDE.md`)

- **Spec → decisión → plan → tareas → código y tests → commit.** Si la ficha es de código y el `RF` que tiene que cumplir **no existe todavía**, **frenar**: falta su tarea 📜.
- **Solo las tareas 📜 crean `RF-xxx` o `D-0xx`**, y **de a una por vez** (lo marca el tablero del plan 08). Antes de numerar, hacer `git pull` y tomar **el siguiente libre**: `grep -o 'RF-[0-9]*' specs/01-spec.md | sort -t- -k2 -n | tail -1`. Los números nunca se reusan.
- **Los números de balance van en `data/`**, nunca en el código (`.claude/rules/datos.md`).
- **El código va en inglés; los documentos, comentarios y textos del juego, en español rioplatense**, claros y detallados (P9).
- **Si algo ya escrito cambia, se actualiza en todos lados:** spec, plan, `CONTENIDO.md`, `README.md`, `ONBOARDING.md` y `CHANGELOG.md`.
- **Las ideas propias no se implementan.** Se anotan en `specs/01-spec.md` §13, "Sugerencias de Claude (consultar antes de implementar)".
- **Arte provisional:** un sistema nuevo se dibuja con `_draw` o con figuras simples, siguiendo los colores de la guía, hasta que llegue el asset de Codex. Nunca esperar al arte.

## 4. Cerrar la tarea

1. Tests completos en verde y sin `SCRIPT ERROR`.
2. En `specs/03-tareas.md`, **en la entrada de tu tarea y en ninguna otra**: marcar `[x]` y escribir un **Resultado honesto**. Qué se hizo, qué se probó (con números) y qué **no** se probó.
3. Actualizar `CHANGELOG.md` si cambia algo que ve quien juega.
4. **Un commit** con el mensaje `Txxx: descripción corta en español`, terminado con la línea de coautoría que indique tu herramienta.
5. `git fetch && git rebase origin/main` (si hay conflicto en `03-tareas.md` o `CHANGELOG.md`, conservar las dos entradas), `git push -u origin feature/…` y **abrir un PR contra `main`**. **No mergear:** el merge lo hace Lucas.
6. Si el push falla, avisar. **Nunca** usar `--force` sobre `main`.

## 5. Frenar y preguntar

Frenar, escribir la pregunta en el PR (o en la respuesta, si no hay PR) y **no inventar** cuando:
- falta una decisión que la ficha supone tomada (un valor, una regla o un nombre);
- el `RF` contradice lo que se encuentra en el código;
- hay que tocar archivos que la ficha no menciona y el cambio es más grande que un ajuste;
- los tests de otra parte del juego se rompen y la causa no es evidente;
- el bot dice que un nivel no se gana con la estrategia que debería ganarlo.

## 6. Para Codex (assets)

- **Antes de producir** hay que mostrarle a Lucas la **ficha de arte**: el concepto en 1 o 2 imágenes de prueba y la lista de piezas, tamaños y estados. Se produce solo con su OK (🎨). Si la ficha de la tarea trae el OK registrado, se puede producir directamente.
- Leer `specs/05-guia-de-arte.md` entera y `.claude/rules/arte.md`.
- **Igual que en M43** (`art/redesign-m43/README.md`), guardar en `art/<carpeta-de-la-tarea>/`:
  - las fuentes originales sin modificar (`sources/`);
  - `prompts.md` con los prompts normalizados;
  - `manifest.json`;
  - el empaquetador (`pack.gd`), si hace falta recortar o armar atlas;
  - una hoja de contacto a escala de juego (34 o 64 px) y de Wiki (112 px), y una captura en partida.
- Los archivos finales van en `assets/sprites/...` con alfa real, márgenes y anclajes estables y **sin sombras incrustadas** (salvo en la decoración del mapa, que lleva una sombra suave dibujada; guía §4).
- **No tocar la lógica.** Solo se cambian rutas y parámetros visuales de los `.tres` o del código de dibujo, si la ficha lo pide. Si integrar el asset exige más código, dejarlo anotado para la tarea de Sonnet correspondiente.
- Tests completos en verde (incluidos los de sprites) antes del PR.

## 7. Para Qwen 3.5 4B (local)

Solo en fichas marcadas *apto Qwen*. Esas tareas son de **datos con validador**:

1. Hacer **exactamente** los cambios de la ficha, archivo por archivo, sin agregar nada.
2. Después de cada archivo de nivel: `godot --headless --path . -s tools/check_level.gd -- <archivo>`. Si da error, corregir **solo lo que dice el error**.
3. Correr los tests completos. Si algo falla y la causa no está en tu cambio, **frenar**.
4. **No** escribir `RF` ni `D`, **no** tocar código `.gd` y **no** hacer el commit final. Un Sonnet bajo revisa el diff, completa el Resultado en `03-tareas.md` y hace el commit.

## 8. Plantilla de ficha

```
# Txxx · Título
- Ejecutor · modelo y esfuerzo
- Depende de · Compuerta · Tamaño
## Leer
## Objetivo
## Alcance (sí / no)
## Pasos
## Hecho cuando
## Verificación
## Frenar si
```


## 9. Ronda de cierre 2026-10-23 · M76

La spec de selector es [T459](T459-selector-mapa-modos-postes.md); sus RF-687–698 y D-198–203 siguen a los de T458, aunque los PR se revisen desde bases distintas. Código T470–T475 espera OK de Lucas a T459; T469 produce muestra, no finales, y espera aprobación antes de integrar. T475 exige propuesta y aprobación **por cada uno de los 15 mapas**. T235 está absorbida por T473, con remanente funcional todavía pendiente. Una sola tarea 📜 activa y hasta dos agentes de código con archivos disjuntos. Mapa celular y desbloqueo Asedio siguen las decisiones finales de Lucas, no las recomendaciones previas de T449.

## 10. Ronda de cierre 2026-10-23 · M77

[T460](T460-carga-franjas.md) define RF-699–707 y D-204–206, tras los rangos reservados T458/T459. Fichas T476–479 esperan aprobación de la spec; T477/T478 requieren muestra y OK de fondos por terreno. **T479 además espera un anexo al informe T454 con la medición de láminas en celular real y la aprobación de Lucas con esos resultados.** La arquitectura de contenedor físico/marco lógico se revisa antes de código; no usar expand jugable para resolver las franjas por inferencia. Coordinar archivos con T461/T464/T475 y T268; una sola tarea 📜 y como máximo dos agentes de código sin archivos compartidos.

## 11. Enmienda documental T480 · Aviso de «Ver todo»

[T480](T480-aclarar-aviso-zoom.md) registra D-207: el aviso de RF-676 se dispara únicamente al acercar (aumentar zoom), nunca al alejar o desplazar sin acercar. Si el jugador desplaza y luego acerca, el aviso puede aparecer si aún no se mostró en ese guardado. Esta tarea solo actualiza documentos; el código T464 se revisa en su propio PR.

## 12. Revisión visual T483 · Recorrido sobre T428

[T483](T483-recorrido-organico.md) compara la referencia T428, la muestra T482 A rechazada y una propuesta que conserva el fondo original con otro recorrido y aterrizaje. Es trabajo visual para decidir T469/T471: no integra arte, no valida controles ni teléfono y no resuelve la compuerta de estandartes. El visor vive en `art/t483-mapa-organico/index.html`; las capturas adjuntas se guardan en `Capturas/T483-*.png`.

## 13. T484 · Ajuste localizado del recorrido sur

[T484](T484-alternativas-tramo-sur.md) agrega al PR #79 dos alternativas para 5–9 sobre la dirección T483 aceptada. Se conservan costa, aterrizaje, 1–4 y 10–15; el visor comparativo es `art/t484-tramo-sur/index.html`. El crítico recomienda B, pero Lucas tiene que elegir. Si «parte de abajo» se refería a la silueta sur, esa costa todavía no se alteró. No se integra arte ni se cierra T469/T471 por producir las opciones.

## 14. T485 · Atlas y descubrimiento por zonas

[T485](T485-atlas-biomas-zonas.md) conserva la B elegida y propone silueta/terreno nuevo con los temas reales de quince niveles, verificados contra JSON. El visor `art/t485-atlas-biomas/index.html` muestra cartografía 1–5, 1–10 al desbloquear 6 y 1–15 al desbloquear 11; descubrir no abre niveles ni conquista. Todo es muestra pendiente de aprobación y futura spec de guardados/pruebas antes de runtime. #79 supersede las muestras del #78, cuyo cierre fue autorizado por Lucas una vez publicada esta revisión.

## 15. Cierre honesto de M75 · T458, T480, T464 a T467

El informe [M75-cierre-honesto](informes/M75-cierre-honesto.md) revisa cada criterio contra `main` y una ventana real. T464 a T467 no tenían ficha propia (salían de la [ficha T458](T458-ficha-camara-panel-opciones.md)). Ahora la tienen y reflejan lo ya hecho: [T464](T464-ver-todo-lupa-aviso.md) (abierta: falta el OK de la lupa), [T465](T465-panel-torre-sin-repeticiones.md) (abierta: RF-677.1 espera una decisión de Lucas), [T466](T466-opcion-circulo-alcance.md) y [T467](T467-ampliacion-alcance.md) (cerradas). Las capturas y la medición se rehacen con `tools/capture_m75_cierre.gd`.
