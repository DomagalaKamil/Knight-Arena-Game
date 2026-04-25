extends Control

const SAVE_PATH := "user://save_game.save"
const WORLD_SCENE := "res://scenes/world.tscn"

@onready var continue_button: Button = %ContinueButton
@onready var new_game_button: Button = %NewGameButton
@onready var options_button: Button = %OptionsButton

func _ready() -> void:
	var has_save := FileAccess.file_exists(SAVE_PATH)
	continue_button.visible = has_save
	options_button.disabled = true

	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)

	if has_save:
		continue_button.grab_focus()
	else:
		new_game_button.grab_focus()

func _on_continue_pressed() -> void:
	if not _load_saved_game():
		_start_game()

func _on_new_game_pressed() -> void:
	_reset_game_state()
	_start_game()

func _reset_game_state() -> void:
	Global.player_current_attack = false
	Global.player_health = 100
	Global.player_alive = true
	Global.target_spawn_point = "default"
	Global.has_pending_player_position = false
	Global.pending_player_position = Vector2.ZERO

func _start_game() -> void:
	get_tree().change_scene_to_file(WORLD_SCENE)

func _load_saved_game() -> bool:
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		return false

	var save_data = save_file.get_var()
	if not (save_data is Dictionary):
		return false

	var scene_path := str(save_data.get("scene", WORLD_SCENE))
	if not ResourceLoader.exists(scene_path):
		scene_path = WORLD_SCENE

	Global.player_current_attack = false
	Global.player_health = int(save_data.get("player_health", 100))
	Global.player_alive = bool(save_data.get("player_alive", true))
	Global.pending_player_position = Vector2(
		float(save_data.get("player_x", 0.0)),
		float(save_data.get("player_y", 0.0))
	)
	Global.has_pending_player_position = true

	get_tree().change_scene_to_file(scene_path)
	return true
