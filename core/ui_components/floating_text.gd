extends RefCounted
class_name FloatingText
## Creates a label floating at the position given which disappears after the passed duration

## Creates a [Label] at [param position] and uses [param text] and [param settings] to configure the label,
## then applies a tween to the label moving upwards for [param duration].
static func create_2d(text: String, position: Vector2, duration: float = 0.5, settings: LabelSettings = LabelSettings.new(), offset: Vector2 = Vector2(0, 40)) -> void:
   var tree := Engine.get_main_loop() as SceneTree
   var label = Label.new()
   label.text = text
   label.z_index = 5
   label.label_settings = settings
   label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
   tree.root.call_deferred("add_child", label)
   
   await label.resized
   label.set_global_position(position - label.size/2)
   label.pivot_offset = label.size/2
   
   var tween: Tween = tree.create_tween()
   tween.set_parallel(true)
   tween.tween_property(label, "position", label.position - offset, duration).set_ease(Tween.EASE_IN)
   tween.tween_property(label, "modulate", Color.TRANSPARENT, duration*3/4).set_delay(duration/4).set_ease(Tween.EASE_IN)
   tween.tween_property(label, "scale", Vector2(0.5, 0.5), duration*3/4).set_delay(duration/4).set_ease(Tween.EASE_IN)
   
   await tween.finished
   label.queue_free()

## Creates a [Label3D] at [param position] and uses [param text] and [param settings] to configure the label,
## then applies a tween to the label moving upwards for [param duration].
static func create_3d(text: String, position: Vector3, duration: float = 0.5, settings: LabelSettings = LabelSettings.new(), offset: Vector3 = Vector3(0, 1, 0)) -> void:
   var tree := Engine.get_main_loop() as SceneTree
   var label = Label3D.new()
   label.text = text
   label.billboard = true
   label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
   tree.root.call_deferred("add_child", label)

   label.position = position
   
   var tween: Tween = tree.create_tween()
   tween.set_parallel(true)
   tween.tween_property(label, "position", label.position + offset, duration).set_ease(Tween.EASE_IN)
   tween.tween_property(label, "modulate", Color.TRANSPARENT, duration*3/4).set_delay(duration/4).set_ease(Tween.EASE_IN)
   tween.tween_property(label, "pixel_size", 0.001, duration*3/4).set_delay(duration/4).set_ease(Tween.EASE_IN)
   
   await tween.finished
   label.queue_free()
