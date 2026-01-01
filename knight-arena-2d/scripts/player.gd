extends CharacterBody2D

var enemy_in_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

const SPEED = 100
var current_direction = "down"

var attack_ip = false #"ip = in progress"
func _ready():
	add_to_group("player")
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta):
	
	enemy_atack()
	attack()
	
	if health <= 0:
		player_alive = false
		health = 0
		self.queue_free()
		
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
			if attack_ip == false:
				animation.play("side_idle")
	
	elif current_direction == "left":
		animation.flip_h = true
		if movement == 1:
			animation.play("side_walk")
		else:
			if attack_ip == false:
				animation.play("side_idle")
	
	elif current_direction == "down":
		animation.flip_h = false
		if movement == 1:
			animation.play("front_walk")
		else:
			if attack_ip == false:
				animation.play("front_idle")
	
	elif current_direction == "up":
		animation.flip_h = false
		if movement == 1:
			animation.play("back_walk")
		else:
			if attack_ip == false:
				animation.play("back_idle")

func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_range = true


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_range = false

func enemy_atack():
	if enemy_in_range and enemy_attack_cooldown == true:
		health = health - 10
		enemy_attack_cooldown = false
		$attackCooldown.start()
		print(health)

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true
	
func attack():
	var dir = current_direction
	if Input.is_action_just_pressed("Attack"):
		Global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
			$dealAttackTimer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
			$dealAttackTimer.start()
		if dir == "down":
			$AnimatedSprite2D.play("front_attack")
			$dealAttackTimer.start()
		if dir == "up":
			$AnimatedSprite2D.play("back_attack")
			$dealAttackTimer.start()
	
func _on_deal_attack_timer_timeout() -> void:
	$dealAttackTimer.stop()
	Global.player_current_attack = false
	attack_ip = false
