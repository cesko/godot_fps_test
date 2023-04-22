extends Control

@onready var health_bar = $MarginContainer/HealthBar

func _ready():
	# TODO get health from active player
	update_health_percent(100)

func update_health_percent(health_percent):
	health_bar.value = health_percent
	
