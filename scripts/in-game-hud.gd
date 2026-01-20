extends Control

func set_next_item(item: int)-> void:
	$VBox/NextItem/NextItemValue.text = str(item)

func set_score(new_score: int) -> void:
	$VBox/Score/ScoreValue.text = str(new_score)
