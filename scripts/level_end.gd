extends Area2D

@export var next_level = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(_body: Node2D) -> void:
	call_deferred("load_next_scene")

func load_next_scene():
	get_tree().change_scene_to_file("res://scene/" + next_level + ".tscn")
