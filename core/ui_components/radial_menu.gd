@tool
extends Control
class_name RadialMenu

var show_menu: bool = false

@export_group("Values")
@export var origin: Vector2 = Vector2.ZERO:     ## The center of the RadialMenu.
   set(value): origin = value; _calc_geometry()
@export var center_radius: float:               ## The radius of the center circle.
   set(value): center_radius = value; _calc_geometry()
@export var center_gap: float:                  ## The gap between the center circle and buttons.
   set(value): center_gap = value; _calc_geometry()
@export var arc_width: float = 75.0:            ## The width of each button.
   set(value): arc_width = value; _calc_geometry()
@export var outline_width: float = 0.0:         ## The width of the RadialMenu and button outlines.
   set(value): outline_width = value; _calc_geometry()

var bounding_rect: Rect2
var radius: float
var corrected_origin: Vector2

## The total rotation to be divided between buttons.
@export_custom(PROPERTY_HINT_RANGE, "0,360,0.1,radians_as_degrees") var max_rotation: float = 2 * PI:
   set(value): max_rotation = value; _update_buttons()
## The gap between each button.
@export var gap_width: float = 0.0:
   set(value): gap_width = value; _update_buttons()
## The rotation of the first button.
@export_custom(PROPERTY_HINT_RANGE, "-360,360,0.1,radians_as_degrees") var start_angle: float:
   set(value): start_angle = value; _update_buttons()

@export_group("Style")
@export var color: Color:              ## The color used for the menu and buttons.
   set(value): color = value; colors = [color, hover_color, active_color, outline_color]; queue_redraw()
@export var hover_color: Color:        ## The color used for the menu and buttons when the mouse is over them.
   set(value): hover_color = value; colors = [color, hover_color, active_color, outline_color]; queue_redraw()
@export var active_color: Color:       ## The color used for the menu and buttons when the mouse clicks on them.
   set(value): active_color = value; colors = [color, hover_color, active_color, outline_color]; queue_redraw()
@export var outline_color: Color:      ## The color used for the menu and button outline.
   set(value): outline_color = value; colors = [color, hover_color, active_color, outline_color]; queue_redraw()
var colors: Array[Color] = [color, hover_color, active_color, outline_color]

@export_group("Buttons")
#@export var hold_open: bool = true
@export var font: Font:                ## The font used by the buttons.
   set(value): font = value; _update_buttons()
@export var font_size: int = 16:       ## The font size of the buttons.
   set(value): font_size = value; _update_buttons()
@export var buttons: Array[String] = ["Button1", "Button2", "Button3", "Button4", "Button5"]:
   set(value): buttons = value; _update_buttons()

@export_group("Animation")
@export var animated: bool = false              ## If [code]true[/code] the menu will open using tweens
@export var animate_max_rotation: bool = false  ## If [code]true[/code] wedge buttons will start at zero width.

var open_tween: Tween
var close_tween: Tween

var open_final_center: float
var open_final_arc: float
var open_final_max: float
var close_center: float
var close_arc: float

var button_nodes: Array[WedgeButton] = []

signal radial_opened
signal radial_opening
signal radial_closed
signal radial_closing
signal radial_pressed
signal radial_hovered

signal button_pressed(index: int)
signal button_hovered(index: int)


func open_menu_at(pos: Vector2):    ## Opens the RadialMenu with [param pos] as its [param origin].
   emit_signal("radial_opening")
   show()
   origin = pos
   if animated:
      if open_tween:
         center_radius = open_final_center if open_final_center else center_radius
         arc_width = open_final_arc if open_final_arc else arc_width
         max_rotation = open_final_max if open_final_max else max_rotation
         open_tween.kill()
      if close_tween: close_tween.kill()
      open_tween = create_tween()
      open_final_center = center_radius
      open_final_arc = arc_width
      center_radius = 0
      arc_width = 0
      open_tween.tween_property(self, "center_radius", open_final_center, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
      open_tween.tween_property(self, "arc_width", open_final_arc, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
      if animate_max_rotation:
         open_final_max = max_rotation
         max_rotation = 0
         open_tween.parallel().tween_property(self, "max_rotation", open_final_max, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
      await open_tween.finished
   else:
      queue_redraw()
   emit_signal("radial_opened")

func close_menu():                  ## Hides the menu.
   emit_signal("radial_closing")
   if animated:
      if open_tween: open_tween.kill()
      if close_tween:
         center_radius = close_center if close_center else center_radius
         arc_width = close_arc if close_arc else arc_width
         close_tween.kill()
      close_tween = create_tween()
      close_center = center_radius
      close_arc = arc_width
      close_tween.tween_property(self, "center_radius", 0, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
      close_tween.tween_property(self, "arc_width", 0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
      await close_tween.finished
      center_radius = close_center
      arc_width = close_arc
   hide()
   emit_signal("radial_closed")

func _calc_geometry() -> void:
   radius = arc_width + center_radius + center_gap
   bounding_rect = Rect2(Vector2(origin.x - radius, origin.y - radius), Vector2(2 * radius, 2 * radius))
   position = bounding_rect.position
   size = bounding_rect.size
   corrected_origin = origin - position
   for b in button_nodes:
      b.radius = center_radius + center_gap
      b.width = arc_width
      b.origin = corrected_origin
   queue_redraw()

func _update_buttons() -> void:
   if font == null:
      push_warning("Provide a font before using the RadialMenu")
      return
   
   if button_nodes.size() != buttons.size():
      _build_buttons()
      return
   
   var pie_slice = max_rotation / buttons.size()
   var rot = start_angle
   
   for i in button_nodes.size():
      var start = rot
      rot += pie_slice
      var end = rot
      button_nodes[i].update(
         i, corrected_origin, center_radius + center_gap, arc_width, start, end,
         gap_width, buttons[i], font, font_size, colors, 64, outline_width
      )
   queue_redraw()

func _build_buttons() -> void:
   for b in button_nodes: b.free()
   button_nodes = []
      
   var pie_slice = max_rotation / buttons.size()
   var rot = start_angle
   for i in buttons.size():
      var start = rot
      rot += pie_slice
      var end = rot
      var wedge_button = WedgeButton.new(
         i, corrected_origin, center_radius + center_gap, arc_width, start, end,
         gap_width, buttons[i], font, font_size, colors, 64, outline_width
      )
      
      wedge_button.hovered.connect(_button_hovered)
      wedge_button.pressed.connect(_button_pressed)
      
      add_child(wedge_button)
      button_nodes.append(wedge_button)

func _ready() -> void:
   if !Engine.is_editor_hint():
      if not mouse_exited.is_connected(_clear_menu): mouse_exited.connect(_clear_menu)
   
   if button_nodes.is_empty(): _build_buttons()
   queue_redraw()

func _draw() -> void:
   if outline_width != 0.0: draw_circle(corrected_origin, center_radius + outline_width, outline_color)
   draw_circle(corrected_origin, center_radius, color)
   for b in button_nodes: b.queue_redraw()

func _gui_input(event: InputEvent) -> void:
   if !Geometry2D.is_point_in_circle(event.position, corrected_origin, radius):
      for button in button_nodes: button.clear_hover()
      queue_redraw()
      return
   for button in button_nodes:
      if Geometry2D.is_point_in_polygon(event.position, button.polygon):
         button.handle_event(event)
      else: button.clear_hover()
   queue_redraw()

func _button_hovered(index: int): emit_signal("button_hovered", index)
func _button_pressed(index: int): emit_signal("button_pressed", index)
func _clear_menu(): for button in button_nodes: button.clear_hover()
