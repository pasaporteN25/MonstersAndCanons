# T442 · Catálogo y persistencia cosmética

**Refs:** RF-662/RF-664, D-186. **Depende de:** T439.

## Alcance

Implementar lógica pura para ids estables de paleta/emblema y una receta predeterminada. Persistirla en un archivo `user://` propio, aislado de SaveManager, `settings` y `SAVE_VERSION`.

## Hecho cuando

Ausencia, JSON inválido, versión no compatible o ids desconocidos producen el predeterminado. Tests cubren validación e ida/vuelta sin mutar progreso ni otras preferencias.
