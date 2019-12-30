extends GridContainer

export (PackedScene) var square;

enum squareStates {Idle = 0, Blocked, Starting, Finished, Checked}
enum editStates {Idle, Blocks, EndPoints, Simulating}

export var grid_length = 500;

var traversal_speed;
var num_columns;
var editState

var hoveredSquare = null
var startSquare = null
var endSquare = null

func init(_num_columns, _traversal_speed):
	traversal_speed = _traversal_speed
	num_columns = _num_columns
	editState = editStates.Idle
	_create_new_grid()

func _update_startend_squares():
	if (endSquare != null):
		if(endSquare.index == hoveredSquare.index):
			endSquare.set_state(squareStates.Idle)
			endSquare = null
	if (startSquare != null):
		if(startSquare.index == hoveredSquare.index):
			startSquare.set_state(squareStates.Idle)
			startSquare = null

func _process(delta):
	if (hoveredSquare == null): return
	match editState:
		editStates.Blocks:
			if(Input.is_action_pressed("left_click")):
				_update_startend_squares()
				hoveredSquare.set_state(squareStates.Blocked)
			elif(Input.is_action_pressed("right_click")):
				_update_startend_squares()
				hoveredSquare.set_state(squareStates.Idle)
						
		editStates.EndPoints:
			if(Input.is_action_pressed("left_click")):
				_update_startend_squares()
				if (startSquare != null):
					startSquare.set_state(squareStates.Idle)
				startSquare = hoveredSquare
				hoveredSquare.set_state(squareStates.Starting)
			elif(Input.is_action_pressed("right_click")):
				_update_startend_squares()
				if (endSquare != null):
					endSquare.set_state(squareStates.Idle)
				endSquare = hoveredSquare
				hoveredSquare.set_state(squareStates.Finished)
				

func _create_new_grid():
	startSquare= null
	endSquare = null
	var squares = []
	for square in get_children():
		remove_child(square);
	var squareSize = grid_length / num_columns;
	columns = num_columns;
	var index = 0;
	for i in range(num_columns*num_columns):
		var s = square.instance();
		s.init(squareSize, index, self);
		add_child(s);
		squares.append(s);
		index += 1;
	_setup_neighboring_squares(squares)
	
func _setup_neighboring_squares(squares):
	for i in range(squares.size()):
		if ((i - num_columns) >= 0): squares[i].add_neighbor(squares[i - num_columns]) #up
		if(i % num_columns != 0): squares[i].add_neighbor(squares[i - 1]) #left
		if ((i + 1) % num_columns != 0): squares[i].add_neighbor(squares[i + 1]) #right
		if (i + num_columns < num_columns*num_columns): squares[i].add_neighbor(squares[i + num_columns]) #down
		

func on_Square_Hover_On(square):
	hoveredSquare = square
	
func recursive_dfs(currentSquare, checked):
	if currentSquare.get_state() == squareStates.Finished:
		print("finished")
		return true
		
	checked.append(currentSquare)
	
	for s in currentSquare.get_neighbors():
		if s.get_state() != squareStates.Blocked and not checked.has(s):
			if (recursive_dfs(s, checked) == true):
				return true
	return false

##REFACTORING

func _update_runtime_values(var _gridSize, var _traversalSpeed): #signal from main
	num_columns = int(_gridSize)
	traversal_speed = _traversalSpeed

func _on_Create_Graph():
	if editState == editStates.Simulating: return
	_create_new_grid()

func _on_Insert_Blocks():
	if editState == editStates.Simulating: return
	editState = editStates.Blocks

func _on_Insert_Endpoints():
	if editState == editStates.Simulating: return
	editState = editStates.EndPoints

func _on_BFS():
	_on_Clear_Checked()
	if editState == editStates.Simulating: return
	if(startSquare != null and endSquare!= null):
		var checked = []
		var toCheck = [startSquare]
		_recursive_bfs(toCheck, checked)
		_animate_Checked(checked)

func _recursive_bfs(var toCheck, var checked):
	var square = toCheck.pop_front()
	print(square.index)
	if square.get_state() == squareStates.Finished:
		print("finished")
		return true
		
	checked.append(square)
	
	for s in square.get_neighbors():
		if s.get_state() != squareStates.Blocked and not checked.has(s) and not toCheck.has(s):
			toCheck.append(s)
	return _recursive_bfs(toCheck, checked)
	

func _on_DFS():
	_on_Clear_Checked()
	if editState == editStates.Simulating: return
	if(startSquare != null and endSquare!= null):
		var checked = []
		recursive_dfs(startSquare, checked)
		_animate_Checked(checked)

func _animate_Checked(checked):
	editState = editStates.Simulating
	for i in range(checked.size() - 1):
			checked[i + 1].set_state(squareStates.Checked)
			yield(get_tree().create_timer(traversal_speed), "timeout")
	
	editState = editStates.Idle

#https://www.geeksforgeeks.org/a-search-algorithm/
#with manhattan distance
func _on_AStar(): #finished this
	_on_Clear_Checked()
	var checked = []
	if editState == editStates.Simulating: return
	var sNode = {"node": startSquare, "g":0, "h":0, "f":0}
	var open = [sNode]
	var closed = []
	var running = true
	
	while (open.size() > 0 and running):
		var min_index = -1
		var min_value = 10000
		for i in range(open.size()):
			if open[i]["f"] < min_value:
				min_value = open[i]["f"]
				min_index = i
		var q = open[min_index]
		checked.append(q["node"])
		open.remove(min_index)
		
		for s in q["node"].get_neighbors():
			print(s.index)
			if s.state == squareStates.Finished:
				print("finished")
				running = false
				break
			if s.state == squareStates.Blocked or checked.has(s): continue
			var g = q["g"] + 1
			var xDist = abs(s.index - endSquare.index)
			var yDist = abs((s.index % num_columns) - (endSquare.index % num_columns))
			var h = xDist + yDist
			var f = g + h
			
			var is_in_open = false
			for i in open:
				if (i["node"].index == s.index): is_in_open = true
			if is_in_open: continue
			
			var is_in_closed = false
			for i in closed:
				if (i["node"].index == s.index): is_in_closed = true
			if is_in_closed: continue
			
			var newnode = {"node": s, "g":g, "h":h, "f":f}
			open.append(newnode)
		closed.append(sNode)
	_animate_Checked(checked)
			

func _on_Controls_Entered():
	hoveredSquare = null

func _on_Clear_Checked():
	if editState == editStates.Simulating: return
	for s in get_children():
		if s.get_state() == squareStates.Checked:
			s.set_state(squareStates.Idle)
	
	




