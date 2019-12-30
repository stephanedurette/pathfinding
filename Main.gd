extends Control

export var grid_length = 500

export var grid_columns = 10
export var traversal_time = .2

export (Dictionary) var grid_columns_range = {"min": 4, "max": 30}
export (Dictionary) var traversal_speed_time = {"min": 1, "max": .001}

signal update_values(grid_size, traversal_speed)

onready var grid = get_node("CenterContainer/HBoxContainer/Grid")

onready var btn_CreateGraph = get_node("CenterContainer/HBoxContainer/Controls/Editing/HBoxContainer/btn_CreateGraph")
onready var btn_InsertBlocks = get_node("CenterContainer/HBoxContainer/Controls/Editing/btn_InsertBlocks")
onready var btn_InsertEndpoints = get_node("CenterContainer/HBoxContainer/Controls/Editing/btn_InsertEndpoints")
onready var btn_ClearChecked = get_node("CenterContainer/HBoxContainer/Controls/Editing/btn_ClearChecked")

onready var btn_BFS = get_node("CenterContainer/HBoxContainer/Controls/Traversal/btn_BFS")
onready var btn_DFS = get_node("CenterContainer/HBoxContainer/Controls/Traversal/btn_DFS")
onready var btn_AStar = get_node("CenterContainer/HBoxContainer/Controls/Traversal/btn_A*")

onready var hCont_controls = get_node("CenterContainer/HBoxContainer/Controls")

onready var sld_traversalSpeed = get_node("CenterContainer/HBoxContainer/Controls/Traversal/sld_traversalSpeed")
onready var spn_gridSize = get_node("CenterContainer/HBoxContainer/Controls/Editing/HBoxContainer/spn_GridSize")

func _ready(): 
	spn_gridSize.value = grid_columns
	spn_gridSize.max_value = grid_columns_range["max"]
	spn_gridSize.min_value = grid_columns_range["min"]
	
	sld_traversalSpeed.min_value = traversal_speed_time["max"]
	sld_traversalSpeed.max_value = traversal_speed_time["min"]
	sld_traversalSpeed.value = _get_traversal_time(traversal_time)
	
	self.connect("update_values", grid, "_update_runtime_values");
	sld_traversalSpeed.connect("value_changed", self, "_update_traversalSpeed")
	spn_gridSize.connect("value_changed", self, "_update_gridSize")
	
	btn_CreateGraph.connect("pressed", grid, "_on_Create_Graph")
	btn_InsertBlocks.connect("pressed", grid, "_on_Insert_Blocks")
	btn_InsertEndpoints.connect("pressed", grid, "_on_Insert_Endpoints")
	btn_ClearChecked.connect("pressed", grid, "_on_Clear_Checked")
	
	btn_BFS.connect("pressed", grid, "_on_BFS")
	btn_DFS.connect("pressed", grid, "_on_DFS")
	btn_AStar.connect("pressed", grid, "_on_AStar")
	
	hCont_controls.connect("mouse_entered", grid, "_on_Controls_Entered")
	
	grid.init(grid_columns, traversal_time)
	
func _get_traversal_time(var sliderValue):
	return traversal_speed_time["max"] + traversal_speed_time["min"] - sliderValue

func _update_traversalSpeed(value):
	traversal_time = _get_traversal_time(value)
	emit_signal("update_values", grid_columns, traversal_time)
	
func _update_gridSize(value):
	grid_columns = value
	emit_signal("update_values", grid_columns, traversal_time)
