extends Node

var hud = HudManager.new()
var player:Node
var world:Node
var menu:Node

enum GameStatus {NONE, RUNNING, PAUSED}
var game_status:GameStatus = GameStatus.NONE

func toggle_pause():
	if game_status == GameStatus.RUNNING:
		print("Set paused")
		pause_game()
	elif game_status == GameStatus.PAUSED:
		print("Set running")
		resume_game()
	else:
		print("What am I doing?")

func pause_game():
	if game_status == GameStatus.NONE:
		return
	game_status = GameStatus.PAUSED
	get_tree().paused = true
	menu.content.showInGameMenu()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	menu.show()
	pass
	
func resume_game():
	if game_status == GameStatus.NONE:
		return
	game_status = GameStatus.RUNNING
	get_tree().paused = false
	menu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass


