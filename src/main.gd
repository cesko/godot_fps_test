extends Node

@onready var world = $World
@onready var hud = $HUD
@onready var ui = $UI

var active_player 
var player_flying
var player_fps

var map

# Game Info
@export var zombie_map:PackedScene
@export var waves : Array[Wave]
@export var initial_wave:int = 0

var _current_wave = initial_wave - 1
var _active_enemies = 0
var _enemies_killed_in_wave = 0
var _wave_finished = true

var _enemy_counter_mutex

func _ready():
	_enemy_counter_mutex = Mutex.new()
	load_main_menu()
	pass
	
func _process(delta):
	pass

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		GameManager.toggle_pause() # this only works for pausing, not unpausing
	
	if Input.is_action_just_pressed("debug_cam"):
		change_camera()

func load_main_menu():
	var content = preload("res://scenes/ui/menu_content.tscn").instantiate()
	content.start_game.connect(start_game)
	content.quit.connect(quit_game)
	content.continue_game.connect(GameManager.resume_game)
	
	var layout = preload("res://scenes/ui/menu_layout.tscn").instantiate()
	ui.add_child(layout) 
	layout.logo_texture = preload("res://assets/textures/murder_floor_logo.png")
	layout.setContent(content)
	
	GameManager.menu = layout

func load_hud():
	var crosshair = preload("res://scenes/hud/hud_crosshair.tscn").instantiate()
	var hud_health = preload("res://scenes/hud/hud_health_display.tscn").instantiate()
	var hud_weapon_info = preload("res://scenes/hud/hud_weapon_info.tscn").instantiate()
	var hud_notification = preload("res://scenes/hud/hud_large_notification.tscn").instantiate()
	var hud_push_notification = preload("res://scenes/hud/push_notification.tscn").instantiate()
	var wave_counter = preload("res://scenes/hud/hud_wave_counter.tscn").instantiate()
	hud.add_child(crosshair)
	hud.add_child(hud_health)
	hud.add_child(hud_weapon_info)
	hud.add_child(hud_notification)
	hud.add_child(hud_push_notification)
	hud.add_child(wave_counter)
	
	# set globals
	GameManager.hud.health_display = hud_health
	GameManager.hud.weapon_info = hud_weapon_info
	GameManager.hud.crosshair = crosshair
	GameManager.hud.notification = hud_notification
	GameManager.hud.push_notification = hud_push_notification
	GameManager.hud.wave_counter = wave_counter

func hide_node_children(n:Node):
	if n.has_method("hide"):
		n.hide()
	else:
		for c in n.get_children():
			if c.has_method("hide"):
				c.hide()

func start_game(gm:GameMode):
	hide_node_children(ui)
	print(gm.mode)
	if gm.mode == GameMode.Mode.TEST:
		start_plane_world()
	elif gm.mode == GameMode.Mode.ZOMBIES:
		start_zombie_game(zombie_map)
	GameManager.game_status = GameManager.GameStatus.RUNNING
	
	
func start_zombie_game(map_scene:PackedScene):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	load_hud()
	
	GameManager.world = map_scene.instantiate()
	world.add_child(GameManager.world)
	
	player_fps = preload("res://scenes/player_control/player_control_fps.tscn").instantiate()
	world.add_child(player_fps)
	player_fps.global_transform = GameManager.world.get_random_player_spawn()
	player_fps.died.connect(_on_player_died)
	active_player = player_fps
	GameManager.player = player_fps
	active_player.set_active(true)
	
	player_flying = preload("res://scenes/player_control/player_control_flying.tscn").instantiate()
	world.add_child(player_flying)
	player_flying.global_position.x = -2
	player_flying.global_position.y = 1
	player_flying.set_active(false)
	
	var weapons = get_tree().get_nodes_in_group("weapon")
	for w in weapons:
		w.spread_updated.connect(GameManager.hud.crosshair.setSpread)
	
	get_tree().create_timer(3.0, false).timeout.connect(start_next_wave)

func start_resting_period( duration=10.0 ):
	get_tree().create_timer(duration, false).timeout.connect(start_next_wave)	
	get_tree().create_timer(duration - 3, false).timeout.connect( func(): GameManager.hud.notification.countdown(3) )
	

func start_next_wave():
	GameManager.hud.notification.notify("ZOMBIES ARE COMING FOR YOUR BRAINS")
	_wave_finished = false
	_enemy_counter_mutex.lock()
	_current_wave += 1
	_active_enemies = 0
	_enemies_killed_in_wave = 0
	_enemy_counter_mutex.unlock()
	
	for i in range(waves[_current_wave].initial_number_of_zombies):
		spawn_zombie()
		
	get_tree().create_timer(5.0).timeout.connect(interval_spawn)
	update_wave_info()
		

func interval_spawn():
	if _wave_finished:
		return
	
	if _active_enemies + _enemies_killed_in_wave < waves[_current_wave].total_number_of_zombies:
		spawn_zombie()
		var random_interval = randf_range(.7 * waves[_current_wave].nominal_spawn_interval_sec, 1.3 * waves[_current_wave].nominal_spawn_interval_sec)
		get_tree().create_timer(random_interval, false).timeout.connect(interval_spawn)

func process_wave():
	update_wave_info()
	if _wave_finished:
		return
	
	if _enemies_killed_in_wave == waves[_current_wave].total_number_of_zombies:
		_wave_finished = true
		# wave completed
		GameManager.world.wave_cleared(_current_wave)
		if (_current_wave+1) < waves.size():
			GameManager.hud.notification.notify("Wave " + str(_current_wave + 1) + " completed" )
			start_resting_period()
		else:
			GameManager.hud.notification.notify("You survived! Well done")
			game_won()
	
	elif _active_enemies < waves[_current_wave].minimum_number_of_zombies: # waves[_current_wave].initial_number_of_zombies:
		if _active_enemies + _enemies_killed_in_wave < waves[_current_wave].total_number_of_zombies:
			spawn_zombie()

func game_won():
	print("You won!")
	Engine.time_scale = 0.5
	await get_tree().create_timer(2).timeout
	Engine.time_scale = 0
	
func spawn_zombie_head(tf:Transform3D, initial_velocity:Vector3, color:Color):
	var zombie_head_scene = preload("res://scenes/characters/zombie_head.tscn")
	waves[_current_wave].total_number_of_zombies += 1
	
	var zombie = zombie_head_scene.instantiate()
	print("spawn zombie head at " + str(tf))
	zombie.set_global_transform(tf)
	zombie.change_color(color)
	zombie.base_color = color
	GameManager.world.add_child(zombie)
	zombie.target = player_fps
	zombie.died.connect(func(): _on_zombie_died(zombie))
	zombie.velocity = initial_velocity
	
	_enemy_counter_mutex.lock()
	_active_enemies += 1
	_enemy_counter_mutex.unlock()
	
	
func spawn_zombie():
	var zombie_normal_scene = preload("res://scenes/characters/zombie.tscn")
	var zombie_fast_scene = preload("res://scenes/characters/zombie_fast.tscn")
	
	var zombie_lightheaded_scene = preload("res://scenes/characters/zombie_lightheaded.tscn")
	
	var p_total = waves[_current_wave].probability_normal_zombie
	p_total += waves[_current_wave].probability_fast_zombie
	p_total += waves[_current_wave].probability_lightheaded_zombie
	
	var zombie
	var random_var = p_total * randf()
	if random_var <= waves[_current_wave].probability_normal_zombie:
		zombie = zombie_normal_scene.instantiate()		
	elif random_var <= waves[_current_wave].probability_normal_zombie + waves[_current_wave].probability_fast_zombie:
		zombie = zombie_fast_scene.instantiate()
	elif random_var <= waves[_current_wave].probability_normal_zombie + waves[_current_wave].probability_fast_zombie + waves[_current_wave].probability_lightheaded_zombie:
		zombie = zombie_lightheaded_scene.instantiate()
		zombie.spawn_head.connect(spawn_zombie_head)
	else:
		print("Error spawning zombie")
			
	var tf = GameManager.world.get_random_enemy_spawn(active_player.global_position, 3.0)
	print("spawn zombie at " + str(tf))
	zombie.global_transform = tf
	zombie.target = player_fps
	zombie.died.connect(func(): _on_zombie_died(zombie))
	zombie.randomization()
	GameManager.world.add_child(zombie)
	_enemy_counter_mutex.lock()
	_active_enemies += 1
	_enemy_counter_mutex.unlock()
	update_wave_info()

func start_plane_world():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Add World
	var plane_world = preload("res://scenes/worlds/plane_world.tscn").instantiate()
	world.add_child(plane_world)
	
	# Add Player
	player_flying = preload("res://scenes/player_control/player_control_flying.tscn").instantiate()
	world.add_child(player_flying)
	player_flying.global_position.x = -2
	player_flying.global_position.y = 1
	player_flying.set_active(false)

	player_fps = preload("res://scenes/player_control/player_control_fps.tscn").instantiate()
	world.add_child(player_fps)
	player_fps.global_position.y = 0
	player_fps.global_position.x = 0	
	player_fps.set_active()	
	active_player = player_fps
	
	load_hud()
	
	var weapons = get_tree().get_nodes_in_group("weapon")
	for w in weapons:
		w.spread_updated.connect(GameManager.hud.crosshair.setSpread)

func change_camera():
	active_player.set_active(false)
	if active_player == player_fps:
		active_player = player_flying
	else:
		active_player = player_fps
	active_player.set_active()

func quit_game():
	get_tree().quit()
	
func _on_player_died():
	GameManager.hud.notification.notify("YOU ARE DEAD")
	active_player.set_active(false)
	Engine.time_scale = 0.2
	await get_tree().create_timer(1).timeout
	Engine.time_scale = 0
	
func _on_zombie_died(char:Node):
	
	_enemy_counter_mutex.lock()
	_enemies_killed_in_wave += 1
	_active_enemies -= 1
	_enemy_counter_mutex.unlock()
	update_wave_info()
	GameManager.hud.push_notification.print("Enemies left: " + str(waves[_current_wave].total_number_of_zombies - _enemies_killed_in_wave) )
	process_wave()
	await get_tree().create_timer(1).timeout
	char.queue_free()

func update_wave_info():
	if(GameManager.hud.wave_counter):
		var remaining = waves[_current_wave].total_number_of_zombies - _enemies_killed_in_wave - _active_enemies
		GameManager.hud.wave_counter.display_wave_info(_current_wave + 1, _active_enemies, remaining)
