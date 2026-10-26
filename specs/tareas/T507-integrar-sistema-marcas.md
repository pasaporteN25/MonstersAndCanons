# T507 · Sistema de marcas por datos

- **Ejecutor:** Sonnet · integración.
- **Depende de / compuerta:** 🚦🎨 T506 con el glifo y los tipos aprobados; **no empezar antes**. Una a la vez con T497, T498 y T508.
- **Refs:** RF-717, RF-719, D-212. **Rama:** `feature/t507-sistema-marcas`, desde `origin/main`; un commit `T507: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/00-constitucion.md, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` (§4), M80 en `specs/01-spec.md` (RF-716 a RF-719 y las preguntas abiertas), D-212 (con la lista de menciones del símbolo A) y `specs/10-universo.md` (§5 y §6). Además, el informe `specs/tareas/informes/T475-integracion-postes.md`, `scripts/logic/campaign_posts.gd`, `scenes/levels/level_decor.gd` y `tests/test_campaign_posts.gd`.

## Objetivo y alcance

Copiar el mecanismo de los postes para las marcas: `data/ui/marcas_campana.json`, una clase de lectura tolerante (archivo ausente o dañado = sin marcas, sin error), el contexto pasado hacia abajo y una capa en `LevelDecor` con su `overlay_mark_cells()`. Los tipos son los aprobados en T506. **Validación dura en un test sobre los 15 niveles:** cada marca en una casilla `X` libre; nunca sobre camino, entrada, salida, construible, removible, extracción, marca de pieza, dibujo de leyenda, poste ni otra marca. Sin efecto de juego ni guardado. No se carga ninguna marca que Lucas no haya aprobado. Comparar los JSON con `origin/main` (idénticos).

## Archivos (propietario único)

`scripts/logic/` (la clase nueva), `scenes/levels/level_decor.gd`, `scenes/levels/level.gd` y la cadena de contexto de `Game`/`LevelData` solo en lo imprescindible, `data/ui/marcas_campana.json`, los PNG aprobados en `assets/sprites/map/rendered/`, tests nuevos y la guía §4. No `data/levels/`, no `postes_campana.json`. Comparte archivos con T508: una a la vez.

## Hecho cuando

Las marcas aprobadas se ven en los niveles pedidos; el test de casillas prohibidas pasa en los 15 niveles; los 15 JSON y `postes_campana.json` son idénticos; capturas a 1280×720 y celular simulado (identificado como tal), con y sin poste; GUT completo sin `SCRIPT ERROR` (`--import` primero; si cae con 139, relanzar y registrar ambos intentos); `git status` revisado (`git checkout -- assets` para SVG reescritos sin querer). No se afirma rendimiento ni prueba en teléfono real.

## Frenar si

Falta el OK de Lucas o el glifo aprobado; hay que tocar un JSON de nivel o la grilla; el poste y una marca caen en la misma casilla; un test de otro nivel falla sin causa evidente.
