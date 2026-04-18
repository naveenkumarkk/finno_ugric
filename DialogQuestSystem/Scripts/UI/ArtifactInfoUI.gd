### ArtifactInfoUI.gd
extends Control

@onready var panel = $CanvasLayer/Panel
@onready var title_label = $CanvasLayer/Panel/VBoxContainer/Title
@onready var artifact_image = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/ArtifactImage
@onready var info_label = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/InfoText
@onready var continue_button = $CanvasLayer/Panel/VBoxContainer/ContinueButton

signal info_closed

func _ready():
	panel.visible = false
	continue_button.pressed.connect(_on_continue_button_pressed)

func show_artifact(data: Dictionary):
	title_label.text = data.get("name", "Unknown Artifact")
	info_label.text = (
		"Essence:    " + data.get("essence", "-") + "\n" +
		"Dating:     " + data.get("dating", "-") + "\n" +
		"Condition:  " + data.get("condition", "-") + "\n" +
		"Materials:  " + data.get("materials", "-") + "\n\n" +
		"\"" + data.get("legend", "") + "\""
	)
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
