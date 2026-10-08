# T239 · Publicación (código fuente y página)

- **Ejecutor:** **Lucas** decide y publica; Sonnet 5.5 · esfuerzo **bajo** prepara los textos · **Depende de:** T238 (y, si la intro entra en la 1.0, T242) · **Tamaño:** chico

## Antes de publicar (Sonnet bajo prepara, Lucas confirma cada paso)
1. **Código fuente (GPL, D-077 y Q-05):**
   - revisar que el repositorio no tenga secretos: claves de firma de Android, rutas personales, `.env` (`git log -p | grep -i "keystore\|password"`, y revisar `export_presets.cfg`);
   - si aparece algo, **no publicar**: avisarle a Lucas.
   - **Pasar el repositorio a público y crear la etiqueta `v1.0` lo hace Lucas**, porque son acciones visibles para todos.
2. **Página** (itch.io u otra, según Q-05): borrador del texto en `specs/publicacion/pagina.md`, con:
   - descripción corta y larga;
   - capturas (de T236 o T238);
   - requisitos;
   - licencia y enlace al código;
   - "Hecho con Godot" y su aviso MIT (RF-387).
3. **Notas de la versión:** el resumen de `CHANGELOG.md` para jugadores.

## Lucas
Publica la página y sube las builds. Esa acción es **de Lucas**: ningún agente publica ni sube nada en su nombre.

## Hecho cuando
El juego está publicado y el código disponible, con los enlaces anotados en `README.md`.
