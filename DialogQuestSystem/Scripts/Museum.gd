extends Node2D

const LIB := "res://Assets/kenney_isometric-miniature-library/Isometric/"
const PLAYER_SCENE := "res://Scenes/Player.tscn"
const INTERACT_DISTANCE := 80.0

var _info_panel: Panel
var _info_title: Label
var _info_image: TextureRect
var _info_body: Label
var _hint_label: Label
var _cases: Array = []   # Array of {position: Vector2, art: Dictionary}
var _nearby_idx: int = -1

func _ready():
	var vp: Vector2 = get_viewport().get_visible_rect().size
	_build_room(vp)
	_build_artifacts(vp)
	_build_info_popup()
	_build_ui(vp)
	_spawn_player(vp)

func _spawn_player(vp: Vector2):
	var player_scene = load(PLAYER_SCENE)
	var player = player_scene.instantiate()
	player.position = Vector2(vp.x / 2.0, vp.y * 0.82)
	add_child(player)
	# Hide main-game HUD in museum
	var hud = player.get_node_or_null("HUD")
	if hud:
		hud.visible = false
	# Lock camera to room
	var cam = player.get_node_or_null("Camera2D")
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = int(vp.x)
		cam.limit_bottom = int(vp.y)

func _build_room(vp: Vector2):
	# Warm floor
	var floor_rect := ColorRect.new()
	floor_rect.size = vp
	floor_rect.color = Color(0.55, 0.43, 0.28)
	floor_rect.z_index = -20
	add_child(floor_rect)
	# Dark wall band at top
	var wall_band := ColorRect.new()
	wall_band.size = Vector2(vp.x, vp.y * 0.30)
	wall_band.color = Color(0.18, 0.12, 0.08)
	wall_band.z_index = -18
	add_child(wall_band)
	# Bookshelves along wall
	var shelf_tex = load(LIB + "bookcaseWideBooks_E.png")
	for i in range(5):
		var s := Sprite2D.new()
		s.texture = shelf_tex
		s.scale = Vector2(0.38, 0.38)
		s.position = Vector2(60 + i * 130, 78)
		s.z_index = -5
		add_child(s)
	# Floor carpets
	var carpet_tex = load(LIB + "floorCarpet_E.png")
	for i in range(4):
		var c := Sprite2D.new()
		c.texture = carpet_tex
		c.scale = Vector2(0.5, 0.5)
		c.position = Vector2(100 + i * 160, 330)
		c.z_index = -10
		add_child(c)
	# Candle stands at the sides
	var candle_tex = load(LIB + "candleStandDouble_E.png")
	for pos in [Vector2(30, 220), Vector2(vp.x - 30, 220)]:
		var c := Sprite2D.new()
		c.texture = candle_tex
		c.scale = Vector2(0.4, 0.4)
		c.position = pos
		add_child(c)
	# Invisible boundary walls to keep the player inside the room
	var walls := [
		Rect2(0, 0, vp.x, 125),          # top
		Rect2(0, vp.y - 18, vp.x, 18),   # bottom
		Rect2(0, 0, 18, vp.y),            # left
		Rect2(vp.x - 18, 0, 18, vp.y),   # right
	]
	for r in walls:
		var wb := StaticBody2D.new()
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = r.size
		col.shape = shape
		wb.position = r.position + r.size * 0.5
		wb.add_child(col)
		add_child(wb)

func _build_artifacts(vp: Vector2):
	var artifacts: Array = Global.museum_artifacts
	var count: int = artifacts.size()
	if count == 0:
		return
	var spacing: float = vp.x / (count + 1)
	var y: float = vp.y * 0.50
	var case_tex = load(LIB + "displayCaseOpen_E.png")
	for i in range(count):
		var art: Dictionary = artifacts[i]
		var x: float = spacing + i * spacing
		# Display case sprite
		var case_spr := Sprite2D.new()
		case_spr.texture = case_tex
		case_spr.scale = Vector2(0.38, 0.38)
		case_spr.position = Vector2(x, y)
		add_child(case_spr)
		# Artifact photo inside the case
		var image_path: String = art.get("image_path", "")
		if image_path != "" and ResourceLoader.exists(image_path):
			var photo := Sprite2D.new()
			photo.texture = load(image_path)
			photo.scale = Vector2(0.13, 0.13)
			photo.position = Vector2(x, y - 46)
			photo.z_index = 2
			add_child(photo)
		# Artifact name label (always visible below case)
		var name_lbl := Label.new()
		name_lbl.text = art.get("name", "?")
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.7))
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.size = Vector2(120, 22)
		name_lbl.position = Vector2(x - 60, y + 58)
		add_child(name_lbl)
		# Solid collision box so the player cannot walk through the case
		var sb := StaticBody2D.new()
		sb.position = Vector2(x, y)
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(58, 72)
		col.shape = shape
		sb.add_child(col)
		add_child(sb)
		_cases.append({"position": Vector2(x, y), "art": art})
	# [E] Inspect hint label — positioned in world space via CanvasLayer
	var hint_cl := CanvasLayer.new()
	hint_cl.layer = 6
	add_child(hint_cl)
	_hint_label = Label.new()
	_hint_label.text = "[E]  Inspect"
	_hint_label.add_theme_font_size_override("font_size", 15)
	_hint_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45))
	_hint_label.visible = false
	hint_cl.add_child(_hint_label)

func _process(_delta):
	# While popup is open, skip proximity checks
	if _info_panel and _info_panel.visible:
		return
	var player = Global.player
	if not player or _cases.is_empty():
		return
	# Find nearest case within interaction range
	var best_idx: int = -1
	var best_dist: float = INTERACT_DISTANCE
	for i in range(_cases.size()):
		var d: float = player.global_position.distance_to(_cases[i].position)
		if d < best_dist:
			best_dist = d
			best_idx = i
	_nearby_idx = best_idx
	if _hint_label:
		if best_idx >= 0:
			# Convert world position to screen space for the CanvasLayer label
			var screen_pos: Vector2 = get_viewport().get_canvas_transform() * _cases[best_idx].position
			_hint_label.position = screen_pos + Vector2(-44, -108)
			_hint_label.visible = true
		else:
			_hint_label.visible = false

func _unhandled_input(event: InputEvent):
	if _info_panel and _info_panel.visible:
		if event.is_action_pressed("ui_cancel"):
			_close_popup()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_interact") and _nearby_idx >= 0:
		_open_popup(_cases[_nearby_idx].art)
		get_viewport().set_input_as_handled()

func _open_popup(art: Dictionary):
	_info_title.text = art.get("name", "")
	_info_body.text = (
		"Essence:   " + art.get("essence", "-") + "\n" +
		"Dating:    " + art.get("dating", "-") + "\n" +
		"Condition: " + art.get("condition", "-") + "\n" +
		"Materials: " + art.get("materials", "-") + "\n\n" +
		'"' + art.get("legend", "") + '"'
	)
	var image_path: String = art.get("image_path", "")
	if image_path != "" and ResourceLoader.exists(image_path):
		_info_image.texture = load(image_path)
	else:
		_info_image.texture = null
	_info_panel.visible = true
	if Global.player:
		Global.player.can_move = false

func _close_popup():
	_info_panel.visible = false
	if Global.player:
		Global.player.can_move = true

func _build_info_popup():
	var cl := CanvasLayer.new()
	cl.layer = 10
	add_child(cl)
	_info_panel = Panel.new()
	_info_panel.set_anchors_preset(Control.PRESET_CENTER)
	_info_panel.size = Vector2(560, 420)
	_info_panel.position = Vector2(-280, -210)
	_info_panel.visible = false
	cl.add_child(_info_panel)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 16
	vbox.offset_top = 12
	vbox.offset_right = -16
	vbox.offset_bottom = -12
	vbox.add_theme_constant_override("separation", 14)
	_info_panel.add_child(vbox)
	_info_title = Label.new()
	_info_title.add_theme_font_size_override("font_size", 22)
	_info_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_info_title)
	var hbox := HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(hbox)
	_info_image = TextureRect.new()
	_info_image.custom_minimum_size = Vector2(160, 200)
	_info_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_info_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hbox.add_child(_info_image)
	_info_body = Label.new()
	_info_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_info_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_body.add_theme_font_size_override("font_size", 14)
	hbox.add_child(_info_body)
	var close_btn := Button.new()
	close_btn.text = "Close  [Esc]"
	close_btn.add_theme_font_size_override("font_size", 18)
	close_btn.pressed.connect(_close_popup)
	vbox.add_child(close_btn)

func _build_ui(vp: Vector2):
	var cl := CanvasLayer.new()
	cl.layer = 5
	add_child(cl)
	var title := Label.new()
	title.text = "Finno-Ugric Heritage Museum"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.5))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 10
	title.offset_bottom = 50
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cl.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Walk near an artifact and press  [E]  to inspect"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	subtitle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	subtitle.offset_top = 46
	subtitle.offset_bottom = 76
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cl.add_child(subtitle)
	var exit_btn := Button.new()
	exit_btn.text = "Exit Exhibition"
	exit_btn.add_theme_font_size_override("font_size", 17)
	exit_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	exit_btn.offset_left = -210
	exit_btn.offset_top = -55
	exit_btn.offset_right = -16
	exit_btn.offset_bottom = -14
	exit_btn.pressed.connect(func(): get_tree().quit())
	cl.add_child(exit_btn)
