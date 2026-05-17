### QuizUI.gd
extends Control

@onready var panel = $CanvasLayer/Panel
@onready var header_label = $CanvasLayer/Panel/VBoxContainer/HeaderLabel
@onready var question_label = $CanvasLayer/Panel/VBoxContainer/QuestionLabel
@onready var options_container = $CanvasLayer/Panel/VBoxContainer/OptionsContainer
@onready var feedback_label = $CanvasLayer/Panel/VBoxContainer/FeedbackLabel
@onready var continue_button = $CanvasLayer/Panel/VBoxContainer/ContinueButton

signal quiz_completed

var correct_index: int = -1
var answered_correctly: bool = false

func _ready():
	panel.visible = false
	continue_button.text = "Jätka"
	continue_button.pressed.connect(_on_continue_button_pressed)

func show_quiz(quiz_data: Dictionary, header: String = "Tõesta, mida oled õppinud.\nEdasiliikumiseks vasta õigesti."):
	correct_index = quiz_data.get("correct", -1)
	answered_correctly = false
	header_label.text = header
	question_label.text = quiz_data.get("question", "")
	feedback_label.text = ""
	continue_button.visible = false

	# Eemalda vanad vastusevariandid
	for child in options_container.get_children():
		child.queue_free()

	# Lisa uued vastusevariandid
	var options: Array = quiz_data.get("options", [])
	for i in options.size():
		var btn = Button.new()
		btn.text = options[i]
		btn.add_theme_font_size_override("font_size", 20)
		btn.pressed.connect(_on_option_pressed.bind(i))
		options_container.add_child(btn)

	panel.visible = true
	AudioManager.duck_background()

func _on_option_pressed(index: int):
	if answered_correctly:
		return

	if index == correct_index:
		answered_correctly = true
		AudioManager.play_correct()
		feedback_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
		feedback_label.text = "Õige!"
		for child in options_container.get_children():
			child.disabled = true
		continue_button.visible = true
	else:
		AudioManager.play_wrong()
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		feedback_label.text = "Vale vastus. Proovi uuesti!"

func _unhandled_input(event: InputEvent):
	if not panel.visible:
		return

	# Klahvid 1–4 valivad vastusevariandi
	var key_map = {
		KEY_1: 0, KEY_2: 1, KEY_3: 2, KEY_4: 3
	}

	if event is InputEventKey and event.pressed and not event.echo:
		if key_map.has(event.keycode):
			_on_option_pressed(key_map[event.keycode])
			get_viewport().set_input_as_handled()
			return

	# Enter/tühik kinnitab, kui nupp "Jätka" on nähtav
	if event.is_action_pressed("ui_accept") and continue_button.visible:
		_on_continue_button_pressed()
		get_viewport().set_input_as_handled()

func _on_continue_button_pressed():
	panel.visible = false
	AudioManager.unduck_background()
	quiz_completed.emit()