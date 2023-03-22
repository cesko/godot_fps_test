extends StaticBody3D

var hit_multiplier = 10
@onready var zombie = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hit(value):
	zombie.take_damage(value * hit_multiplier)
