extends RigidBody3D
@export var speed : float = 1.0
@onready var y_pivot : Node3D = $xPivot
@onready var x_pivot : Node3D = $xPivot/yPivot
var sens : float = 0.06

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# decouple camera from player rotation
	y_pivot.top_level = true

func _integrate_forces(state):
	# movement math
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (y_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_just_pressed("jump"):
		apply_central_impulse(Vector3(0,15,0))
	apply_central_impulse(direction * speed)
	
	# setting the camera position to the rotation
	y_pivot.global_position = global_position

# camera rotation
func _input(event):
	if event is InputEventMouseMotion:
		y_pivot.rotate(Vector3(0,1,0),deg_to_rad(-event.relative.x * sens))
		x_pivot.rotate(Vector3(1,0,0),deg_to_rad(-event.relative.y * sens))
