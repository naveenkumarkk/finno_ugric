### PopupUI.gd
extends Control

@onready var panel = $CanvasLayer/Panel
@onready var message_label = $CanvasLayer/Panel/VBoxContainer/MessageLabel
@onready var continue_button = $CanvasLayer/Panel/VBoxContainer/ContinueButton

signal popup_closed

func _ready():
	panel.visible = false
	continue_button.pressed.connect(_on_continue_button_pressed)

func show_popup(message: String, button_text: String = "Continue"):
	message_label.text = message
	continue_button.text = button_text
	panel.visible = true

func _unhandled_input(event: InputEvent):
	if not panel.visible:
		return
	if event.is_action_pressed("ui_accept"):
		_on_continue_button_pressed()
		get_viewport().set_input_as_handled()

func _on_continue_button_pressed():
	panel.visible = false
	popup_closed.emit()
