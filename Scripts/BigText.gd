extends Label

func _on_TileMap_game_won(player_number, player_token):
	text = "Player "+str(player_number)+" Wins\n\nPress\nR\nto play again"
	add_color_override("font_color", player_token.get_colour_value())
	visible = true
	$BlinkTimer.start()


func _on_BlinkTimer_timeout():
	visible = !visible
