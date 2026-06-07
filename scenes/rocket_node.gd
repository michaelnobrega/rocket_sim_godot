# scenes/rocket.gd — visual controller for the rocket scene
extends Node2D

@onready var exhaust = $Exhaust

var rocket_data: Rocket  # referência ao objeto de física


func setup(data: Rocket) -> void:
	rocket_data = data
	var actual_px = data.sprite_height_px * data.sprite_import_scale
	var scale_factor = (data.length * Config.WORLD_SCALE) / actual_px
	scale = Vector2(scale_factor, scale_factor)


func _ready() -> void:
	exhaust.visible = false
	exhaust.stop()


func update_visuals() -> void:
	if rocket_data == null:
		return
	if rocket_data.engine_on and not rocket_data.landed:
		exhaust.visible = true
		exhaust.play("high")
	else:
		exhaust.visible = false
		exhaust.stop()


func _process(_delta: float) -> void:
	update_visuals()
