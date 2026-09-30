---
paths:
  - "specs/**"
---

# Reglas para los documentos de `specs/`

El proyecto se hace con **spec primero** (constitución P3: la spec manda):

1. **Spec** (`01-spec.md`): qué hace el juego, con requisitos numerados (`RF-xxx`) y un **criterio de aceptación** "Dado / Cuando / Entonces".
2. **Decisión** (`04-decisiones.md`): el **por qué** y las alternativas descartadas (`D-0xx`), con fecha, estado y quién decidió.
3. **Plan** (`02-plan-tecnico.md`): el **cómo** técnico.
4. **Tareas** (`03-tareas.md`): pequeñas (P8), cada una con `Refs`, **"Hecho cuando"** y, al terminar, `[x]` y un **"Resultado"** honesto (qué se hizo, qué se probó, qué **no**).
5. **Código y tests**, y recién ahí el commit.

Además:
- **Los números de RF y de D no se reusan ni se reordenan.** Siempre se sigue con el siguiente.
- Una idea nueva que nadie pidió va al **backlog** (§13), y las que propone Claude por su cuenta, a "Sugerencias de Claude (consultar antes de implementar)": no se implementan sin que Lucas las apruebe.
- **Documentos y comentarios en español** (P9), con lenguaje claro: Lucas pidió explicaciones detalladas.
- Cuando cambia algo que ya estaba escrito (un tamaño, una regla), **se actualiza en todos los lugares** donde aparece (spec, plan, `CONTENIDO.md`, `README.md`, `ONBOARDING.md`).
- Los límites honestos van escritos: qué se probó de verdad y qué no (por ejemplo "no se abrió en una computadora Linux real").
