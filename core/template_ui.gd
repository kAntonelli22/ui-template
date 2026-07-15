class_name TemplateUI
extends CanvasLayer

@onready var debug_panel: Panel = $Control/Debug
@onready var debug_label: Label = $Control/Debug/Label

@onready var ui_sliders: Dictionary[String, UISlider] = {
   "menu": $Control/MenuSlider,
   "settings": $Control/SettingsSlider
}
@onready var main_menu: Control = $Control/MenuSlider/Menu/MarginContainer/MainMenu
@onready var pause_menu: Control = $Control/MenuSlider/Menu/MarginContainer/PauseMenu

var buttons: Dictionary[String, Button]

# settings variables
var settings: Dictionary[String, Variant] = {
   "debug_mode": false,
   "fast_menu": false
}

func _ready() -> void:
   debug(["game paused: ", get_tree().paused])
   if !settings.debug_mode: debug_panel.hide()
   for button in $Control/MenuSlider/Menu/MarginContainer/MainMenu/VBoxContainer.get_children().slice(1): add_button(button)

func debug(array: Array):
   debug_label.text = ""
   for item in array:
      debug_label.text += str(item)

func add_button(button: Button):
   buttons.set(button.name, button)

func pause_game():
   if $Control/MenuSlider.current_point == 1:
      main_menu.hide()
      pause_menu.show()
      ui_sliders.menu.move_to_next_point()
      get_tree().paused = true

func _unhandled_input(_event: InputEvent) -> void:
   if Input.is_action_just_pressed("pause"):
      pause_game()

func _on_play_pressed() -> void:
   ui_sliders.menu.move_to_next_point()

func _on_settings_pressed() -> void:
   var success: bool = await ui_sliders.settings.move_to_next_point()
   if !success: buttons.Settings.button_pressed = !buttons.Settings.button_pressed

func _on_menu_pressed() -> void:
   #get_tree().paused = false
   await ui_sliders.menu.move_to_next_point()
   pause_menu.hide()
   main_menu.show()

func _on_quit_pressed() -> void:
   get_tree().quit()

# ---- # Settings
func _on_fast_menu_toggled(toggled_on: bool) -> void:
   settings.fast_menu = toggled_on
   for ui_slider in ui_sliders.keys():
      ui_sliders[ui_slider].instant = toggled_on

func _on_debug_mode_toggled(toggled_on: bool) -> void:
   settings.debug_mode = toggled_on
   debug_panel.visible = toggled_on
