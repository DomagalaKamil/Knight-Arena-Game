extends Area2D

@export_file("*.tscn") var target_scene_path := ""
@export var target_scene: PackedScene
@export var target_spawn_point := "default"

func _on_body_entered(body):
	if body.is_in_group("player"):
		if target_scene_path == "" and target_scene == null:
			return

		Global.target_spawn_point = target_spawn_point

		var main = get_tree().root.get_node_or_null("Main")
		if main and main.has_method("load_level") and target_scene != null:
			main.load_level(target_scene, target_spawn_point)
		elif target_scene_path != "":
			get_tree().change_scene_to_file(target_scene_path)
		else:
			get_tree().change_scene_to_packed(target_scene)
