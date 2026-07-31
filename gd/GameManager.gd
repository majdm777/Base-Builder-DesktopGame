extends Node

enum State{
	play,
	building,
	destroying
}

var Current_State = State.play

var Wood : float = 20.0
var Stone : float = 20
var Iron : float = 20
var Gold : float = 20

var population : int = 0
var MaxPopulation : int = 4
var AvlPopulation : int = 0

var citizen : PackedScene
var Happiness := 1

var spawnReady := true 

var Food : float =20
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if population < MaxPopulation && spawnReady && Happiness > 0:
		spawnReady = false
		await get_tree().create_timer(3.0).timeout
		spawnReady = true
		population +=1
		AvlPopulation +=1
	elif  spawnReady && Happiness < 0 :
		spawnReady = false
		await get_tree().create_timer(60).timeout
		spawnReady = true
		if AvlPopulation >0:
			AvlPopulation -= 1
	pass
