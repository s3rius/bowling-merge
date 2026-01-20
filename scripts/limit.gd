extends Node3D

signal limit_hit

var bodies_in_limit: Dictionary[int, bool] = {}

func on_body_entered(body: Node) -> void:
	var pawn = body as Pawn
	bodies_in_limit[pawn.get_instance_id()] = true
	pawn.start_blinking()
	print("[Adding] Bodies in limit: ", bodies_in_limit.size())
	$LimitTimer.start(2.0)

func on_body_exited(body: Node) -> void:
	var pawn = body as Pawn
	pawn.stop_blinking()
	bodies_in_limit.erase(pawn.get_instance_id())
	print("[Removing] Bodies in limit: ", bodies_in_limit.size())
	if bodies_in_limit.is_empty():
		print("Limit cleared, stopping timer")
		$LimitTimer.stop()

func on_timer_timeout() -> void:
	limit_hit.emit()
	print("[Emitted] limit signal")
