extends CharacterBody2D

const SPEED = 200.0

func _physics_process(delta):
	var direction = Vector2.ZERO #ADDING COMMENT
	
	# arrow keys OR W A S D both work
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	if Input.is_action_pressed("ui_down"):
		direction.y = 1
	
	# normalize so diagonal isn't faster
	if direction.length() > 0:
		direction = direction.normalized()
	
	velocity = direction * SPEED
	move_and_slide()
