extends Node

enum State{
	play,
	building,
	destroying
}

var Current_State = State.play

var Wood : float = 20
var Stone : float = 20
var Iron : float = 20
var Gold : float = 20

var Food : float =20
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
