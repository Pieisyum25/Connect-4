extends TileMap

var grid = []
var grid_size = Vector2(7, 6)

onready var token_scene = preload("res://Scenes/Token.tscn")

var num_of_colours = 8

# Players:
var p1 = {"number" : 1, "colour" : 0}
var p2 = {"number" : 2, "colour" : 1}
var current_player = p1
var current_token = null

# Game:
var move_timer_finished = true
var game_over = false
var dir = {"LEFT" : Vector2.LEFT,
			"RIGHT" : Vector2.RIGHT,
			"UP" : Vector2.UP,
			"DOWN" : Vector2.DOWN,
			"UP_LEFT" : Vector2.UP + Vector2.LEFT,
			"UP_RIGHT" : Vector2.UP + Vector2.RIGHT,
			"DOWN_LEFT" : Vector2.DOWN + Vector2.LEFT,
			"DOWN_RIGHT" : Vector2.DOWN + Vector2.RIGHT}

signal game_won

func _ready():
	
	# assign player colours:
	randomize()
	p1.colour = randi() % num_of_colours
	p2.colour = p1.colour
	while p2.colour == p1.colour:
		p2.colour = randi() % num_of_colours
	
	init_grid()
	start_turn()

func init_grid():
	for x in grid_size.x:
		grid.append([])
		grid[x].resize(grid_size.y)

func start_turn():
	current_token = token_scene.instance()
	add_child(current_token)
	current_token.set_colour(current_player.colour)
	var viewport_rect = get_viewport_rect()
	var pick_up_position = viewport_rect.position + Vector2(viewport_rect.size.x/2, viewport_rect.size.y + cell_size.y/2)
	current_token.set_position(pick_up_position)
	current_token.follow_mouse()

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_R:
		get_tree().reload_current_scene()
	if game_over:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT and move_timer_finished:
		var clicked_grid_pos = world_to_map(get_global_mouse_position())
		if not within_grid_bounds(clicked_grid_pos):
			return
		var clicked_column = clicked_grid_pos.x
		
		if not column_has_space(clicked_column):
			return
			
		for y in range(grid[clicked_column].size()-1, -1, -1):
			if grid[clicked_column][y] == null:
				grid[clicked_column][y] = current_token
				var grid_pos = Vector2(clicked_column, y)
				var landing_pos = map_to_world(grid_pos) + cell_size/2
				var drop_pos = map_to_world(Vector2(clicked_column, -1)) + cell_size/2
				current_token.drop(drop_pos, landing_pos)
				move_timer_finished = false # comment out for quick moves!
				$MoveTimer.start()
				break
		
		# check all tokens of colour to see if 4 lined up
		var winning_tokens = []
		if game_won(current_token.get_colour(), winning_tokens):
			
			# highlight winning tokens:
			for token in winning_tokens:
				token.highlight()
			
			# set win text to player colour:
			emit_signal("game_won", current_player.get("number"), current_token)
			game_over = true
			return
		
		# if no winner:
		next_turn()

func within_grid_bounds(grid_pos):
	return grid_pos.x >= 0 and grid_pos.x < grid_size.x and grid_pos.y >= -1 and grid_pos.y < grid_size.y

func column_has_space(clicked_column):
	for slot in grid[clicked_column]:
		if slot == null:
			return true
	return false

func game_won(var colour, var winning_tokens):
	# run through all tokens of colour
	# for each token, go in straight line in each direction (including diagonals)
	# if 4 (or more), return true (also add them to array so we can do cool stuff with them)
	# if tokens all exhausted, return false
	for x in grid.size():
		for y in grid[x].size():
			var grid_pos = Vector2(x, y)
			var token = grid[x][y]
			if token == null or token.get_colour() != colour:
				continue
			
			# the fun begins:
			# if valid direction
			for direction in dir.values():
				winning_tokens.append(token)
				var next_pos = grid_pos + direction
				var next_token
				while valid_direction(next_pos, colour):
					# keep going in direction:
					next_token = grid[next_pos.x][next_pos.y]
					winning_tokens.append(next_token)
					next_pos += direction
				if winning_tokens.size() >= 4:
					return true
				else:
					winning_tokens.clear()
	return false

func valid_direction(var next_pos, var colour):
	if not within_grid_bounds(next_pos):
		return false
	var token = grid[next_pos.x][next_pos.y]
	return token != null and token.get_colour() == colour

func next_turn():
	if current_player == p1:
		current_player = p2
	else:
		current_player = p1
	start_turn()


func _on_MoveTimer_timeout():
	move_timer_finished = true
