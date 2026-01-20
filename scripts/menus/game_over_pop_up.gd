extends CanvasLayer

func _ready() -> void:
	$Control/VBoxContainer/RetryButton.connect("pressed", retry)
	$Control/VBoxContainer/MainMenuButton.connect("pressed", go_to_main_menu)

func retry() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		go_to_main_menu()
