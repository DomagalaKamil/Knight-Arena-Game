extends CanvasLayer

const SAVE_PATH := "user://save_game.save"
const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"

var player: CharacterBody2D

@onready var panel: Control = %Panel
@onready var save_button: Button = %SaveButton
@onready var options_button: Button = %OptionsButton
@onready var exit_to_menu_button: Button = %ExitToMenuButton
@onready var quit_button: Button = %QuitButton
@onready var status_label: Label = %StatusLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	options_button.disabled = true

	save_button.pressed.connect(_on_save_pressed)
	exit_to_menu_button.pressed.connect(_on_exit_to_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("pause_menu"):
		toggle()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	status_label.text = ""

	if visible:
		save_button.grab_focus()

func _on_save_pressed() -> void:
	if player == null:
		status_label.text = "Save failed"
		return

	if player.has_method("save_state"):
		player.save_state()

	var save_data := {
		"scene": _current_scene_path(),
		"player_x": player.global_position.x,
		"player_y": player.global_position.y,
		"player_health": Global.player_health,
		"player_alive": Global.player_alive
	}

	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		status_label.text = "Save failed"
		return

	save_file.store_var(save_data)
	status_label.text = "Game saved"

func _on_exit_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _current_scene_path() -> String:
	var current_scene := get_tree().current_scene
	if current_scene == null or current_scene.scene_file_path == "":
		return "res://scenes/world.tscn"

	return current_scene.scene_file_path
