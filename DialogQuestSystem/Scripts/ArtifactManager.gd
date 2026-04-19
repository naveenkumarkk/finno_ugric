### ArtifactManager.gd
## Autoload singleton that manages the entire Finno-Ugric Expedition game flow.
## Flow: Initial popup -> Explore -> Collect artifact -> Info popup -> Checkpoint quiz
##       -> Progress popup -> (repeat x5) -> Museum -> Final quiz (x5) -> End

extends Node

# Game state machine
enum Phase {
	EXPLORING,
	ARTIFACT_INFO,
	CHECKPOINT_QUIZ,
	PROGRESS_POPUP,
	MUSEUM_INTRO,
	FINAL_QUIZ,
	GAME_OVER
}

var phase: Phase = Phase.EXPLORING

# Data
var all_artifact_data: Array = []
var final_quiz_data: Array = []
var artifacts_collected: int = 0
const TOTAL_ARTIFACTS: int = 5
var current_artifact: Dictionary = {}
var final_quiz_index: int = 0

# UI node references (instantiated at runtime)
var artifact_info_ui = null
var quiz_ui = null
var popup_ui = null

signal artifact_count_changed(count: int)
signal game_finished

func _ready():
	# Wait one frame so the main scene is fully loaded before adding UI nodes
	await get_tree().process_frame
	_setup_ui()
	_load_data()
	_spawn_artifacts()
	_show_initial_popup()

func _setup_ui():
	var root = get_tree().root

	var artifact_info_scene = load("res://Scenes/UI/ArtifactInfoUI.tscn")
	artifact_info_ui = artifact_info_scene.instantiate()
	root.add_child(artifact_info_ui)
	artifact_info_ui.info_closed.connect(_on_info_closed)

	var quiz_scene = load("res://Scenes/UI/QuizUI.tscn")
	quiz_ui = quiz_scene.instantiate()
	root.add_child(quiz_ui)
	quiz_ui.quiz_completed.connect(_on_quiz_completed)

	var popup_scene = load("res://Scenes/UI/PopupUI.tscn")
	popup_ui = popup_scene.instantiate()
	root.add_child(popup_ui)
	popup_ui.popup_closed.connect(_on_popup_closed)

func _load_data():
	var file = FileAccess.open("res://Resources/artifact_data.json", FileAccess.READ)
	if file == null:
		push_error("ArtifactManager: Cannot open artifact_data.json")
		return
	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(json_text) != OK:
		push_error("ArtifactManager: JSON parse error - " + json.get_error_message())
		return

	var data = json.get_data()
	all_artifact_data = data.get("artifacts", [])
	final_quiz_data = data.get("final_quiz", [])

func _spawn_artifacts():
	var item_scene = load("res://Scenes/QuestItem.tscn")
	if item_scene == null:
		push_error("ArtifactManager: Cannot load QuestItem.tscn")
		return

	var main = get_tree().current_scene

	# Positions within the land tile area (world x ~48-480, y ~32-320)
	var artifact_positions = {
		"hip_jewelry": Vector2(160, 80),
		"bag":         Vector2(280, 195),
		"beer_bucket": Vector2(460, 210),
		"hunting_kit": Vector2(120, 270),
		"robe":        Vector2(350, 260),
	}

	# Per-artifact icon scale (compensates for different source image sizes)
	var artifact_scales = {
		"hip_jewelry": Vector2(0.025, 0.025),
		"bag":         Vector2(0.08, 0.08),
		"beer_bucket": Vector2(0.08, 0.08),
		"hunting_kit": Vector2(0.08, 0.08),
		"robe":        Vector2(0.08, 0.08),
	}

	for artifact in all_artifact_data:
		var art_id: String = artifact.get("id", "")
		var art_name: String = artifact.get("name", art_id)
		if art_id == "":
			continue

		var item = item_scene.instantiate()
		item.item_id = art_id
		item.position = artifact_positions.get(art_id, Vector2(200, 200))
		main.add_child(item)

		# Use icon_path from JSON (falls back to icon1 if missing)
		var icon_path: String = artifact.get("icon_path", "res://Assets/Icons/icon1.png")
		if not ResourceLoader.exists(icon_path):
			icon_path = "res://Assets/Icons/icon1.png"
		var icon_tex = load(icon_path)
		var icon_scale: Vector2 = artifact_scales.get(art_id, Vector2(0.08, 0.08))
		item.setup(icon_tex, icon_scale)

		# Name label above the sprite — hidden until player is near
		var name_label = Label.new()
		name_label.name = "NameLabel"
		name_label.text = art_name
		name_label.add_theme_font_size_override("font_size", 8)
		name_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.position = Vector2(-50, -22)
		name_label.custom_minimum_size = Vector2(100, 0)
		name_label.visible = false
		item.add_child(name_label)

		# "Press E" hint below the sprite — hidden until player is near
		var hint_label = Label.new()
		hint_label.name = "HintLabel"
		hint_label.text = "[E]"
		hint_label.add_theme_font_size_override("font_size", 7)
		hint_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint_label.position = Vector2(-20, 10)
		hint_label.custom_minimum_size = Vector2(40, 0)
		hint_label.visible = false
		item.add_child(hint_label)

	# Museum entrance — far right of the land area
	var museum = item_scene.instantiate()
	museum.item_id = "museum"
	museum.position = Vector2(450, 100)
	main.add_child(museum)
	museum.setup(load("res://Assets/Images/museum_transparent.png"), Vector2(0.08, 0.08))

	var museum_label = Label.new()
	museum_label.name = "NameLabel"
	museum_label.text = "MUSEUM\n(need 5/5)"
	museum_label.add_theme_font_size_override("font_size", 8)
	museum_label.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	museum_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	museum_label.position = Vector2(-50, -30)
	museum_label.custom_minimum_size = Vector2(100, 0)
	museum_label.visible = false
	museum.add_child(museum_label)

	var museum_hint = Label.new()
	museum_hint.name = "HintLabel"
	museum_hint.text = "[E]"
	museum_hint.add_theme_font_size_override("font_size", 7)
	museum_hint.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
	museum_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	museum_hint.position = Vector2(-20, 10)
	museum_hint.custom_minimum_size = Vector2(40, 0)
	museum_hint.visible = false
	museum.add_child(museum_hint)

func _show_initial_popup():
	if popup_ui == null:
		return
	if Global.player:
		Global.player.can_move = false
	popup_ui.show_popup(
		"Welcome, Aleksei Peterson\n\nYou are an ethnographer exploring the Mari region.\nYour mission is to collect 5 cultural artifacts before taking them to the museum.\n\nMove with the arrow keys. Press E near an object to collect it.\n\nGood Luck!",
		"Start Expedition"
	)

func get_artifact(artifact_id: String) -> Dictionary:
	for art in all_artifact_data:
		if art.get("id", "") == artifact_id:
			return art
	return {}

# Called by Player when pressing E on an artifact item
func collect_artifact(artifact_id: String):
	if phase != Phase.EXPLORING:
		return
	current_artifact = get_artifact(artifact_id)
	if current_artifact.is_empty():
		push_warning("ArtifactManager: Artifact not found: " + artifact_id)
		return
	if Global.player:
		Global.player.can_move = false
	phase = Phase.ARTIFACT_INFO
	AudioManager.play_item_collected()
	artifact_info_ui.show_artifact(current_artifact)

# Called by Player when pressing E on the museum entrance (after all collected)
func enter_museum():
	if phase != Phase.EXPLORING:
		return
	if artifacts_collected < TOTAL_ARTIFACTS:
		popup_ui.show_popup(
			"You have collected %d/%d artifacts.\nCollect all artifacts before entering the museum!" % [artifacts_collected, TOTAL_ARTIFACTS],
			"OK"
		)
		if Global.player:
			Global.player.can_move = false
		return
	AudioManager.play_reach_museum()
	if Global.player:
		Global.player.can_move = false
	phase = Phase.MUSEUM_INTRO
	popup_ui.show_popup(
		"You have arrived at the museum.\n\nBefore opening the exhibition, you must prove your knowledge of the collected artifacts.\nAnswer the final questions correctly to complete your mission.",
		"Start Final Quiz"
	)

# --- Signal handlers ---

func _on_info_closed():
	if phase != Phase.ARTIFACT_INFO:
		return
	phase = Phase.CHECKPOINT_QUIZ
	var quiz = current_artifact.get("quiz", {})
	AudioManager.play_quiz_opens()
	quiz_ui.show_quiz(quiz)

func _on_quiz_completed():
	match phase:
		Phase.CHECKPOINT_QUIZ:
			artifacts_collected += 1
			artifact_count_changed.emit(artifacts_collected)
			phase = Phase.PROGRESS_POPUP
			if artifacts_collected >= TOTAL_ARTIFACTS:
				popup_ui.show_popup(
					"All artifacts were collected. Great job!!\nThe museum awaits your findings!!",
					"Go to Museum"
				)
			else:
				popup_ui.show_popup(
					"You have collected %d/%d artifacts.\nContinue your research" % [artifacts_collected, TOTAL_ARTIFACTS],
					"Continue"
				)
		Phase.FINAL_QUIZ:
			final_quiz_index += 1
			if final_quiz_index < final_quiz_data.size():
				AudioManager.play_quiz_opens()
				quiz_ui.show_quiz(
					final_quiz_data[final_quiz_index],
					"Final Quiz (%d/%d)\nAnswer the final questions correctly to complete your mission." % [final_quiz_index + 1, final_quiz_data.size()]
				)
			else:
				phase = Phase.GAME_OVER
				AudioManager.play_mission_completed()
				popup_ui.show_popup(
					"Congratulations!\n\nAll artifacts were collected, and the final quiz was completed.\nYou have successfully completed your ethnographic mission.",
					"Enter Museum"
				)

func _on_popup_closed():
	match phase:
		Phase.PROGRESS_POPUP:
			phase = Phase.EXPLORING
			if Global.player:
				Global.player.can_move = true
		Phase.MUSEUM_INTRO:
			phase = Phase.FINAL_QUIZ
			final_quiz_index = 0
			AudioManager.play_final_quiz()
			AudioManager.play_quiz_opens()
			quiz_ui.show_quiz(
				final_quiz_data[0],
				"Final Quiz (1/%d)\nAnswer the final questions correctly to complete your mission." % final_quiz_data.size()
			)
		Phase.GAME_OVER:
			game_finished.emit()
			# Clean up floating UI nodes before switching scenes
			if artifact_info_ui:
				artifact_info_ui.queue_free()
				artifact_info_ui = null
			if quiz_ui:
				quiz_ui.queue_free()
				quiz_ui = null
			if popup_ui:
				popup_ui.queue_free()
				popup_ui = null
			# Transition to the in-game museum exhibition
			Global.museum_artifacts = all_artifact_data.duplicate(true)
			get_tree().change_scene_to_file("res://Scenes/Museum.tscn")
		# Initial popup (EXPLORING phase) — just resume movement
		Phase.EXPLORING:
			if Global.player:
				Global.player.can_move = true
