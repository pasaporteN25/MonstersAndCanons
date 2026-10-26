# Procedencia · T505

Codex; atribución solicitada: gpt-6.1-sol, esfuerzo medio; fecha 2026-10-26.
Python 3 + Pillow, sin NumPy, servicios de imágenes, imágenes generativas ni material ajeno.
Codex definió los tres signos con polígonos originales y programó todos los materiales,
proyecciones, desgaste, hojas y controles. No participaron otros agentes.
Las rocas derivan del generador procedural original T504 del repositorio, leído sin escribirlo.
Las referencias PNG del juego se observaron para escala, luz, material y perspectiva;
los suelos y las capturas se reutilizan como fondos del propio proyecto.
El método sigue generate_samples.py: supersampling x3 y reducción Lanczos a 128 px.
Las miniaturas usan la aproximación trilineal de T504; no certifican el filtro de GPU.
Semilla principal 50526; constantes locales en las fuentes para materiales y musgo.
El manifiesto registra SHA-256, tipo, glifo y semilla de cada archivo generado y fuente.
Reproducir: python3 art/m80-muestras/glifo-h/sources/generate_glifo.py
Después: python3 art/m80-muestras/marcas/sources/generate_marcas.py
Solo se escriben las dos carpetas autorizadas. prompts.md se conserva intacto.
La revisión visual y sus límites quedan en revision.md. Propuestas sujetas a Lucas.


## Composiciones y alcance
Las doce marcas son dibujos procedurales originales. El hito usa cinco bloques de
la fuente T504. El poste de campaña se reutiliza intacto solo como comparación.
Los montajes son ediciones sobre capturas reales previas; no son capturas de una
integración nueva. Cada casilla alterada se repinta antes de colocar un único ítem.
Nivel 12 usa g1 y arenisca; 13 usa g2 y snow_rock_01; 14 usa g3 y roca oscura.
No se mezclan variantes del signo dentro de un mismo nivel.
En nieve, snow_rock_01 es la excepción explícita solicitada a la familia T504.
Los JSON y postes se leen y se validan con assert. Se extiende la calibración T504
al ancho limitante del nivel 12 según scripts/logic/rules.gd. Los orígenes y tamaños
exactos, señales, cuatro X por nivel y postes están en composiciones.json.
La captura original ya trae postes: la versión base los retira repintando sus X.
La versión _con_poste los vuelve a dibujar a escala documentada en sus casillas.
