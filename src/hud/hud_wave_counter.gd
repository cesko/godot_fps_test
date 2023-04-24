extends Control

@onready var label = $MarginContainer/Label

func display_wave_info(wave_nr:int, active_zombies:int, remaining_zombies:int):
	label.text = "Wave " + str(wave_nr) + "\nZombies: " + str(active_zombies) + " (" + str(remaining_zombies) + ")"
