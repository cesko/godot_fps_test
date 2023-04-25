class_name HudInventorySlot extends PanelContainer

var selected = false
var icon:Texture
var text:String = ""

@onready var texture_rect = $TextureRect
@onready var label = $Label

func _ready():
	label.text = text
	texture_rect.texture = icon
	set_selected(selected)
	

func set_selected(_selected:bool = true):
	selected = _selected
	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(5)
	
	if _selected:
		stylebox.border_color = Color(0.18814972043037, 0.1706395149231, 0.14148688316345)
	else:
		stylebox.border_color = Color(0, 0, 0, 0)

	add_theme_stylebox_override("panel", stylebox)
