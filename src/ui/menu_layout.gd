extends Control

@onready var logo_panel = $HBoxContainer/MenuPanel/MarginContainer/VBoxContainer/Logo
@onready var content_panel = $HBoxContainer/MenuPanel/MarginContainer/VBoxContainer/MainContent
@onready var version_label = $VersionLabel

@export var logo_texture:Texture:
	set(new_logo):
		logo_texture = new_logo
		logo_panel.texture = logo_texture

@export var version_info:String:
	set(new_version_info):
		version_info = new_version_info
		version_label.set_text(version_info)
		
var content 

func setContent(new_content:Control):
	if content:
		content.queue_free()
	content = new_content
	if content_panel:
		content_panel.add_child(content)
