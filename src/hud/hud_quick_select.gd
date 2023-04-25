extends Control

@export var slot_scene := preload("res://scenes/hud/hud_inventory_slot.tscn")

@onready var hud_slots = $MarginContainer/Slots

var slots : Dictionary = {} # int:InventoryElement
var tween

func update(iqs:InventoryQuickSlots):
	for old_slot in hud_slots.get_children():
		hud_slots.remove_child(old_slot)
	
	for i in range(iqs.quick_slots.size()):
		var slot:InventoryElement = iqs.quick_slots[i]
		if slot:
			var new_slot:HudInventorySlot = slot_scene.instantiate()
			new_slot.text = slot.text
			new_slot.icon = slot.icon
			hud_slots.add_child(new_slot)
			slots[i] = new_slot
			
	set_selected(iqs.current_index)
	show_for_duration(1.0)

func show_for_duration(d:float):
		if tween:
			tween.kill()
		self.show()
		visible = true
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		tween = get_tree().create_tween()
		tween.tween_interval(d)
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), .25)
		tween.tween_callback(self.hide)

func set_selected(index:int):
	for i in slots:
		if slots[i]:
			if i == index:
				slots[i].set_selected(true)
			else:
				slots[i].set_selected(false)
