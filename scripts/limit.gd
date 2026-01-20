extends Node3D

@export var limit_timer: float = 2.0

signal limit_hit

var bodies_in_limit: Dictionary[int, bool] = {}

func _ready() -> void:
	$Area3D.connect("body_entered", on_body_entered)
	$Area3D.connect("body_exited", on_body_exited)

func on_body_entered(body: Node) -> void:
	var pawn = body as Pawn
	bodies_in_limit[pawn.get_instance_id()] = true
	pawn.start_blinking()
	if $LimitTimer.is_stopped():
		$LimitTimer.start(limit_timer)

func on_body_exited(body: Node) -> void:
	var pawn = body as Pawn
	pawn.stop_blinking()
	bodies_in_limit.erase(pawn.get_instance_id())
	if bodies_in_limit.is_empty():
		$LimitTimer.stop()

func on_timer_timeout() -> void:
	limit_hit.emit()
