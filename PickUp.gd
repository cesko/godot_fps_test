class_name PickUp

extends Node3D

signal collected

var player:CharacterBody3D
@export var pickup_radius:float = 1.0

var pickup_enabled:bool = true

var _pickup_radius_squared

# Called when the node enters the scene tree for the first time.
func _ready():
	_pickup_radius_squared = pickup_radius*pickup_radius
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		if global_transform.origin.distance_squared_to(player.global_transform.origin) <= _pickup_radius_squared:
			on_pickup()
			collected.emit()

func on_pickup():
	player._health = player._health_max
	pass

func enable_pickup():
	pickup_enabled = true
	set_visible(true)

func disable_pickup():
	pickup_enabled = false
	set_visible(false)
