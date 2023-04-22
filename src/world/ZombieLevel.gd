extends Node3D

@onready var player_spawn = $PlayerSpawn
var zombie_spawn = []

var rng = RandomNumberGenerator.new()

func _ready():
	zombie_spawn.append($ZombieSpawn01)
	zombie_spawn.append($ZombieSpawn02)
	zombie_spawn.append($ZombieSpawn03)
	zombie_spawn.append($ZombieSpawn04)
	zombie_spawn.append($ZombieSpawn05)
	zombie_spawn.append($ZombieSpawn06)
	zombie_spawn.append($ZombieSpawn07)
	zombie_spawn.append($ZombieSpawn08)
	zombie_spawn.append($ZombieSpawn09)
	zombie_spawn.append($ZombieSpawn10)
	zombie_spawn.append($ZombieSpawn11)

func getPlayerSpawn():
	return player_spawn.getSpawn()

func getZombieSpawn(player_location:Vector3, safe_radius=5) -> Transform3D:

	for i in range(10):
		var k = rng.randi_range(0, 10)
		var t = zombie_spawn[k].getSpawn()
		var d = player_location.distance_to(t.origin)
		if d > safe_radius:
			t.origin.x += rng.randf_range(-0.2, 0.2)
			t.origin.z += rng.randf_range(-0.2, 0.2)
			return t
		else:
			print("Player too close to spawn " + str(k) + ", try finding another one")
	return Transform3D(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1), Vector3(0,0,0))
