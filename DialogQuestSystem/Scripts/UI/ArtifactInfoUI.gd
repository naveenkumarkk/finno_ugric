### ArtifactInfoUI.gd
extends Control

@onready var panel = $CanvasLayer/Panel
@onready var title_label = $CanvasLayer/Panel/VBoxContainer/Title
@onready var artifact_image = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/ArtifactImage
@onready var prop_grid = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/InfoVBox/PropGrid
@onready var legend_text = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/InfoVBox/LegendText
@onready var continue_button = $CanvasLayer/Panel/VBoxContainer/ContinueButton

signal info_closed

func _ready():
	panel.visible = false
	continue_button.pressed.connect(_on_continue_button_pressed)

func show_artifact(data: Dictionary):
	title_label.text = data.get("name", "Unknown Artifact")

	# Clear previous grid rows
	for child in prop_grid.get_children():
		child.queue_free()

	# Build property table rows
	var props = [
		["Region",    data.get("region", "-")],
		["Essence",   data.get("essence", "-")],
		["Dating",    data.get("dating", "-")],
		["Condition", data.get("condition", "-")],
		["Materials", data.get("materials", "-")],
	]
	for prop in props:
		var key_lbl := Label.new()
		key_lbl.text = prop[0] + ":"
		key_lbl.add_theme_color_override("font_color", Color(0.7, 0.88, 1.0))
		key_lbl.add_theme_font_size_override("font_size", 14)
		prop_grid.add_child(key_lbl)
		var val_lbl := Label.new()
		val_lbl.text = prop[1]
		val_lbl.add_theme_font_size_override("font_size", 14)
		val_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		val_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		prop_grid.add_child(val_lbl)

	legend_text.text = '"' + data.get("legend", "") + '"'

	# Load artifact image
	var image_path: String = data.get("image_path", "")
	if image_path != "" and ResourceLoader.exists(image_path):
		artifact_image.texture = load(image_path)
	else:
		artifact_image.texture = null
	panel.visible = true

func _unhandled_input(event: InputEvent):
	if not panel.visible:
		return
	if event.is_action_pressed("ui_accept"):
		_on_continue_button_pressed()
		get_viewport().set_input_as_handled()

func _on_continue_button_pressed():
	panel.visible = false
	info_closed.emit()
