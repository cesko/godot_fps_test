extends Node3D

class_name ZombieMap

var player_spawns := []
var enemy_spawns := []

@onready var trigger_health = $InstantHealth
@onready var trigger_ammu = $InstantAmmu
@onready var rifle_pickup = $RiflePickup

@onready var _trigger_health_tf = trigger_health.global_transform

var rng = RandomNumberGenerator.new()

func _ready():
	enemy_spawns = find_child("EnemySpawns").get_children()
	rifle_pickup.hide()
	rifle_pickup.enabled = false

func get_random_spawn( list_of_spawns:Array ) -> Transform3D:
	var tf = Transform3D()
	if list_of_spawns.is_empty():
		return tf
	return list_of_spawns[0].global_transform

func get_random_player_spawn() -> Transform3D:
	return get_random_spawn(player_spawns)
		
func get_random_enemy_spawn(player_location:Vector3, safe_radius=5) -> Transform3D:

	var start_index = rng.randi_range(0, enemy_spawns.size()-1)
	var index = start_index
	
	for i in range(enemy_spawns.size()):
		var tf = enemy_spawns[index].global_transform
		var d = player_location.distance_to(tf.origin)
		if d > safe_radius:
			tf.origin.x += rng.randf_range(-0.2, 0.2) # randomize slightly
			tf.origin.z += rng.randf_range(-0.2, 0.2) # randomize slightly
			tf.basis = Basis(Vector3.UP, rng.randf_range(-PI, PI))
			return tf
		else:
			print("Player too close to spawn " + str(index) + ", try finding another one")
			index += 1
			if index >= enemy_spawns.size():
				index = 0
	
	# Last resort
	return enemy_spawns[index].global_transform
			

# set up after wave was cleared
func wave_cleared(wave):
	if not trigger_health:
		print("Restock Health")
		trigger_health = preload("res://scenes/trigger/instant_health.tscn").instantiate()
		add_child(trigger_health)
		trigger_health.global_transform = _trigger_health_tf
	else:
		print("health:" + str(trigger_health))
	
	if wave == 1:
		rifle_pickup.show()
		rifle_pickup.enabled = true
