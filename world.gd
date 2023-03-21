extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var ui_canvas = $UI
var rng = RandomNumberGenerator.new()

const Player = preload("res://player.tscn")
const Zombie = preload("res://zombie.tscn")

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
				add_zombie(get_random_spawn_location())
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
	player.global_transform.origin = Vector3(0, 3, 6)
	player.killed.connect(player_killed)
	ui_canvas.set_player(player)

func get_random_spawn_location():
	var x = rng.randf_range(-3, 3)
	var z = rng.randf_range(-3, 3)
	
	return Vector3(x, 1, z)
	
func add_zombie(spawn_location):
	zombies.append(Zombie.instantiate())
	add_child(zombies[-1])
	zombies[-1].global_transform.origin = spawn_location
	zombies[-1].attack_player.connect(player.take_damage)
	_current_number_of_enemies += 1
	_total_number_of_enemies += 1
	
func player_killed():
	ui_canvas.player_notification("YOU DIED")
	
	
	
