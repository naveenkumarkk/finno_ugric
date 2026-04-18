### QuestItem.gd
@tool
extends StaticBody2D

# item_id maps to artifact id in artifact_data.json.
# Use item_id = "museum" for the museum entrance trigger.
@export var item_id: String = ""
@export var item_quantity: int = 1
@export var item_icon: Texture2D
@onready var sprite_2d = $Sprite2D

# Distance at which labels become visible
const LABEL_SHOW_DISTANCE: float = 60.0

func _ready():
	if not Engine.is_editor_hint():
		if item_icon:
			sprite_2d.set_texture(item_icon)

func _process(_delta):
	if Engine.is_editor_hint():
		if item_icon:
			sprite_2d.set_texture(item_icon)
		return
	# Show/hide name and hint labels based on player proximity
	var player = Global.player
	if player:
		var dist = global_position.distance_to(player.global_position)
		var nearby = dist <= LABEL_SHOW_DISTANCE
		var name_label = get_node_or_null("NameLabel")
		var hint_label = get_node_or_null("HintLabel")
		if name_label:
			name_label.visible = nearby
		if hint_label:
			hint_label.visible = nearby

# Called by ArtifactManager after instantiation to set icon + scale
func setup(tex: Texture2D, sprite_scale: Vector2 = Vector2(0.1, 0.1)):
	item_icon = tex
	sprite_2d.texture = tex
	sprite_2d.scale = sprite_scale
