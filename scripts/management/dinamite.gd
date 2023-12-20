extends Area2D

var dinamite_speed: float = 300
var direction: int = -1
var player_ref = null
var distance: float

func _process(delta):
	position.x += dinamite_speed * direction * delta
	

func on_body_entered(body):
	if body.name == "Knight":
		player_ref = body
