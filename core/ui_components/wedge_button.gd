extends Control
class_name WedgeButton

# shape arguments
var point_count: int
var radius: float
var width: float
var origin: Vector2
var start_angle: float
var end_angle: float
var gap_width: float

# style arguments
var text: String
var color: Color
var hover_color: Color
var active_color: Color
var font
var font_size: int = 16
var current_color: Color = color

#outline arguments
var outline_width: float
var outline_color: Color

var polygon: PackedVector2Array
var index: int
var is_pressed: bool = false

signal hovered(index: int)
signal pressed(index: int)

func _init(
   p_index: int, p_origin: Vector2, p_radius: float, p_width: float, p_start: float, p_end: float,
   p_gap_width: float, p_text: String, p_font, p_font_size,
   colors: Array[Color], p_count: int = 64, p_outline_width: float = 0.0
) -> void:
   print("new button made")
   index = p_index
   origin = p_origin
   radius = p_radius
   width = p_width
   start_angle = p_start
   end_angle = p_end
   gap_width = p_gap_width
   
   text = p_text
   font = p_font
   font_size = p_font_size
   color = colors[0]
   hover_color = colors[1]
   active_color = colors[2]
   outline_color = colors[3]
   
   point_count = p_count
   outline_width = p_outline_width
   current_color = color
   
   mouse_filter = Control.MOUSE_FILTER_IGNORE

func update(
   p_index: int, p_origin: Vector2, p_radius: float, p_width: float, p_start: float, p_end: float,
   p_gap_width: float, p_text: String, p_font, p_font_size,
   colors: Array[Color], p_count: int = 64, p_outline_width: float = 0.0
) -> void:     ## Used to modify an existing button without needing to recreate the button.
   index = p_index
   origin = p_origin
   radius = p_radius
   width = p_width
   start_angle = p_start
   end_angle = p_end
   gap_width = p_gap_width
   
   text = p_text
   font = p_font
   font_size = p_font_size
   color = colors[0]
   hover_color = colors[1]
   active_color = colors[2]
   outline_color = colors[3]
   
   point_count = p_count
   outline_width = p_outline_width
   current_color = color

func handle_event(event: InputEvent) -> void:      ## Determines the color the button should have based on the event
   if event is InputEventMouseMotion:
      current_color = hover_color
      emit_signal("hovered", index)
      queue_redraw()
   if event is InputEventMouseButton:
      is_pressed = !is_pressed
      if is_pressed:
         current_color = active_color
         emit_signal("pressed", index)
      queue_redraw()

func clear_hover():     ## Changes the buttons color back to the default and calls for a redraw.
   current_color = color
   queue_redraw()

func _draw() -> void:
   var base_color = outline_color if outline_width != 0.0 else current_color
   polygon = _draw_arc_poly(point_count, origin, radius, radius + width, start_angle, end_angle, gap_width, base_color)
   if outline_width != 0.0:
      var inset = Geometry2D.offset_polygon(polygon, -outline_width)
      if inset.is_empty() or Geometry2D.triangulate_polygon(inset[0]).is_empty(): return
      draw_polygon(inset[0], PackedColorArray([current_color]))
   
   var text_pos: Vector2 = _get_center(radius, width, start_angle, end_angle)
   var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
   var text_ascent = font.get_ascent(font_size)
   var centered_pos: Vector2 = Vector2(text_pos.x - (text_size.x / 2.0), text_pos.y + (text_ascent / 2.0))
   draw_string(font, centered_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)

func _draw_arc_poly(count: int, center: Vector2, r: float, w: float, boundary_start: float, boundary_end: float, gap: float, c: Color) -> PackedVector2Array:
   var half_gap = gap / 2.0
   var inner_offset = asin(clamp(half_gap / r, -1.0, 1.0)) if r > 0.0 else 0.0
   var outer_offset = asin(clamp(half_gap / w, -1.0, 1.0))
   
   var inner_start = boundary_start + inner_offset
   var inner_end = boundary_end - inner_offset
   var outer_start = boundary_start + outer_offset
   var outer_end = boundary_end - outer_offset
   
   var outer_points: PackedVector2Array = PackedVector2Array()
   var inner_points: PackedVector2Array = PackedVector2Array()
   
   for i in range(count + 1):
      var t = float(i) / count
      var outer_angle = lerp(outer_start, outer_end, t) - PI / 2
      var inner_angle = lerp(inner_start, inner_end, t) - PI / 2
      outer_points.push_back(center + Vector2(cos(outer_angle), sin(outer_angle)) * w)
      inner_points.push_back(center + Vector2(cos(inner_angle), sin(inner_angle)) * r)
      
   var points = outer_points
   inner_points.reverse()
   points.append_array(inner_points)
   if points.is_empty() or Geometry2D.triangulate_polygon(points).is_empty(): return PackedVector2Array()
   draw_polygon(points, PackedColorArray([c]))
   return points

func _get_center(r: float, w: float, angle_from: float, angle_to: float) -> Vector2:
   var mid_angle = (angle_from + angle_to) / 2.0 - PI / 2.0
   var mid_radius = r + w / 2.0
   return origin + Vector2(cos(mid_angle), sin(mid_angle)) * mid_radius
