# Google Play: ficha, formularios y pasos (T597)

**Estado:** borrador para Lucas (RF-756, RF-757, D-237). **Lo publica Lucas**: ningún agente sube nada ni completa la consola en su nombre. Las reglas de Google cambian; donde algo depende de ellas, dice **[confirmar en la consola]**.

## 0. Datos fijos

| Campo | Valor |
|---|---|
| Nombre de la app | **Monsters & Canons** (17 de 30 caracteres) |
| Identificador (paquete) | `com.monsterscanonsv1.game` — **no se puede cambiar después de la primera subida** |
| Tipo | Juego · **Gratis** (una app gratis no puede pasar a paga después) |
| Categoría | Juegos → **Estrategia** |
| Etiquetas | Tower defense, Estrategia, Un jugador, Sin conexión |
| Idioma predeterminado | **Español (Latinoamérica) – es-419**. El juego hoy está solo en español (el selector de inglés está apagado, T534). |
| Sitio web (opcional) | https://github.com/pasaporteN25/MonstersAndCanons |
| Correo de contacto | **Lo elige Lucas** (es público en la ficha). |
| Política de privacidad | https://github.com/pasaporteN25/MonstersAndCanons/blob/main/PRIVACY.md (funciona cuando T597 esté en `main`) |

## 1. Textos de la ficha

**Descripción corta** (máx. 80 caracteres):

> Defendé la colonia con torres: 15 niveles, modo Asedio y cero anuncios.

**Descripción larga** (máx. 4.000 caracteres):

> **Monsters & Canons** es un tower defense en 2D. Una expedición científico-militar llega a Cántaro para quedarse. Mientras levanta su campamento, aparecen criaturas cerca del perímetro. Tu trabajo es que ninguno llegue a la salida: elegís dónde poner cada torre, cuándo mejorarla y cómo repartir el oro y los recursos para aguantar hasta la última oleada.
>
> **Qué vas a encontrar**
>
> • **Campaña de 15 niveles**, de la pradera a las ruinas, la nieve y el desierto, con mapas de una, dos y tres entradas y un final con jefe.
> • **Torres que se mejoran y se combinan**: de la básica al cañón, el francotirador, el mortero, el hielo, el fuego, la Tesla y más.
> • **Monstruos con mañas propias**: rápidos, blindados, voladores, que curan, que roban oro, que apagan torres o que se parten al caer.
> • **Recursos y demolición**: limpiá obstáculos del mapa para conseguir recursos y elegí si pagás una torre solo con oro o usando recursos.
> • **Modo Asedio**: los 15 mapas con monstruos más duros y récords propios.
> • **Wiki dentro del juego** con torres, enemigos, guía y la historia de la colonia, que se va abriendo a medida que avanzás.
> • **Tutorial** en el primer nivel y una **intro** corta que podés saltear.
> • **Pensado para el celular**: controles táctiles, zoom con dos dedos y pantalla horizontal.
>
> **Sin anuncios, sin compras y sin conexión.** El juego no pide permisos, no necesita internet y guarda tu progreso solo en el teléfono.
>
> **Software libre.** Monsters & Canons se distribuye bajo la licencia GPL 3 o posterior. El código está en GitHub. Hecho con Godot Engine.

**Notas de la versión 1.0.0** (máx. 500 caracteres, se escriben al crear cada versión):

> Primera versión en Google Play: campaña completa de 15 niveles, modo Asedio, Wiki, tutorial y controles táctiles.

## 2. Gráficos

| Qué pide Play | Archivo | Estado |
|---|---|---|
| Ícono, 512 × 512, PNG de 32 bits, hasta 1 MB | `art/play-store/icon_512.png` (copia de `assets/icon.png`) | Listo. Ilustración del monstruo y el cañón, con esquinas cuadradas para el recorte automático de Play (T600). |
| Gráfico destacado, 1024 × 500, sin transparencia | `art/play-store/feature_graphic_1024x500.png` (lámina «El oasis» + logo) | Listo; se regenera con `tools/play_store_graphics.gd`. |
| Capturas de teléfono: de 2 a 8, PNG o JPEG, el lado largo **no más del doble** del corto | **Pendiente.** | Sacarlas en el teléfono, jugando (ver abajo). |

**Capturas.** Lo más fácil y lo más honesto es sacarlas en el teléfono, en partida: **un celular de 20:9 da imágenes más anchas que 2:1**, que Play rechaza, así que recortalas a 16:9 (por ejemplo 1920 × 1080) o sacalas desde la PC a 1280 × 720 o 1920 × 1080. Sugerencia de 6: (1) nivel 1 con varias torres y enemigos en el camino; (2) una torre con su panel de mejora abierto; (3) un mapa con recursos y la elección «Solo oro / Usar recursos»; (4) un mapa de nieve o desierto con dos entradas; (5) el nivel 15 con muchas torres; (6) la Wiki o el mapa de campaña. Sin el modo de pruebas a la vista.

## 3. Formularios de «Contenido de la app»

| Formulario | Respuesta | Por qué |
|---|---|---|
| Política de privacidad | La URL de arriba | `PRIVACY.md` |
| Acceso a la app | Toda la funcionalidad está disponible sin acceso especial | No hay cuentas ni contraseñas. |
| Anuncios | **No** contiene anuncios | |
| Clasificación de contenido (IARC) | Categoría **Juego**. Violencia: **sí, fantástica/caricaturesca contra criaturas no humanas** (torres que disparan a monstruos), sin sangre realista. Sexo, lenguaje, drogas, alcohol, apuestas: **no**. ¿Los usuarios interactúan o comparten contenido? **no**. ¿Comparte ubicación? **no**. ¿Compras digitales? **no**. | El resultado lo calcula el cuestionario; lo esperable es una clasificación baja (del tipo PEGI 7 / E10+) **[confirmar en la consola]**. |
| Público objetivo | Recomendado: **13 años o más** | Elegir menores de 13 suma los requisitos del programa para familias. El juego los cumpliría (no tiene datos ni anuncios), pero alarga la revisión. Se puede ampliar después. |
| Seguridad de los datos | ¿Recopila o comparte datos del usuario? **No**. (Si pregunta por cifrado o eliminación de datos: no aplica, no hay datos ni cuentas.) | No hay red, permisos, cuentas, anuncios ni análisis. Si eso cambia, se actualiza antes de la versión siguiente. |
| App de noticias, gubernamental, de salud, financiera, COVID-19 | **No** | |

## 4. La clave de subida (la hace Lucas, una sola vez)

Play usa **Play App Signing**: Google guarda la clave que firma la app que bajan los jugadores, y vos firmás cada AAB con una **clave de subida** tuya. Si la clave de subida se pierde, Google permite reemplazarla, pero lleva tiempo: guardá el archivo y su contraseña en un lugar seguro (gestor de contraseñas y una copia fuera de la computadora).

1. Crear la clave (te pide la contraseña y unos datos; la contraseña la escribís vos):

   ```powershell
   & "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkeypair -v -keystore "$env:USERPROFILE\claves\monsterscanons-upload.jks" -alias upload -keyalg RSA -keysize 2048 -validity 10000
   ```

   (Crear antes la carpeta `claves`. **Nunca** dentro del repositorio: `.gitignore` igual ignora `*.jks` y `*.keystore`.)
2. En Godot: **Proyecto → Exportar → «Android Play» → Keystore → Release**: la ruta del `.jks`, el usuario `upload` y la contraseña. Godot la guarda en `.godot/export_credentials.cfg`, que no se versiona.

## 5. Exportar el AAB

- Desde el editor: **Proyecto → Exportar → «Android Play» → Exportar proyecto**, con **«Exportar con depuración» destildado**, a `build/MonstersCanons.aab`.
- O por consola (la primera vez instala la plantilla en `android/`):

  ```powershell
  godot --headless --path . --install-android-build-template --export-release "Android Play" build/MonstersCanons.aab
  ```

- **Antes de cada subida, subir `version/code`** en los dos presets de Android (`export_presets.cfg`). Play rechaza un AAB con un código ya usado. El nombre de versión sale de `config/version` en `project.godot` (hoy «beta»; pasa a `1.0.0` con T268/T375).
- **Avast y Java:** en esta PC, Avast inspecciona HTTPS y el Java de Android Studio no confía en su certificado, así que Gradle no puede bajar sus dependencias (error `PKIX path building failed`). Ver `ONBOARDING.md` §7.5.

## 6. Pasos en la consola, en orden

1. **Crear app**: nombre, idioma es-419, Juego, Gratis, aceptar las declaraciones.
2. **Panel → Configurar la app**: completar los formularios de la sección 3.
3. **Ficha de Play Store principal**: textos de la sección 1 y gráficos de la sección 2.
4. **Prueba interna** (Probar y publicar → Pruebas → Prueba interna): crear una lista de testers (correos de cuentas de Google, hasta 100), **crear versión**, aceptar Play App Signing, subir el `.aab`, pegar las notas y publicar en esa pista. Suele estar disponible en minutos u horas; los testers entran por el enlace de participación.
5. **Prueba cerrada**: según las reglas actuales para **cuentas personales nuevas**, hace falta una prueba cerrada con **al menos 12 testers durante 14 días seguidos** antes de poder pedir acceso a **producción** **[confirmar en la consola: el panel muestra el requisito y la cuenta regresiva]**.
6. **Producción**: con el acceso aprobado, crear la versión de producción (se puede promover el mismo AAB) y enviarla a revisión. La primera revisión puede tardar varios días.

## 7. Actualizaciones

Cada actualización es: subir `version/code` (y `version/name`), exportar el AAB firmado con **la misma clave de subida**, crear una versión nueva en la pista y enviarla. Los teléfonos la bajan solos si tienen activada la actualización automática de Play. El progreso (`user://`) se conserva porque el paquete y la firma son los mismos. Se puede hacer un **lanzamiento por etapas** (por ejemplo, 20 % de los usuarios primero). Automatizarlo desde GitHub Actions está en «Sugerencias de Claude» (spec §13).
