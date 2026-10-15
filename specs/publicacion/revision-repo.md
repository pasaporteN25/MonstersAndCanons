# Revisión del repositorio antes de publicar (T239)

**Fecha:** 2026-10-11 · **Rama:** `feature/t239-preparar-publicacion` · **Quién:** Claude (solo lectura; no se corrigió ni se borró nada) · **Repositorio:** `github.com/pasaporteN25/TDv1` (hoy privado).

## Resultado en una línea

**No apareció ninguna clave, contraseña, token ni keystore** en el árbol actual ni en el historial (304 commits, 67 ramas). Sí hay **datos personales menores** que se vuelven públicos si el repositorio pasa a público; están abajo para que Lucas decida.

## Qué se revisó y cómo

| Revisión | Resultado |
|---|---|
| Archivos sensibles en el árbol (`git ls-files`: `*.keystore`, `*.jks`, `.env`, `*.pem`, `*.p12`, `*.key`, `id_rsa`, `credential*`, `*.apk`, `*.exe`, `*.pck`) | **Ninguno.** |
| Los mismos tipos de archivo en **todo el historial** (`git log --all --name-only`) | **Ninguno** jamás se commiteó. |
| Texto en el árbol: `keystore`, `password`, `passwd`, `secret`, `api_key`, `token`, `BEGIN … PRIVATE KEY`, `ghp_`, `AKIA` | Solo coincidencias **inofensivas**: `technology_token.svg` (un dibujo), una variable `token` de un efecto en `scenes/game/game.gd`, la palabra «password» dentro del texto de la licencia GPL, y menciones en documentos de que **no** hay keystore en el repo. |
| Texto en el **historial** (`git log --all -p`, mismos patrones, excluyendo `addons/`, `art/`, `assets/`) | Solo las líneas de documentación de `ONBOARDING.md`, `specs/03-tareas.md`, `specs/04-decisiones.md` y la ficha T239 que hablan del keystore de depuración. Ningún valor de clave. |
| `export_presets.cfg` (y su historial) | **Limpio.** Sin campos `keystore/*`, `release_user` ni `release_password`; `package/signed=true` firma con el keystore de depuración que Godot guarda **fuera del repo** (`~/.local/share/godot/keystores/debug.keystore`). El archivo trae `exclude_filter` con `tests/*, tools/*, specs/*, addons/gut/*, art/*`. |
| `.gitignore` | Ignora `.godot/`, `/android/`, `/build/`, `*.exe`, `*.pck`. **No** ignora `*.keystore`, `*.jks`, `.env` ni `*.apk` (ver recomendación 2). |
| `.github/workflows/tests.yml` | No usa `secrets.*`. |

## Hallazgos para que Lucas decida

Ninguno es una credencial. Se anotan con archivo y commit donde corresponde.

1. **Correo personal en cada commit.** Los 303 commits de Lucas llevan `lucas_felici@yahoo.com.ar` como autor y 1 commit lleva `noreply@openai.com`. Al hacer público el repositorio, el correo queda visible en el historial. *Si no se quiere, solo se arregla reescribiendo el historial (acción destructiva, necesita permiso de Lucas) o publicando una copia nueva sin historial.* El historial de la cuenta de GitHub también puede ocultar el correo con la opción «Keep my email addresses private» (afecta commits **futuros**, no los viejos).
2. **Rutas del usuario del sistema** (`/home/newman/...`), sin claves:
   - `specs/03-tareas.md:1690` (entrada de T237, commit `10ef0ae` y siguientes) y la entrada de la APK de T237 (commit `a3ef097`): rutas del JDK, del SDK de Android y del keystore.
   - `art/t233-final/validation/gut.txt`, `art/t244-coloso/validation/*.txt`, `art/t249-mejoras/validation/gut_*.txt`, `art/t257-cuadrilla/validation/*.txt`, `art/t260-decoration/validation/gut*.log`, `art/t261-ground/validation/*.txt`: salidas de pruebas con `/home/newman/.local/share/…` y `/home/newman/orca/workspaces/…`.
   - `ONBOARDING.md:222,235`: `C:\Users\<usuario>\…` es un **ejemplo genérico**, no un dato real.
3. **Tamaño.** `art/` pesa **462 MB** y tiene 1228 archivos versionados (archivo de pruebas de arte, GIF de hasta 20 MB como `art/redesign-m31/previews/motion.gif`). No es un secreto, pero cualquiera que clone el repositorio público lo baja entero. `art/` no entra en los ejecutables.
4. **Nombre del repositorio.** Se llama `TDv1` y el juego `Monsters & Canons`; la carpeta de guardado sigue siendo `JuegoA` en los tres sistemas. Es una decisión estética, no de seguridad.
5. **Textos de proyecto internos.** `specs/` y `CLAUDE.md` son documentos de trabajo en español con menciones a otros agentes (Codex, Sonnet, Orca). No hay nada sensible, pero se van a ver públicos.

## Recomendaciones (no aplicadas)

1. Decidir sobre el punto 1 **antes** de pasar a público: después no se puede deshacer, porque los clones lo conservan.
2. Agregar a `.gitignore`: `*.keystore`, `*.jks`, `.env`, `*.apk`, `*.aab`, para que una firma futura (por ejemplo, la de Play Store, Q-05) no se suba por accidente. *No se tocó `.gitignore`; el pedido era solo revisar.*
3. Si se publica con historial, nada que cambiar en `export_presets.cfg`.

## Pasos manuales para Lucas, en orden

1. **Leer este informe** y decidir los puntos 1 a 3 de «Hallazgos».
2. **Confirmar los textos** de `pagina.md` y `notas-version-1.0.md`: sacar los **[confirmar]**. En particular, saber si querés que el modo Asedio salga con los porcentajes provisorios (spec T258 pide que juegues del 1 al 15) y si las capturas se sacan de la versión final.
3. **Actualizar el `CHANGELOG.md`**: dice que las láminas de la intro son provisorias, pero T241 ya las aprobó (commit `9188157`). Corregirlo antes de publicar para que las notas no digan algo viejo.
4. **Exportar las builds** con `godot --headless --path . --export-release …` para Windows, Linux y Android (la APK de T237 se exportó pero no se probó en un dispositivo; probar en un celular real **antes** de subirla).
5. **Probar el `.exe` en un Windows real** (nunca se ejecutó, T237) y anotar la versión mínima en la página.
6. **Sacar las capturas** de la lista de `pagina.md`.
7. **Crear la etiqueta `v1.0`** en `master`/la rama que corresponda y subirla.
8. **Pasar el repositorio a público** en GitHub (Settings → Danger Zone → Change visibility). Verificar que `LICENSE` se vea en la portada.
9. **Crear la página en itch.io** (gratis) con el texto de `pagina.md`, subir las tres builds y marcar cada una con su plataforma.
10. **Anotar los enlaces** (itch.io y repositorio) en `README.md` (criterio «Hecho cuando» de T239) y marcar T239 `[x]` en `specs/03-tareas.md` con su «Resultado».

*Ningún paso de esta lista lo hizo Claude: no se publicó, no se cambió la visibilidad, no se creó la etiqueta ni se subió ninguna build.*

## Pruebas

Suite de GUT: **1628 de 1628 pasan** (116 scripts), sin `SCRIPT ERROR`. Ningún test cubre los documentos de `specs/publicacion/`.
