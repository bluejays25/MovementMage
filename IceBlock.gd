extends Area3D
class_name IceBlock

func _on_timer_timeout() -> void:
	queue_free()
