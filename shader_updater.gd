extends Node3D

var time = 0.0
var timeout = 8.1
var size = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Update shader parameters for every smoke grenade in scene
	for g in $"../../SmokeGrenades".get_children():
		var data = Vector4(position.x, position.y, position.z, size)
		var m = g.get_child(0).get_material()
		m.set_shader_parameter(name, data)
		m.set_shader_parameter(name + "_t", Time.get_ticks_msec() / 1000.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time > timeout:
		queue_free()
	time += delta
