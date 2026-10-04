# Números del modo de pruebas (spec RF-324, D-048). Los valores reales viven en data/dev_config.tres (P2).
class_name DevConfig
extends Resource

## Oro que da el botón "+1000 de oro" del panel.
@export var gold_step: int = 0
## Velocidades del panel, de la más lenta a la más rápida (RF-322). Tiene que incluir 1.
@export var speeds: PackedFloat32Array = PackedFloat32Array()
