extends Node2D

@onready var button: Button = $Button

func _on_button_pressed() -> void:
   $PanelSlider.move_to_next_point()
   FloatingText.create_2d("word", button.position + button.size/2)
