@tool
extends Control
class_name UISlider

@export var node: Control :   ## The affected ui node
   set(value):
      node = value
      calc_node_pivots()
      queue_redraw()

@export_group("Settings")
@export var instant: bool = false   ## If true the UI will slide immediately, if false it will use a tween instead.
@export var lock_during_transition: bool = true
enum Pivot {TOPLEFT, TOPCENTER, TOPRIGHT, CENTERLEFT, CENTER, CENTERRIGHT, BOTTOMLEFT, BOTTOMCENTER, BOTTOMRIGHT}
@export var node_pivot: Pivot = Pivot.TOPLEFT :    ## controls the pivot offset of the provided ui node
   set(value):
      node_pivot = value
      queue_redraw()

@export_group("Debug")
@export var debug: bool = true : ## controls panel outline
   set(value):
      debug = value
      if debug and line: line.show()
      elif line: line.hide()
      queue_redraw()
@export var debug_color: Color = Color.PURPLE :
   set(value):
      debug_color = value
      queue_redraw()

var pivots

@onready var line: Line2D = $Line2D

var current_point: int = 0             ## index of the current point on the Line2D
var current_position: Vector2          ## position of the current Line2D point
var in_transition: bool = false        ## true when a tween is affecting the slider

var old_points: PackedVector2Array     ## used to determine debug redraw

func _draw() -> void:
   if Engine.is_editor_hint() and debug:
      if line == null or node == null: return
      for point in line.get_point_count():
         var rect = Rect2(Vector2.ZERO + Vector2(0, 0), node.size - Vector2(0, 0))
         rect.position = line.get_point_position(point)
         rect.position -= pivots[node_pivot]
         draw_rect(rect, debug_color, false, 1)
         old_points = line.points

func _process(delta: float) -> void:
   if Engine.is_editor_hint() and debug and line != null:
      if line.points != old_points: queue_redraw()

func _ready() -> void:
   if node == null or !node.is_node_ready(): return            # ensure node is ready
   node.position = Vector2.ZERO                                # reset node position
   node.position -= pivots[node_pivot]                         # apply pivot to node
   current_position = line.get_point_position(current_point)   # get first point position
   position = current_position                                 # set slider position to first point

func calc_node_pivots():
   pivots = [
      Vector2.ZERO, Vector2(node.size.x / 2, 0), Vector2(node.size.x, 0), Vector2(0, node.size.y / 2), node.size / 2,
      Vector2(node.size.x, node.size.y / 2), Vector2(0, node.size.y), Vector2(node.size.x / 2, node.size.y), node.size
   ]

## Gets the next position for the slider to move. Moves instantly if [param instant] is [code]true[/code], uses a tween if [param instant] is [code]false[/code].
## returns [code]true[/code] if moving and [code]false[/code] if the slider was blocked from moving by its settings.
func move_to_next_point() -> bool:
   if lock_during_transition and in_transition: return false
   var next = current_point + 1                                                  # |
   if next >= line.get_point_count(): next = 0                                   # > get next point
   current_point = next                                                          # |
   current_position = line.get_point_position(current_point)
   if debug: print(self.name, " sliding ", node.name, " to ", current_position)
   
   if instant:
      node.position = current_position
   else:
      in_transition = true
      var tween = get_tree().create_tween()
      tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
      tween.tween_property(self, "position", current_position, 0.5).set_trans(Tween.TRANS_CIRC)
      await tween.finished
      in_transition = false
   return true
