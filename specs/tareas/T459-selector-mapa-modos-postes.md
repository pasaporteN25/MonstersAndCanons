# T459 · 📜 Selector, mapa, modos y postes

- **Ejecutor:** arquitectura/spec pesada; preferencia Opus, revisión del orquestador. La disponibilidad efectiva del modelo se informa en la entrega, no se simula una revisión.
- **Depende de:** decisiones finales de Lucas en T449; T458 ya numerada (RF-674–686/D-192–197). **Compuerta:** 🚦 OK de Lucas al PR antes del código T469–T475. **Tamaño:** documental.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, constitución, spec §11/§13 y M72–M74/M76, decisiones D-178/D-179/D-183 y D-198–203, plan técnico, tablero, plan de cierre, ONBOARDING, tareas/README y las dos secciones finales de T449.

## Objetivo y alcance

Registrar las decisiones de Lucas con RF-687–698, D-198–203, plan técnico y fichas T469–T475. Incluye mapa inicial PC/celular, migración única, geografía nueva aprobable, selección explícita, Asedio por campaña y acceso heredado, T235, insignias/números y veinte postes. No código, datos de juego ni arte final. T449 contiene recomendaciones anteriores que las respuestas de Lucas reemplazan.

## Hecho cuando

RF con Dado/Cuando/Entonces, decisiones y alternativas descartadas, dependencias/archivos y criterios de aceptación delegables; compuertas por arte y por cada mapa explícitas. Documentos coherentes, sin reutilizar números. Draft revisable por Lucas antes de programar.

## Verificación

Lectura de fuentes y grillas JSON vigentes, revisión documental y `git diff --check`. No ejecutar Godot, bots ni pruebas por un cambio documental. No cerrar T453/T454/T238 ni declarar probado teléfono/rendimiento.

## Frenar si

Se descubre una decisión de Lucas contradictoria o una aprobación faltante se intenta dar por supuesta; registrar la duda y continuar con lo independiente.

## Borrador textual para revisar el flujo

```text
Campaña | Asedio | Comunidad | …modos…           Estrellas: N de 45
Vista: Mapa / Tarjetas
┌──── lienzo, fijo si entra / desplazable si excede ─────────────┐
│ Aterrizaje en tierra → zonas orgánicas 1…15, serrucho oeste→este│
│ Candado = inaccesible; estrellas + fondo rebelde/partido/propio│
└──────────────────────────────────────────────────────────────┘
[Nombre y lugar del nivel seleccionado] [★★☆]       [Jugar]
```

En celular, tocar zona actualiza la ficha y arrastrar un dedo desplaza; el último renglón queda fijo. La distribución exacta se decide en implementación con mínimos táctiles existentes y capturas; esto no aprueba arte. En tarjetas, tocar conserva la entrada directa. En Récords, el selector «Campaña / Asedio / …modos…» muestra los top 5 ya guardados del modo elegido. El motivo «Ganá el nivel anterior» queda en el detalle del mapa inaccesible, sin repetir los rótulos retirados.
