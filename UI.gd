extends CanvasLayer

@onready var health_bar = $PanelContainer/VBoxContainer/HealthBar
@onready var ammu_counter = $PanelContainer/VBoxContainer/Ammunition
@onready var notification_label = $NotificationLabel/Label
@onready var notification_label_animation = $NotificationLabel/Label/AnimationPlayer
@onready var wave_stats = $WaveStats
var _player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	notification_label.hide()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _player:
		health_bar.value = _player.health / _player.health_max * 100
		display_ammunition()
		
	else:
		print("UI: Player not set")

func display_ammunition():
	ammu_counter.text = str(_player.get_ammu_gun()) + " / " + str(_player._ammu_reserve)

func set_player(player):
	_player = player
	
func player_notification(s:String, quick_fade=false):
	notification_label.visible = true
	notification_label.text = s
	if quick_fade:
		notification_label_animation.play("quick_fade")
	else:
		notification_label_animation.play("fade_notification")

func display_wave_stats(zombies_left, zombies_alive):
	wave_stats.text = str("Zombies left: " + str(zombies_left)  + " (" + str(zombies_alive) + ")")
