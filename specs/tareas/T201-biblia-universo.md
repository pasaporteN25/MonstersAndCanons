# T201 · 🚦 G2 · Biblia del universo de Monsters & Canons

- **Ejecutor:** Sonnet 5.5 · esfuerzo **alto** (ideal: Opus). Es escritura creativa con criterio.
- **Depende de:** T200 (Q-01, Q-02 y Q-03) y T202 (glosario) · **Compuerta:** Lucas aprueba el texto (G2) · **Tamaño:** mediano

## Leer
- `specs/07-lore-y-cierre-v1.md` **entero**: es la fuente de verdad del lore acordado.
- `specs/06-monsters-canons-3d.md` §1, §9 y §15: la familia de juegos y qué **no** entra en la V1 (Épocas).
- `specs/08-plan-cierre-v1.md` §3 y §5: qué es la "franquicia" y las fichas de los mapas.
- El informe de T202 (glosario) y `specs/05-guia-de-arte.md` §3 (especies) y §7 (familias de torres).
- Los artículos de `data/wiki/*.json`, para conocer el tono actual de los textos del juego.

## Objetivo
Crear `specs/10-universo.md`: el **canon** que comparten la V1, M&C 3D y M&C 2. Es un documento de referencia, **no** una spec: no tiene `RF`.

## Contenido (secciones obligatorias)
1. **Premisa en 5 líneas:** una expedición llega a un planeta lejano para **quedarse**.
2. **El planeta:** nombre (de Q-03 o 3 propuestas para elegir), regiones (los temas del juego: oasis/pradera, bosque, ruinas, desierto, nieve…) y qué hay en cada una.
3. **La expedición o colonia:** nombre (ídem), por qué hierro, bronce, cristal y mecanismos (07 §2: **sin** láseres ni soldados espaciales) y qué son las torres: artillería del perímetro.
4. **Los habitantes, en cuatro capas** (07 §2):
   - fauna hostil;
   - criaturas independientes (el Ladrón, por ejemplo);
   - comunidades organizadas: Guardián, Chamán y Curandero;
   - quién es el Soberano.
   Una ficha por especie con su **nombre canónico de T202**, qué es y qué busca, en 2 o 3 líneas.
5. **Los avances científicos y las ruinas:** qué son y quién las dejó. Puede quedar ambiguo, pero tiene que ser coherente con que **el símbolo de las ruinas es el mismo que el de las señales del oasis** (plan 08 §5).
6. **Las señales** (07 §2): el catálogo de señales y qué revelan en cada bloque.
7. **El arco de la V1 en 15 mapas:** una línea por mapa, que sirve de guía para los textos de T227.
8. **Tono y reglas de escritura:**
   - el desenlace es ambiguo;
   - se muestran las consecuencias, sin sentenciar;
   - nada de caricaturas;
   - textos breves.
   Con 3 ejemplos de cómo **sí** y 3 de cómo **no**.
9. **Canon y semillas:**
   - lo que es canon fijo;
   - lo que son **semillas** para entregas futuras (elegir bando, rebeldes, Épocas), marcadas como **no prometidas**.
10. **Sugerencia pendiente:** el doble sentido Canons/cánones (06 §1) va como propuesta, no como canon.

## Reglas
- **No contradecir el 07.** Si algo del 07 parece incompleto, se escribe como opción y se le pregunta a Lucas.
- Los nombres propios nuevos (planeta, colonia, comunidades) van **siempre con 3 opciones** para que Lucas elija, salvo que él ya los haya dado.
- Español rioplatense, claro, sin grandilocuencia. Para todo el documento, 300 a 600 líneas como máximo.
- No tocar código ni datos. Agregar el enlace en `CLAUDE.md` ("Dónde está cada cosa") y en `specs/07` §14.

## Hecho cuando
- `specs/10-universo.md` existe con las 10 secciones.
- Lucas eligió los nombres y aprobó el texto, y su OK quedó escrito al principio del documento con la fecha.
- La entrada de T201 en `03-tareas.md` está completa.

## Frenar si
- Lucas no eligió los nombres: dejar el documento con las opciones y pedir la elección en el PR. **No mergear sin G2.**
