class_name Character extends CharacterBody3D

signal died

@export_group("Character Attributes")
@export var health:float = 5.0
@export var health_max:float = 5.0

var alive:bool = true

var real_velocity_filtered_parameter = 0.5
var _real_velocity_filtered:Vector3 = Vector3.ZERO


func _process(delta):
	if global_position.y < -100:
		print("Character fell from map")
		_on_death()

func _physics_process(delta):
	_calculate_real_velocity_filtered(delta)
	

func _ready():
	health = health_max

func change_health(delta) -> float:
	health += delta
	health = clamp(health, 0, health_max)
	if alive and health <= 0:
		alive = false
		_on_death()
	return health

func get_health() -> float:
	return health

func set_health(new_health:float) -> void:
	health = new_health

func get_health_percent() -> float:
	return health/health_max

func get_health_max() -> float:
	return health_max

func _on_death():
	print("Character died")
	died.emit()


func _calculate_real_velocity_filtered(delta):
	var alpha = real_velocity_filtered_parameter * delta
	_real_velocity_filtered *= (1.0 - alpha)
	_real_velocity_filtered += alpha * get_real_velocity()
