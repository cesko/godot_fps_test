extends Control

signal start_game(GameMode)
signal continue_game
signal exit_game
signal quit

@export var initial_panel:Control

@onready var panels = {"Main":$Main, "GameSelection":$GameSelection, "InGame": $InGame }

var _current_panel

func _ready():
	if initial_panel:
		_current_panel = initial_panel
	else:
		_current_panel = panels["Main"]
	
	hideAllPanels()
	_current_panel.show()

func hideAllPanels():
	for p in panels:
		panels[p].hide()

func switchToPanel(panel:Control):
	_current_panel.hide()
	_current_panel = panel
	_current_panel.show()

# External Button Pushes
func _on_main_btn_quit_button_up():
	quit.emit()

func _on_game_selection_btn_testing_button_up():
	var gm = GameMode.new()
	gm.mode = GameMode.Mode.TEST
	print(gm.mode)
	start_game.emit(gm)

func _on_game_selection_btn_zombie_survival_button_up():
	var gm = GameMode.new()
	gm.mode = GameMode.Mode.ZOMBIES
	print("sirvival: " + str(gm.mode))
	start_game.emit(gm)

func _on_ingame_btn_continue_button_up():
	continue_game.emit()

func _on_ingame_btn_quit_button_up():
	quit.emit()

func _on_ingame_btn_exit_game_button_up():
	exit_game.emit()



# Internal Button Pushes
func _on_main_btn_start_button_up():
	switchToPanel(panels["GameSelection"])
	
func _on_game_selection_btn_back_button_up():
	switchToPanel(panels["Main"])
	pass

