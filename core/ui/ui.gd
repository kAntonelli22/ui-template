class_name UI
extends CanvasLayer

@onready var debug_panel: Panel = $Control/Debug
@onready var debug_label: Label = $Control/Debug/Label
var panels: Dictionary[String, Panel]
var menu_tabs: Dictionary[String, Control]

var buttons: Dictionary[String, Button]

# settings variables
var settings: Dictionary[String, Variant] = {
   "debug_mode": false,
   "fast_menu": false
}

func add_button(button: Button):
   buttons.set(button.name, button)

func _ready() -> void:
   debug(["game paused: ", get_tree().paused])
   if !settings.debug_mode: debug_panel.hide()
   for button in $Control/MenuSlider/Menu/MarginContainer/MainMenu/VBoxContainer.get_children().slice(1): add_button(button)

func debug(array: Array):
   debug_label.text = ""
   for item in array:
      debug_label.text += str(item)

func reset():  #TODO reset the ui
   pass

func load_menu_state():    #TODO load a menu combo
   pass

func pause_game():      #FIXME uses old panel system
   if panels.Menu.visible and get_tree().paused == false:
      debug(["game paused: ", !get_tree().paused])
      Util.print(["menu onscreen, double slide and pause"])
      get_tree().paused = true
      #await slide_panel(panels.Menu, false, true)
      #change_tab(menu_tabs.PauseMenu)
      #await slide_panel(panels.Menu, true, true)
   elif !panels.Menu.visible and get_tree().paused == false:
      debug(["game paused: ", !get_tree().paused])
      Util.print(["menu offscreen, single slide and pause"])
      get_tree().paused = true
      #change_tab(menu_tabs.PauseMenu)
      #await slide_panel(panels.Menu, true, true)
   elif panels.Menu.visible and get_tree().paused == true:
      debug(["game paused: ", !get_tree().paused])
      Util.print(["menu onscreen, single slide and pause"])
      get_tree().paused = false
      #await slide_panel(panels.Menu, false, true)

func _unhandled_input(_event: InputEvent) -> void:
   if Input.is_action_just_pressed("pause"):
      Util.print(["esc pressed"])
      pause_game()

func _on_play_pressed() -> void:
   $Control/MenuSlider.move_to_next_point()
   SignalBus.emit_signal("start")

func _on_settings_pressed() -> void:
   var success: bool = await $Control/SettingsSlider.move_to_next_point()
   if !success: buttons.Settings.button_pressed = !buttons.Settings.button_pressed
   #if !panels.Settings.visible: await slide_panel(panels.Settings, false, true)
   #else: await slide_panel(panels.Settings, true, true)

func _on_menu_pressed() -> void:
   get_tree().paused = false     # FIXME old
   #change_tab(menu_tabs.MainMenu)

func _on_quit_pressed() -> void:
   SignalBus.emit_signal("quit")

# ---- # Settings
func _on_fast_menu_toggled(toggled_on: bool) -> void:
   settings.fast_menu = toggled_on  #FIXME does not change UI Sliders

func _on_debug_mode_toggled(toggled_on: bool) -> void:
   settings.debug_mode = toggled_on
   debug_panel.visible = toggled_on
