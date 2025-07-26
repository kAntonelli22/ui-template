extends Node
#FIXME debug for template project

@onready var ui: UI = get_parent()


func _on_button_pressed() -> void:
   ui.slide_panel(ui.panels.Menu, true, true)
