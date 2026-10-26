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
