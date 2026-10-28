# Prompts · T463 (fondo del Coloso)

Estado: PROPUESTA sin aprobar. Generador: `codex exec` con su herramienta de imagen integrada (ver README).

## Encargo común

Fondo 16:9 (sin personaje, criatura ni figuras) para la presentación pausada del Coloso en un tower defense 2D de fantasía en un planeta fronterizo. Ilustración de utilería dimensional y pintada, materiales mate, luz cálida suave desde arriba a la izquierda, sensación de cámara elevada ortográfica, misma familia que las rocas facetadas de basalto y el pasto oliva del juego (apagado, terroso; no fotorrealista, no vector plano, sin contornos ni resplandores). Composición: el centro y el centro-bajo quedan calmos, de poco contraste y vacíos porque ahí van la ilustración del gólem y el texto; el interés (profundidad, formaciones de roca, atmósfera) va en los bordes izquierdo, derecho y superior; viñeta suave. Paleta: basalto carbón oscuro, sepia/ocre cálido, oliva apagado, acentos ámbar tenues. Sin texto, interfaz, logo, símbolos, estandartes, personas ni carteles.

## Variantes

- **A · Anfiteatro de basalto:** cañón ancho de basalto al atardecer, paredes de piedra facetada oscura que se cierran desde los lados, suelo plano de polvo ocre, bruma cálida baja en el horizonte.
- **B · Llanura en ruinas:** llanura abierta de Cántaro bajo cielo cubierto, columnas rotas y bloques caídos al fondo a izquierda y derecha, matorral oliva y tierra desnuda, cresta oscura lejana, luz gris-sepia fría con un claro cálido en las nubes.
- **C · Cantera:** cantera excavada, bancos de piedra de pálida a oscura en terrazas a ambos lados con andamios de madera y una vía de carro lejana, polvo en el aire, luz cálida de fin de tarde, pozo oscuro poco profundo en la media distancia.

## Lo que realmente se corrió (honesto)

- `raw_a` salió del encargo común + «anfiteatro de basalto» (en español, vía `codex exec -m gpt-6-luna`). Resultado: paisaje cinematográfico con horizonte y atardecer dramático; **descartada** por la compuerta de estilo.
- `raw_b` y `raw_c` **no** usaron las escenas B y C de la tabla de arriba: tras ver `raw_a` se corrigió el encargo para pedir explícitamente la familia del mapa (cámara elevada 3/4, rocas facetadas gordas de basalto con vetas ámbar, árboles chicos de copa oliva, pasto y tierra, sin niebla ni cielo, centro calmo). `raw_b` = claro de frontera (pasto oliva y tierra); `raw_c` = versión sombría y de cierre (suelo pedregoso oscuro con grietas ámbar y camino ondulado en el tercio inferior).
- Las escenas B (llanura en ruinas) y C (cantera) de la tabla **no se generaron**.
