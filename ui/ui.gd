class_name UI
extends CanvasLayer

@onready var panel_container: Control = $Control
@onready var debug_panel: Panel = $Control/Debug
@onready var debug_label: Label = $Control/Debug/Label
@onready var current_menu_tab: Control
var panels: Dictionary[String, Panel]
var menu_tabs: Dictionary[String, Control]
var active_tweens: Dictionary[Panel, Tween]

# settings variables
var settings: Dictionary[String, Variant] = {
   "debug_mode": false,
   "fast_menu": false
}

func _ready() -> void:
   debug(["game paused: ", get_tree().paused])
   if !settings.debug_mode: debug_panel.hide()
   
   for panel in panel_container.get_children(): panels[panel.name] = panel
   for node in panels.Menu.get_node("MarginContainer").get_children(): menu_tabs[node.name] = node
   current_menu_tab = menu_tabs.MainMenu

func debug(array: Array):
   debug_label.text = ""
   for item in array:
      debug_label.text += str(item)

# reverse - true: panel is slid right or down
func slide_panel(panel: Panel, reverse: bool, horizontal: bool):
   Util.print(["sliding panel"])
   if active_tweens.has(panel): return
   var target: Vector2 = panel.position
   if !reverse and horizontal: target.x -= panel.size.x
   elif reverse and horizontal: target.x += panel.size.x
   elif !reverse and !horizontal: target.y -= panel.size.y
   elif reverse and !horizontal: target.y += panel.size.y
   
   # visibility check code
   var panel_rect: Rect2 = panels[panel.name].get_rect()
   var next_panel_rect: Rect2 = Rect2(target, panel_rect.size)
   var viewport_rect: Rect2 = get_viewport().get_visible_rect()
   var is_onscreen: bool = viewport_rect.intersects(panel_rect)
   var will_be_onscreen: bool = viewport_rect.intersects(next_panel_rect)
   
   if !settings.fast_menu:
      Util.print(["tween started"])
      if !is_onscreen and will_be_onscreen: panel.show()
      var tween = get_tree().create_tween()
      tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
      active_tweens[panel] = tween
      tween.tween_property(panel, "position", target, 0.5).set_trans(Tween.TRANS_CIRC)
      await tween.finished
      active_tweens.erase(panel)
      Util.print(["tween finished"])
      if is_onscreen and !will_be_onscreen: panel.hide()
   else:
      if !is_onscreen and will_be_onscreen: panel.show()
      elif is_onscreen and !will_be_onscreen: panel.hide()
      panel.position = target

func change_tab(new_tab: Control):
   if current_menu_tab == new_tab: return
   if panels.Menu.visible: await slide_panel(panels.Menu, false, true)
   current_menu_tab.hide()
   current_menu_tab = new_tab
   current_menu_tab.show()
   await slide_panel(panels.Menu, true, true)

func reset():  #TODO reset the ui
   pass

func load_menu_state():    #TODO load a menu combo
   pass

func pause_game():
   if panels.Menu.visible and get_tree().paused == false:
      debug(["game paused: ", !get_tree().paused])
      Util.print(["menu onscreen, double slide and pause"])
      get_tree().paused = true
      #await slide_panel(panels.Menu, false, true)
      change_tab(menu_tabs.PauseMenu)
      #await slide_panel(panels.Menu, true, true)
   elif !panels.Menu.visible and get_tree().paused == false:
      debug(["game paused: ", !get_tree().paused])
      Util.print(["menu offscreen, single slide and pause"])
      get_tree().paused = true
      change_tab(menu_tabs.PauseMenu)
      #await slide_panel(panels.Menu, true, true)
   elif panels.Menu.visible and get_tree().paused == true:
      debug(["game paused: ", !get_tree().paused])
      Util.print(["menu onscreen, single slide and pause"])
      get_tree().paused = false
      await slide_panel(panels.Menu, false, true)

func _unhandled_input(_event: InputEvent) -> void:
   if Input.is_action_just_pressed("pause"):
      Util.print(["esc pressed"])
      pause_game()

func _on_play_pressed() -> void:
   if panels.Menu.visible:
      await slide_panel(panels.Menu, false, true)
      SignalBus.emit_signal("start")

func _on_settings_pressed() -> void:
   if !panels.Settings.visible: await slide_panel(panels.Settings, false, true)
   else: await slide_panel(panels.Settings, true, true)

func _on_menu_pressed() -> void:
   get_tree().paused = false
   change_tab(menu_tabs.MainMenu)

func _on_quit_pressed() -> void:
   SignalBus.emit_signal("quit")

# ---- # Settings
func _on_fast_menu_toggled(toggled_on: bool) -> void:
   settings.fast_menu = toggled_on

func _on_debug_mode_toggled(toggled_on: bool) -> void:
   settings.debug_mode = toggled_on
   debug_panel.visible = toggled_on
