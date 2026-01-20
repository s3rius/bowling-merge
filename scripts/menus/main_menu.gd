extends Control

func _ready() -> void:
	$VFlowContainer/StartButton.connect("pressed", start_game)
	$VFlowContainer/QuitButton.connect("pressed", quit_game)

func start_game():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func quit_game():
	get_tree().quit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		quit_game()
