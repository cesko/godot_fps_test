extends Node

class_name HudManager

var health_display
var weapon_info
var crosshair
var notification
var push_notification

func update_health(health:float, max:float):
	if health_display:
		var health_percent = 100 * health/max
		health_display.update_health_percent(health_percent)
	
func update_ammunition(magazin:int, reserve:int):
	if weapon_info:
		weapon_info.update_ammunition(magazin, reserve)
