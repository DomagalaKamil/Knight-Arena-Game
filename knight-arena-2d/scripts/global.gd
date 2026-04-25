extends Node

# Combat
var player_current_attack := false

# Player stats (persist across levels)
var player_health := 100
var player_alive := true

# Scene transition data
var target_spawn_point := "default"

# Save/load handoff data
var has_pending_player_position := false
var pending_player_position := Vector2.ZERO
