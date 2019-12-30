extends TextureRect

enum States {Idle = 0, Blocked, Starting, Finished, Checked}

var neighbors = []

export var stateColors = [Color.white, Color.black, Color.blue, Color.red, Color.orange];
onready var tween = $Tween
var index;
var state;
var size;
var isHovered = false;
var isEnabled = true;

signal hoverOn( _self )

func init(_size, _index, _parent):
	_load_image(_size);
	state = States.Idle;
	index = _index;
	size = _size
	$Tween.connect("tween_completed", self, "on_Animation_Finished");
	self.connect("hoverOn", _parent, "on_Square_Hover_On");

func _load_image(_size):
	var imageTexture = ImageTexture.new();
	var image = Image.new();
	image.create(_size, _size, false,Image.FORMAT_RGB8);
	image.fill(Color.white);
	imageTexture.create_from_image(image);
	texture = imageTexture;

func set_state(new_state):
	if (new_state == state): return
	tween.interpolate_property(self, "modulate",
       stateColors[state], stateColors[new_state], .25,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	state = new_state
	isEnabled = false

func get_state():
	return state

func on_Animation_Finished(object, key):
	isEnabled = true;

func _physics_process(delta):
	var pos = get_global_transform().get_origin() + Vector2(size / 2, size / 2);
	var mousePos = get_global_mouse_position();
	var inRange = (pos - mousePos).length() < size / 2;
	if(inRange and not isHovered):
		isHovered = true
		emit_signal("hoverOn", self)
	elif(not inRange):
		isHovered = false

func add_neighbor(square):
	neighbors.append(square)

func get_neighbors():
	return neighbors

