class_name ToggleText
extends Button

@onready var panel_container: HBoxContainer = $PanelContainer

@export var options: Array[String] = ["text"]
@export var current_option: int = 0
@export var text_color: Color

var panels: Array = []
var square_panels: bool = true

func _ready() -> void:
   $".".add_theme_color_override("font_color", text_color)
   $".".add_theme_color_override("font_hover_color", text_color)
   $".".add_theme_color_override("font_pressed_color", text_color)
   $".".add_theme_color_override("font_hover_pressed_color", text_color)
   $".".add_theme_color_override("font_focus_color", text_color)
   current_option = clampi(current_option, 0, options.size()-1)
   _update_button()
   _create_panels()

func _update_button():
   text = options[current_option]

func _get_current_option() -> String:
   return options[current_option]

func _create_panels():
   var stylebox: StyleBoxFlat = StyleBoxFlat.new()
   stylebox.bg_color = text_color
   stylebox.anti_aliasing = false
   if square_panels: stylebox.set_corner_radius_all(5)
   
   for option in options:
      var panel: Panel = Panel.new()
      panel.add_theme_stylebox_override("normal", stylebox)
      panel.custom_minimum_size = Vector2(5, 5)
      panel_container.add_child(panel)
      

func _on_pressed() -> void:
   if current_option+1 < options.size(): current_option += 1
   else: current_option = 0
   _update_button()
