class_name InventoryQuickSlots extends RefCounted

var number_of_slots = 6
var quick_slots: Array[InventoryElement] = []
var current_index = 0

func _init():
	for i in range(number_of_slots):
		quick_slots.append( null )

func empty():
	for i in range(number_of_slots):
		quick_slots[i] = ( null )

func add_element (element:InventoryElement, index:int=-1) -> int:
	print("Add Quick Slot Element " +  element.text)
	if index < 0:		
		for i in range(quick_slots.size()):
			if quick_slots[i] == null:
				quick_slots[i] = element
				return i
		print("no empty slot")
		return -1 # no space in quickslots
	
	if index >= quick_slots.size():
		return -2 # invalid place
	
	quick_slots[index] = element
	return index

func get_slot(index:int) -> InventoryElement:
	if index < 0 or index >=quick_slots.size():
		return null
	else:
		if quick_slots[index]:
			current_index = index
		return quick_slots[index]

func get_next_slot() -> InventoryElement:
	for i in range(quick_slots.size()):
		current_index = wrap_index(current_index + 1)
		if quick_slots[current_index]:
			return quick_slots[current_index]
	
	return null

func get_previous_slot() -> InventoryElement:
	for i in range(quick_slots.size()):
		current_index = wrap_index(current_index - 1)
		if quick_slots[current_index]:
			return quick_slots[current_index]

	return null

func wrap_index(index:int) -> int:
	if index >= quick_slots.size():
		return index % quick_slots.size()
	
	if index < 0:
		return wrap_index(index + quick_slots.size()) 
	
	return index

	
