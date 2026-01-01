extends CharacterBody2D

@export var speed: float = 35.0

var player: CharacterBody2D
var player_chase := false

var health = 100
var player_in_range = false
var can_take_damage = true

func _physics_process(delta: float) -> void:
	
	deal_with_damage()
	
	if player_chase and is_instance_valid(player):
		var direction := (player.global_position - global_position).normalized()
		velocity = direction * speed

		# Animations
		if abs(direction.x) > abs(direction.y):
			$AnimatedSprite2D.play("side_walk")
			$AnimatedSprite2D.flip_h = direction.x < 0
		elif direction.y < 0:
			$AnimatedSprite2D.play("back_walk")
		else:
			$AnimatedSprite2D.play("side_walk")

	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("idle")

	move_and_slide()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_chase = false

func enemy():
	pass


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = false
		
func deal_with_damage():
	if player_in_range and Global.player_current_attack == true:
		if can_take_damage == true:
			$takeDamageCooldown.start()
			can_take_damage = false
			health = health - 20
			print("slime health = ", health)
			if health <= 0:
				self.queue_free()

func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
