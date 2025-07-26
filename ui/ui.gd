class_name UI
extends CanvasLayer

@onready var panel_container: Control = $Control
@onready var debug_panel: Panel = $Control/Debug
@onready var debug_label: Label = $Control/Debug/Label
@onready var current_menu_tab: Control
var panels: Dictionary[String, Panel]
var menu_tabs: Dictionary[String, Control]
var active_tweens: Dictionary[Panel, Tween]

# settings variables    #HACK temp name   #TODO add type to dictionary after update to 4.4
var settings_dict: Dictionary = {
   "debug_mode": false,
   "fast_menu": false
}

func _ready() -> void:
   if !settings_dict.debug_mode: debug_panel.hide()
   
   for panel in panel_container.get_children(): panels[panel.name] = panel
   for node in panels.Menu.get_node("MarginContainer").get_children(): menu_tabs[node.name] = node
   current_menu_tab = menu_tabs.MainMenu

func debug(array: Array):
   if !settings_dict.debug_mode: return
   debug_label.text = ""
   for item in array:
      debug_label.text += str(item)

# reverse - true: panel is slid right or down
func slide_panel(panel: Panel, reverse: bool, horizontal: bool):
   if active_tweens.has(panel): return
   var target: Vector2 = panel.position
   if !reverse and horizontal: target.x -= panel.size.x
   elif reverse and horizontal: target.x += panel.size.x
   elif !reverse and !horizontal: target.y -= panel.size.y
   elif reverse and !horizontal: target.y += panel.size.y
   
   # visibility check code
   var panel_rect: Rect2 = panels[panel.name].get_rect()
   var next_panel_rect: Rect2 = panel_rect
   next_panel_rect.position = target
   var viewport_rect: Rect2 = get_viewport().get_visible_rect()
   var is_onscreen: bool = viewport_rect.intersects(panel_rect)
   var will_be_onscreen: bool = viewport_rect.intersects(next_panel_rect)
   #Util.print(["is onscreen? ", is_onscreen, "  will be onscreen? ", will_be_onscreen])
   var moving_onscreen: bool = !is_onscreen and will_be_onscreen
   var moving_offscreen: bool = is_onscreen and !will_be_onscreen
   #Util.print(["moving onscreen? ", moving_onscreen, "   moving offscreen? ", moving_offscreen])
   
   if !settings_dict.fast_menu:
      if moving_onscreen: panel.show()
      var tween = get_tree().create_tween()
      active_tweens[panel] = tween
      tween.tween_property(panel, "position", target, 0.5).set_trans(Tween.TRANS_CIRC)
      await tween.finished
      active_tweens.erase(panel)
      if moving_offscreen: panel.hide()
   else:
      if moving_onscreen: panel.show()
      elif moving_offscreen: panel.hide()
      panel.position = target

func change_tab(new_tab):
   Util.print(["changing tab"])
   current_menu_tab.hide()
   current_menu_tab = new_tab
   current_menu_tab.show()

func _unhandled_input(_event: InputEvent) -> void:
   if Input.is_action_just_pressed("pause") and !panels.Menu.visible: #FIXME pause menu slides when menu is already out
      if panels.Menu.visible and current_menu_tab == menu_tabs.PauseMenu:
         await slide_panel(panels.Menu, false, true)
         get_tree().paused = true
      else:
         change_tab(menu_tabs.PauseMenu)
         await slide_panel(panels.Menu, true, true)
         get_tree().paused = true

func _on_play_pressed() -> void:
   if panels.Menu.visible:     #FIXME no longer works in pause
      await slide_panel(panels.Menu, false, true)
      SignalBus.emit_signal("start")

func _on_settings_pressed() -> void:
   if !panels.Settings.visible: await slide_panel(panels.Settings, false, true)     #FIXME no longer works in pause
   else: await slide_panel(panels.Settings, true, true)

func _on_menu_pressed() -> void:
   await slide_panel(panels.Menu, false, true)      #FIXME no longer works in pause
   change_tab(menu_tabs.MainMenu)
   await slide_panel(panels.Menu, false, true)

func _on_quit_pressed() -> void:
   SignalBus.emit_signal("quit")    #FIXME no longer works in pause

# ---- # Settings
func _on_fast_menu_toggled(toggled_on: bool) -> void:
   settings_dict.fast_menu = toggled_on

func _on_debug_mode_toggled(toggled_on: bool) -> void:
   settings_dict.debug_mode = toggled_on
   debug_panel.visible = toggled_on
