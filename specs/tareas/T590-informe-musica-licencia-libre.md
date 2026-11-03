# T590 · Informe: música con licencia libre para el juego

- Ejecutor · Codex · Terra 6.1, esfuerzo medio
- Depende de · nada · Compuerta · ninguna (meter música al juego sí necesita el OK de Lucas) · Tamaño · Mediano
- Prioridad · media

## Leer

`specs/01-spec.md`: B-70, RF-354, RF-472 (créditos) y RF-116. `specs/11-textos-lore.md` §3 (créditos). `specs/10-universo.md` (tono). Las propuestas de música de combate T535 y T536 (ramas `feature/t535-combat-music-proposal` y `feature/t536-combat-music-sol`, solo lectura).

## Objetivo

Que Lucas sepa **dónde conseguir música con licencia libre** que sirva para el juego, que va a salir **gratis en itch.io**, y qué conviene buscar para cada momento.

## Alcance

**Sí:** un informe en `specs/tareas/informes/T590-musica-licencia-libre.md`, en español. Buscar en repositorios y bibliotecas de música libre (por ejemplo OpenGameArt, Free Music Archive, Incompetech, Freesound para efectos, itch.io assets, Musopen y los que encuentres); registrar la fecha de consulta.

**No:** descargar archivos al repositorio, integrar música, tocar el juego ni cambiar los créditos. Si una pista se copia al informe, solo el enlace.

## Qué tiene que contestar

1. **Repositorios:** cuáles hay, qué licencias usan, cómo se filtra por licencia, si piden cuenta, y cuán confiable es el dato de licencia de cada uno.
2. **Licencias:** para cada una (CC0, CC BY, CC BY-SA, CC BY-NC, licencias propias de cada sitio) decir si permite **redistribuir en itch.io gratis**, si exige **atribución** y cómo, si limita **uso comercial** (a futuro) y si obliga a licenciar igual el juego (SA). Separar en una tabla: «sirve», «sirve con cuidado» y «evitar».
3. **Géneros y sugerencias por momento del juego:** menú, combate común, jefes, victoria, derrota, epílogo y créditos. Para cada uno, género sugerido, tempo, instrumentación y qué palabras buscar, con el tono de Cántaro (planeta árido, colonia, señales). Comparar con la música sintetizada actual (RF-354): qué mejora y qué se pierde.
4. **Candidatos concretos:** una lista corta (no más de 15) de pistas o paquetes con enlace, autor, licencia, duración, formato, si hace loop y para qué momento sirve. Marcar cuáles ya probaste que la licencia dice lo que dice en la página oficial del autor.
5. **Créditos y licencias en el juego:** cómo sumar cada pista a la pantalla de créditos (RF-472) con el texto de atribución exacto que pide su licencia, y un archivo de licencias dentro del paquete de itch.io. Qué hay que guardar como prueba (captura de la página, fecha).
6. **Riesgos:** pistas con licencia dudosa o cambiada, contenido subido por terceros que no es del autor, Content ID, exigencias de atribución en la página de itch.io, y qué hacer si una pista se retira.
7. **Recomendación:** el orden en que conviene probar los candidatos y el costo en tareas de integrarlos (audio, créditos, archivo de licencias, tests).

## Hecho cuando

El informe contesta los siete puntos, cada licencia está citada de su fuente oficial con fecha, y dice con claridad qué **no** pudo verificar (por ejemplo escuchar una pista en el juego). No hay música nueva en el repositorio.

## Verificación

`git status` limpio salvo el informe, esta ficha y la entrada de `specs/03-tareas.md`. Las licencias son la parte delicada: ante la duda, marcar «evitar» o «a confirmar con el autor».

## Frenar si

Una fuente no deja ver su licencia con claridad, o el único modo de obtener la pista es saltarse una restricción: no incluirla.
