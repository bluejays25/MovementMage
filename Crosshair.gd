extends Control

var norm_line

func _draw() -> void:
	draw_circle(Vector2.ZERO, 4, Color.DIM_GRAY)
	draw_circle(Vector2.ZERO, 3, Color.WHITE)
	if norm_line:
		draw_line(norm_line[0], norm_line[1], Color.RED, 5)

func set_norm_line(line) -> void:
	norm_line = line
	if line:
		norm_line[0] -= position
		norm_line[1] -= position
	queue_redraw()
