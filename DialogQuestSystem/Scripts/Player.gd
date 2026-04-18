### Player.gd

extends CharacterBody2D

# Scene-Tree Node references
@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var artifact_count_label = $HUD/Coins/Amount
@onready var hud_tracker = $HUD/QuestTracker
@onready var tracker_title = $HUD/QuestTracker/Details/Title

# Variables
@export var speed = 150
var can_move = true

func _ready():
	Global.player = self
	# Show region info on HUD tracker
	hud_tracker.visible = true
	tracker_title.text = "Aleksei Peterson\nMari Region"
	artifact_count_label.text = "0/5"

	# Connect to ArtifactManager to update count display
	ArtifactManager.artifact_count_changed.connect(_on_artifact_count_changed)
	
# Input for movement
func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * speed
	
	# Turn raycast towards movement direction
	if velocity != Vector2.ZERO:
		ray_cast_2d.target_position = velocity.normalized() * 50

# Movement & Animation
func _physics_process(delta):
	if can_move:
		get_input()
		move_and_slide()
		update_animation()
	
# Animation
func update_animation():
	if velocity == Vector2.ZERO:
		animated_sprite.play("idle")
	else:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				animated_sprite.play("walk_right")
			else:
				animated_sprite.play("walk_left")
		else:
			if velocity.y > 0:
				animated_sprite.play("walk_down")  
			else:
				animated_sprite.play("walk_up")

func _input(event):
	# Interact with artifact items or museum entrance
	if can_move:
		if event.is_action_pressed("ui_interact"):
			var target = ray_cast_2d.get_collider()
			if target != null:
				if target.is_in_group("Item"):
					var item_id: String = target.item_id
					if item_id == "museum":
						ArtifactManager.enter_museum()
					elif item_id != "":
						ArtifactManager.collect_artifact(item_id)
						target.queue_free()
				elif target.is_in_group("NPC"):
					# NPC dialog kept for future use
					can_move = false
					target.start_dialog()

# Update artifact count display on HUD
func _on_artifact_count_changed(count: int):
	artifact_count_label.text = str(count) + "/5"
