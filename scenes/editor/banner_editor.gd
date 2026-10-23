## T443 (RF-663–RF-665): edita una receta cosmética local; solo «Aplicar» escribe el archivo.
class_name BannerEditor
extends Control

signal applied(recipe: BannerRecipe)
signal cancelled

var store_path: String = BannerRecipeStore.DEFAULT_PATH
var close_editor: Callable = GameFlow.go_to_tools
var draft: BannerRecipe

@onready var _large_preview: TextureRect = %LargePreview
@onready var _tile_preview: TextureRect = %TilePreview
@onready var _palette_row: HBoxContainer = %PaletteRow
@onready var _emblem_row: HBoxContainer = %EmblemRow
@onready var _message: Label = %Message
@onready var _apply_button: Button = %ApplyButton
@onready var _cancel_button: Button = %CancelButton
@onready var _restore_button: Button = %RestoreButton


func _ready() -> void:
	draft = BannerRecipeStore.load_recipe(store_path)
	_build_choices(_palette_row, BannerCatalog.palette_ids(), true)
	_build_choices(_emblem_row, BannerCatalog.emblem_ids(), false)
	_apply_button.pressed.connect(apply_draft)
	_cancel_button.pressed.connect(cancel_editing)
	_restore_button.pressed.connect(restore_default)
	Audio.add_click_sounds(self)
	_refresh()
	(_palette_row.get_child(0) as Control).grab_focus()


func select_palette(id: String) -> void:
	if BannerCatalog.has_palette(id):
		draft.palette = id
		_message.text = ""
		_refresh()


func select_emblem(id: String) -> void:
	if BannerCatalog.has_emblem(id):
		draft.emblem = id
		_message.text = ""
		_refresh()


func restore_default() -> void:
	draft = BannerRecipe.default_recipe()
	_message.text = "Predeterminado seleccionado. Aplicalo para guardarlo."
	_refresh()


func apply_draft() -> bool:
	if not BannerRecipeStore.save_recipe(draft, store_path):
		_message.text = "No se pudo guardar. Revisá el espacio y los permisos del dispositivo."
		return false
	_message.text = "Diseño aplicado."
	applied.emit(draft)
	close_editor.call()
	return true


func cancel_editing() -> void:
	cancelled.emit()
	close_editor.call()


func _build_choices(row: HBoxContainer, ids: Array[String], is_palette: bool) -> void:
	for id: String in ids:
		var choice := Button.new()
		choice.text = BannerCatalog.palette_label(id) if is_palette else BannerCatalog.emblem_label(id)
		choice.toggle_mode = true
		choice.set_meta("choice_id", id)
		choice.custom_minimum_size = Vector2(132, 48)
		choice.focus_mode = Control.FOCUS_ALL
		choice.pressed.connect(select_palette.bind(id) if is_palette else select_emblem.bind(id))
		row.add_child(choice)


func _refresh() -> void:
	var preview: Texture2D = MapDrawings.post_texture(true, draft)
	_large_preview.texture = preview
	_tile_preview.texture = preview
	for row: HBoxContainer in [_palette_row, _emblem_row]:
		for choice: Button in row.get_children():
			var is_palette: bool = row == _palette_row
			var id: String = str(choice.get_meta("choice_id"))
			choice.set_pressed_no_signal(id == (draft.palette if is_palette else draft.emblem))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		cancel_editing()
		get_viewport().set_input_as_handled()
