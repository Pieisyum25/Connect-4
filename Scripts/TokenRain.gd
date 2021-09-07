extends Particles2D


func _on_TileMap_game_won(player_number, player_token):
	emitting = true
	process_material.anim_offset = 0.125 * player_token.frame
