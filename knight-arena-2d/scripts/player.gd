extends CharacterBody2D

const SPEED = 100
var current_direction = "down"

func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta):
	var input_vector := Vector2.ZERO

	if Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1
	if Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1
	if Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1
	if Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * SPEED
		update_direction(input_vector)
		play_animation(1)
	else:
		velocity = Vector2.ZERO
		play_animation(0)

	move_and_slide()


func update_direction(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		current_direction = "right" if dir.x > 0 else "left"
	else:
		current_direction = "down" if dir.y > 0 else "up"

func play_animation(movement):
	var animation = $AnimatedSprite2D
	
	if current_direction == "right":
		animation.flip_h = false
		if movement == 1:
			animation.play("side_walk")
		else:
			animation.play("side_idle")
	
	elif current_direction == "left":
		animation.flip_h = true
		if movement == 1:
			animation.play("side_walk")
		else:
			animation.play("side_idle")
	
	elif current_direction == "down":
		animation.flip_h = false
		if movement == 1:
			animation.play("front_walk")
		else:
			animation.play("front_idle")
	
	elif current_direction == "up":
		animation.flip_h = false
		if movement == 1:
			animation.play("back_walk")
		else:
			animation.play("back_idle")
