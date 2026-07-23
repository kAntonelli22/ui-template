extends Node2D

@onready var button: Button = $Button

func _on_button_pressed() -> void:
   $PanelSlider.move_to_next_point()
   FloatingText.create_2d("word", button.position + button.size/2)
   
   $CanvasLayer/RadialMenu.toggle_button("Button1")

func _input(event: InputEvent) -> void:
   if event.is_action_pressed("action"):
      $CanvasLayer/RadialMenu.open_menu_at(get_viewport().get_mouse_position())
      return
   if event.is_action_pressed("ui_accept"):
      $CanvasLayer/RadialMenu.close_menu()
