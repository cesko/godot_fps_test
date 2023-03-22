extends Node

@onready var level = $NavigationRegion3D/level
@onready var main_menu = $CanvasLayer/MainMenu
@onready var ui_canvas = $UI
@onready var health_pickup = $NavigationRegion3D/level/HealthPickUp
@onready var ammu_pickup = $NavigationRegion3D/level/AmmuPickUp

const Player = preload("res://player.tscn")
const Zombie = preload("res://zombie.tscn")

var rng = RandomNumberGenerator.new()

var player = null

var running = false

var zombies = []

var kill_counter = 0

# Level
var _level_counter = -1
var _levels = [] 
var _current_number_of_enemies = 0
var _total_number_of_enemies = 0

func _ready():
	ui_canvas.hide()
	_levels.append(Level.new(10,3))
	_levels.append(Level.new(20,5))
	_levels.append(Level.new(40,10))
	_levels.append(Level.new(40,20))

func _process(delta):
	if running:
		if _total_number_of_enemies == _levels[_level_counter]._total_enemies:
			if _current_number_of_enemies == 0:
				running = false
				if _level_counter < _levels.size()-1:
					ui_canvas.player_notification("Wave " + str(_level_counter+2) + " in 10s")
					get_tree().create_timer(7).timeout.connect(start_level)
				else:
					ui_canvas.player_notification("You Survived!")
		else:
			if _current_number_of_enemies < _levels[_level_counter]._max_enemies:
				add_zombie()
		#var all_zombies = get_tree().get_nodes_in_group("zombies")
		for z in zombies:
			if z.isAlive() == false:
				kill_counter += 1
				print("Killed Zombies: " + str(kill_counter))
				z.queue_free()
				zombies.erase(z)
				_current_number_of_enemies -= 1
				continue
			z.update_target_location(player.global_transform.origin)
			
			
		#get_tree().call_group("zombies", "update_target_location", player.global_transform.origin)

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_start_button_pressed():
	main_menu.hide()
	_level_counter = -1
	add_player(0)
	ui_canvas.show()
	start_level()

func start_level():
	ui_canvas.player_notification("New Wave in 3", true)
	await get_tree().create_timer(1).timeout
	ui_canvas.player_notification("New Wave in 2", true)
	await get_tree().create_timer(1).timeout
	ui_canvas.player_notification("New Wave in 1", true)
	await get_tree().create_timer(1).timeout
	ui_canvas.player_notification("Zombies!!", true)
	_current_number_of_enemies = 0
	_total_number_of_enemies = 0
	_level_counter += 1
	running = true

func add_player(peer_id):
	player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	player.global_transform = level.getPlayerSpawn() # .origin = Vector3(0, 3, 6)
	player.killed.connect(player_killed)
	ui_canvas.set_player(player)
	
	health_pickup.player=player
	ammu_pickup.player=player
	
func add_zombie():
	zombies.append(Zombie.instantiate())
	add_child(zombies[-1])
	zombies[-1].global_transform = level.getZombieSpawn(player.global_transform.origin)
	zombies[-1].attack_player.connect(player.take_damage)
	var r = rng.randf_range(.9, 1.1)
	zombies[-1].scale = Vector3(r, r, r)
	_current_number_of_enemies += 1
	_total_number_of_enemies += 1
	
	# randomly create a special zombie
	var special_zombies = rng.randf()
	if special_zombies > .8 and special_zombies <= .9:
		zombies[-1].SPEED = 6
		zombies[-1].base_color = Color(150.0/255, 100.0/255, 50.0/255)
		zombies[-1].changeColor(zombies[-1].base_color)
	elif special_zombies > .9:
		zombies[-1].SPEED = 2.5
		zombies[-1].base_color = Color(100.0/255, 100.0/255, 50.0/255)
		zombies[-1].health = 11
		zombies[-1].health_max = 11
		zombies[-1].DAMAGE = 2
		zombies[-1].scale = Vector3(1.3, 1.2, 1.3)
		zombies[-1].changeColor(zombies[-1].base_color)
	
	
func player_killed():
	ui_canvas.player_notification("YOU DIED")
	
	
	
