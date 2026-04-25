extends CharacterBody2D

# ======================
# CONSTANTS & VARIABLES
# ======================

const SPEED := 100
const PAUSE_MENU_SCENE := preload("res://scenes/pause_menu.tscn")

var current_direction := "front"
var facing_left := false

var enemy_attack_cooldown := true

var health := 100
var player_alive := true

# ======================
# NODE REFERENCES
# ======================

@onready var animation := $AnimatedSprite2D
@onready var healthbar := $healthBar
@onready var regen_timer := $regenTimer
@onready var attack_timer := $attackCooldown

var pause_menu: CanvasLayer

# ======================
# READY
# ======================

func _ready():
	add_to_group("player")
	attack_timer.one_shot = true

	# Load persistent data
	health = Global.player_health
	player_alive = Global.player_alive
	if Global.has_pending_player_position:
		global_position = Global.pending_player_position
		Global.has_pending_player_position = false

	update_healthbar()
	_setup_pause_menu()

# ======================
# PROCESS
# ======================

func _physics_process(delta):
	if not player_alive:
		return

	player_movement()
	if not Global.player_current_attack:
		update_animation()

# ======================
# MOVEMENT
# ======================

func player_movement():
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction.x > 0:
		current_direction = "side"
		facing_left = false
	elif direction.x < 0:
		current_direction = "side"
		facing_left = true
	elif direction.y > 0:
		current_direction = "front"
	elif direction.y < 0:
		current_direction = "back"

	velocity = direction * SPEED
	move_and_slide()

# ======================
# ANIMATIONS
# ======================

func update_animation():
	animation.flip_h = current_direction == "side" and facing_left

	if velocity.length() == 0:
		animation.play(current_direction + "_idle")
	else:
		animation.play(current_direction + "_walk")

# ======================
# COMBAT
# ======================

func _input(event):
	if event.is_action_pressed("attack") and not Global.player_current_attack:
		player_attack()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu") and pause_menu:
		pause_menu.toggle()
		get_viewport().set_input_as_handled()

func player_attack():
	Global.player_current_attack = true
	animation.flip_h = current_direction == "side" and facing_left
	animation.play(current_direction + "_attack")
	attack_timer.start()

func _on_attack_cooldown_timeout():
	Global.player_current_attack = false

# ======================
# DAMAGE & HEALTH
# ======================

func take_damage(amount: int):
	if not enemy_attack_cooldown or not player_alive:
		return

	health -= amount
	enemy_attack_cooldown = false

	if health <= 0:
		health = 0
		player_alive = false

	save_state()
	update_healthbar()

	regen_timer.start()
	await get_tree().create_timer(1.0).timeout
	enemy_attack_cooldown = true

func player():
	pass

func _on_regen_timer_timeout():
	if health < 100 and player_alive:
		health += 10
		if health > 100:
			health = 100

	save_state()
	update_healthbar()

# ======================
# HEALTHBAR
# ======================

func update_healthbar():
	healthbar.value = health
	healthbar.visible = health < 100

# ======================
# GLOBAL SYNC
# ======================

func save_state():
	Global.player_health = health
	Global.player_alive = player_alive

func _setup_pause_menu() -> void:
	pause_menu = PAUSE_MENU_SCENE.instantiate()
	pause_menu.player = self
	add_child.call_deferred(pause_menu)

func _on_player_hitbox_body_entered(_body: Node2D):
	pass

func _on_player_hitbox_body_exited(_body: Node2D):
	pass

func _on_deal_attack_timer_timeout():
	pass
