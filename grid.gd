extends GridContainer

# test
var grid = [
	[0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0],
]

var grey = Color(0.5,0.5,0.5)
var white = Color(1,1,1)
var red = Color(1,0,0)
var green = Color(0,1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Loop for creating 81 spinboxes in a 9 by 9 grid. The grid layout is
	# automatically done by the grid node.
	for i in range(9**2):
		# Create new spinbox and set its attributes
		var new_input = SpinBox.new()
		new_input.size_flags_horizontal = 3 # 3 = expand and fill
		new_input.size_flags_vertical = 3 # 3 = expand and fill
		
		new_input.min_value = 0
		new_input.max_value = 9
		
		new_input.set_name(str(i))
		
		# Effectively removes spinbox arrows by replacing with a tiny
		# transparent picture.
		var blank_tiny = load("res://blank_tiny.svg")
		new_input.add_theme_icon_override("up", blank_tiny)
		new_input.add_theme_icon_override("up_disabled", blank_tiny)
		new_input.add_theme_icon_override("up_hover", blank_tiny)
		new_input.add_theme_icon_override("up_pressed", blank_tiny)
		new_input.add_theme_icon_override("down", blank_tiny)
		new_input.add_theme_icon_override("down_disabled", blank_tiny)
		new_input.add_theme_icon_override("down_hover", blank_tiny)
		new_input.add_theme_icon_override("down_pressed", blank_tiny)
		new_input.add_theme_icon_override("updown", blank_tiny)
		new_input.add_theme_constant_override("buttons_width", 1)
		
		new_input.set_editable(false)
		
		new_input.value_changed.connect(_on_value_changed.bind(new_input))
		
		# Accessing the underlying line_edit node and setting attributes
		var line_edit = new_input.get_line_edit()
		line_edit.context_menu_enabled = false
		line_edit.set_horizontal_alignment(1) # 1 = Centered
		line_edit.set_max_length(1)
		line_edit.add_theme_color_override("font_color", grey)
		
		add_child(new_input)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Resizes font with window size change
	var a = round(get_viewport().get_visible_rect().size[0]/50)
	for child in get_children():
		child.get_line_edit().add_theme_font_size_override("font_size", a)


func _on_value_changed(value, name):
	if value == 0:
		name.get_line_edit().add_theme_color_override("font_color", grey)
	else:
		name.get_line_edit().add_theme_color_override("font_color", white)


func _on_new_game_pressed():
	"""
	Create a new Sudoku grid
	"""
	var invalid = true
	var average_tries = 0
	while invalid:
		average_tries += 1
		invalid = false
		grid = [
		[0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0],
		]
		
		for child in get_children():
			var grid_value = name_to_grid(child.name)
			var allowed_nums = [0,1,2,3,4,5,6,7,8,9]
			var random_num = 0
			while not valid_state(grid_value) and len(allowed_nums) > 1:
				allowed_nums.erase(random_num)
				random_num = allowed_nums[randi() % len(allowed_nums)]
				grid[grid_value[0]][grid_value[1]] = random_num
			if valid_state(grid_value):
				child.set_value(grid[grid_value[0]][grid_value[1]])
				child.get_line_edit().add_theme_color_override("font_color", white)
				child.get_line_edit().set_editable(true)
			else:
				invalid = true
				break
	print(average_tries)
	
	full_to_partial()


func _on_auto_solve_pressed():
	for child in get_children():
		child.get_line_edit().add_theme_color_override("font_color", white)
		var grid_value = name_to_grid(child.name)
		child.set_value(grid[grid_value[0]][grid_value[1]])
		child.get_line_edit().set_editable(false)


func _on_check_pressed():
	for child in get_children():
		var grid_value = name_to_grid(child.name)
		if child.get_value() == 0:
			pass
		elif child.get_value() != grid[grid_value[0]][grid_value[1]]:
			child.get_line_edit().add_theme_color_override("font_color", red)
		else:
			child.get_line_edit().add_theme_color_override("font_color", green)


# checks if a particular row, col, and subgrid are valid
func valid_state(grid_position):
	var valid = true
	var grid_value = grid[grid_position[0]][grid_position[1]]
	
	var row_values = grid[grid_position[0]].duplicate()
	row_values.erase(grid_value)
	
	var col_values = []
	for i in range(9):
		col_values.append(grid[i][grid_position[1]])
	col_values.erase(grid_value)
	
	var subgrid_values = []
	var subgrid_x = grid_position[0] / 3
	var subgrid_y = grid_position[1] / 3
	
	for i in range(3):
		for j in range(3):
			subgrid_values.append(grid[3*subgrid_x+i][3*subgrid_y+j])
	subgrid_values.erase(grid_value)
	
	if grid_value == 0:
		valid = false
	elif grid_value in row_values:
		valid = false
	elif grid_value in col_values:
		valid = false
	elif grid_value in subgrid_values:
		valid = false
	
	return valid


# convert spinbox name to x,y coordinates i.e 00 to 80
func name_to_grid(name):
	name = name.to_int()
	var row = name / 9
	var col = name % 9
	return [row,col]


func full_to_partial():
	for child in get_children():
		var random_num = randi() % 2
		child.set_editable(random_num)
		if child.editable == true:
			child.set_value(0)


# features
# v1:
	# 9x9 spinbox grid with check,solve,newgame buttons -/
	# random algorithm for full-grid generation -/
	# full-grid to partial-grid (not necessarily unique) -/
	# solver just checks the pre-computed solution -/
	# (Theming)
	# spinbox arrows 'removed' -/
	# values (default  white, blank grey, wrong red, right green) -/
	# check button [default], solve button [red], newgame button [green] -/
	# background panel and subgrid dividers -/
# v2:
	# semi-random solver
	# full-grid to 1-solution partial-grid (use solver to detect multi-solutions)
	# (Theming)
	# special event when check solution when all green.
# v3 (optional):
	# non-random algorithm for full-grid generation (all 1's, all 2's ...)
	# (Theming)
	# rows/cols/subgrids highlighted, same number highlighted
	# spinbox alternating background colors
# testing, both for functionality , efficiency , usability
