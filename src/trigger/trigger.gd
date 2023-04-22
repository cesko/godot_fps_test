extends Node3D

class_name Trigger

@export var enabled=true
@export var events:Array[TriggerEvent]
@export var single_event:bool = true
@export var event_delay_sec:float = 1.0
@export var remove_on_trigger:bool = false

var area:Area3D

func _ready():
	area = find_child("Area3D")
	
	if area:
		area.body_entered.connect(triggered)

func contineous_trigger(body:Node3D):
	if body in area.get_overlapping_bodies():
		triggered(body)
	

func triggered(body:Node3D):
	if enabled == false:
		return
		
	print("Triggered!")
	var events_handled = false
	if body.has_method("handle_event"):
		for e in events:
			if body.handle_event(e):
				events_handled = true
	
	if events_handled and single_event and remove_on_trigger:
		queue_free()
		
	if not single_event:
		if events_handled:
			get_tree().create_timer(event_delay_sec).timeout.connect(func(): contineous_trigger(body))

