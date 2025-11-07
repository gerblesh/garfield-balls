extends RigidBody3D
class_name Ball

enum C {
		NULL,
		GARFIELD,
		ANDRE,
		TELETUBBY,
		SUSSY,
		OG_GARFIELD,
}

var accel : float = 1.0
@export var current_char: C = C.GARFIELD

var up_direction := Vector3.UP


const JUMP_GRACE := 0.2
var falling := JUMP_GRACE
var auth: bool = false
var display_name: String

@onready var name_label: Label3D = $Fixed/Label3D
@onready var floor_cast: ShapeCast3D = $ShapeCast3D
@onready var y_pivot : Node3D = $xPivot
@onready var x_pivot : Node3D = $xPivot/yPivot
@onready var camera: Camera3D = $xPivot/yPivot/SpringArm3d/Camera3d
@onready var model: Node3D = $Model
@onready var fixed: Node3D = $Fixed

var sens : float = 0.06

@onready var last_grounded_pos := global_position

func _ready() -> void:
	set_multiplayer_authority(name.to_int())

	name_label.text = display_name
	fixed.top_level = true
	# auth = name.to_int() == Network.multiplayer.get_unique_id()
	if not is_multiplayer_authority():
		auth = false
		set_physics_process(false)
		set_process_input(false)
		camera.current = false
		camera.queue_free()
		floor_cast.top_level = false
		floor_cast.enabled = false
		Network.player_disconnected.connect(_on_disconnect)
		return

	camera.current = true
	auth = true
	set_collision_layer_value(3, true) # skibidi now the player is on the jump pad
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# decouple camera from player rotation
	y_pivot.top_level = true


func reset_pos() -> void:
	global_position = last_grounded_pos
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

# Player disconnected
func _on_disconnect(id: int) -> void:
	if id == get_multiplayer_authority():
		queue_free()

func _physics_process(_delta: float) -> void:
	floor_cast.global_position = global_position
	# movement math
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (y_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if floor_cast.is_colliding():
		falling = 0
		var norm := floor_cast.get_collision_normal(0) # I guess index zero is the one idfk atp
		# ok so stupid idea, we align the acceleration to the normal of the plane!!
		var new_accel := accel
		var weight := minf(linear_velocity.length() / 5, 1.0)
		
		linear_damp = lerp(1.4, 0.7, weight * weight)
		new_accel = lerp(1.2,0.9, weight * weight)

		var s: Vector3 = direction.slide(norm).normalized() * new_accel
		apply_central_impulse(s)
		# last_grounded_pos = global_position
	else:
		falling += _delta
		linear_damp = 0

	if Input.is_action_just_pressed("jump") and falling < JUMP_GRACE:
		var norm := up_direction
		if floor_cast.is_colliding():
			norm = floor_cast.get_collision_normal(0) # I guess index zero is the one idfk atp

		apply_central_impulse(norm * 15)
		falling = JUMP_GRACE
		floor_cast.enabled = false

	if not floor_cast.enabled and falling > JUMP_GRACE + 0.2:
		# can jump again
		floor_cast.enabled = true
	
	# setting the camera position to the rotation
	y_pivot.global_position = global_position

func _process(_delta: float) -> void:
	if model.current_char != current_char:
		model.set_character(current_char)
	fixed.global_position = global_position
	#set_multiplayer_authority(name.to_int())

# camera rotation
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		y_pivot.rotate(Vector3(0,1,0),deg_to_rad(-event.relative.x * sens))
		x_pivot.rotate(Vector3(1,0,0),deg_to_rad(-event.relative.y * sens))
