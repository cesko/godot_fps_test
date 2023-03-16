extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
var rng = RandomNumberGenerator.new()

const Player = preload("res://player.tscn")
const Zombie = preload("res://zombie.tscn")

var player = null

var running = false

var zombies = []

var kill_counter = 0

func _process(delta):
	if running:
		#var all_zombies = get_tree().get_nodes_in_group("zombies")
		for z in zombies:
			if z.isAlive() == false:
				kill_counter += 1
				print("Killed Zombies: " + str(kill_counter))
				z.queue_free()
				zombies.erase(z)
				add_zombie(get_random_spawn_location())
				add_zombie(get_random_spawn_location())
				continue
			z.update_target_location(player.global_transform.origin)
			
			
		#get_tree().call_group("zombies", "update_target_location", player.global_transform.origin)

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_start_button_pressed():
	main_menu.hide()
	add_player(0)
	add_zombie(get_random_spawn_location())
	running = true

func add_player(peer_id):
	player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)

func get_random_spawn_location():
	var x = rng.randf_range(-3, 3)
	var z = rng.randf_range(-3, 3)
	
	return Vector3(x, 1, z) # by fair dice roll
	
func add_zombie(spawn_location):
	zombies.append(Zombie.instantiate())
	zombies[-1].global_transform.origin = spawn_location
	add_child(zombies[-1])
