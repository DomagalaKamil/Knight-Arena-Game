extends Node2D

@onready var level_container := get_node_or_null("World/LevelContainer")
@onready var player := find_child("Player", true, false)

var current_level: Node = null

func load_level(scene: PackedScene, spawn_point: String):
	if scene == null:
		return

	if level_container == null:
		get_tree().change_scene_to_packed(scene)
		return

	if current_level:
		current_level.queue_free()

	current_level = scene.instantiate()
	level_container.add_child(current_level)

	await get_tree().process_frame

	if player == null:
		return

	var spawns = current_level.get_node_or_null("PlayerSpawnPoints")
	if spawns and spawns.has_node(spawn_point):
		player.global_position = spawns.get_node(spawn_point).global_position
