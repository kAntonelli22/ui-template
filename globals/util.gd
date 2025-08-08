extends Node

# ---- # Generic Palette
# Black - White (#15151A), (#292933), (#3E3E4D), (#A3A3CC), (#B8B8E6), (#CCCCFF),
# Rich Print BBCode (Dimgray), (Springgreen), (Royalblue), (Dimgray), (Dimgray), (#64649E), 

var class_colors = {
   "global": "[color=#64649E]Global[/color]",
   "signalbus": "[color=#64649E]SignalBus[/color]",
   "ui": "[color=#64649E]UI[/color]",
   "util": "[color=#64649E]Util[/color]",
}

# ---- # debug print that uses class colors and adds the line it was called from
var left_padding: int = 0
var center_padding: int = 135

func _ready() -> void:
   for key in class_colors.keys():
      var key_value: String = class_colors[key].get_slice("]", 1)
      if key_value.length() > left_padding:
         left_padding = key_value.length()

#FIXME needs a better name than tween text
func tween_text(text: String, position: Vector2, duration: float = 0.5, settings: LabelSettings = LabelSettings.new(), offset: Vector2 = Vector2(0, 40)):
   var label = Label.new()
   label.text = text
   label.z_index = 5
   label.label_settings = settings
   label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
   call_deferred("add_child", label)
   
   await label.resized
   label.set_global_position(position - label.size/2)
   label.pivot_offset = label.size/2
   var tween: Tween = get_tree().create_tween()
   tween.set_parallel(true)
   tween.tween_property(label, "position", label.position - offset, duration).set_ease(Tween.EASE_IN)
   tween.tween_property(label, "modulate", Color.TRANSPARENT, duration*3/4).set_delay(duration/4).set_ease(Tween.EASE_IN)
   tween.tween_property(label, "scale", Vector2(0.5, 0.5), duration*3/4).set_delay(duration/4).set_ease(Tween.EASE_IN)
   
   await tween.finished
   remove_child(label)
   label.queue_free()

#HACK bbcode in text causes formatting to be off
func print(args: Array, caller: String = ""):
   var stack = get_stack()
   var ln = -1
   var file_name = "Unknown"
   if stack.size() > 1:
      var caller_info = stack[1]
      ln = caller_info.line
      file_name = caller_info.source.get_file().get_basename()
   
   var text: String = ""
   for arg in args:
      text += str(arg)
   
   if !class_colors.has(file_name): return   # do not print if their is no class tag
   var printer: String = class_colors[file_name] + " | "
   var bbcode: int = printer.get_slice("]", 0).length() + 8 # closing bbcode bracket offset
   printer = printer.lpad(left_padding + bbcode)
   
   var final: String = printer + text
   var ln_name = " | " + file_name.rpad(8) + ": " + str(caller).rpad(8) + ": " + str(ln).rpad(8)
   
   if text.length() <= center_padding:
      final += "    "
      final = final.rpad(center_padding + bbcode - 7, ".")
      final += "   " + ln_name
      print_rich(final)
      return
   
   #FIXME doesnt function correctly
   #var offset: int = 0
   #while(text.length() > center_padding + printer.length()):
      #var first = final.substr(0, center_padding + printer.length() + offset)
      #var second = ".".lpad(bbcode-1) + " | " + final.substr(center_padding + text.length() + offset)
      #final += first + " " + str(ln_name) + "\n" + second
      #offset += first.length()
      #text.erase(0, center_padding + printer.length())
   print_rich(final)
