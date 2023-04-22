extends Control

class_name Notification

@export var label:Label
@export var default_notification_options:NotificationOptions

var tween:Tween

func _ready():
	label.visible = false
	label.text = ""

func notify(text:String, options:NotificationOptions=null):
	if not options:
		options = default_notification_options
	
	if tween:
		tween.kill()
		
	label.text = text
	label.visible = true
	label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	if options.lifespan >= 0.0:
		var show_time = options.lifespan - options.out_duration
		tween = get_tree().create_tween()
		tween.tween_interval(show_time)
		match options.out_anim:
			NotificationOptions.AnimOptions.FADE:
				tween.tween_property(label, "modulate", Color(1.0, 1.0, 1.0, 0.0), options.out_duration)
	
		tween.tween_callback(hide_label)

func multiple_notifications(texts:PackedStringArray, steptime=1.0):
	var options = NotificationOptions.new()
	options.lifespan = steptime
	options.out_duration = 0.5
	options.out_anim = NotificationOptions.AnimOptions.FADE
	for t in texts:
		notify(t, options)
		await get_tree().create_timer(steptime).timeout

func countdown(duration:int = 3):
	var texts = []
	for i in range(duration):
		texts.append(str(duration - i))
	
	multiple_notifications(texts, 1.0)
	

func hide_label():
	label.visible = false
