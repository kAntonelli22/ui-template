extends Node3D


func _on_button_pressed() -> void:
   FloatingText.create_3d("words", $CSGBox3D.position + Vector3(0, 1, 0), 0.5)
