extends PlayerControlBase

class_name PlayerControlFlying

# Parameter
@export var speed = 5.0

# Internals

func _ready():
	super()

func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		var pitch = -event.relative.y * Settings.mouse_sensitivity
		var yaw = -event.relative.x * Settings.mouse_sensitivity
		rotate_y(yaw)
		camera.rotate_object_local(Vector3.RIGHT, pitch)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)


func _physics_process(delta):
	
	var current_speed = speed
	
	var surge = Input.get_axis("forward", "backward")
	var sway  = Input.get_axis("strafe_left", "strafe_right")
	var heave = Input.get_axis("crouch", "jump")
	var direction = transform.basis * camera.transform.basis * Vector3(sway, 0, surge)
	direction.y += heave
	direction = direction.normalized()
	
	velocity = current_speed * direction
	
	apply_movement()
	
