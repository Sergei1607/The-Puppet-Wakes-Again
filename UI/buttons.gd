extends Button


func _physics_process(delta: float) -> void:
	print(has_focus())

func _ready() -> void:
	
	
	grab_focus()
	print(has_focus())
