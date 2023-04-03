extends Node3D

var time = 0.0
var timeout = 8.1 # TODO pass this as parameter
var fog_material = preload("res://FogShader.tres")
var fog_instance = fog_material.duplicate() # Unique shader instances

# Called when the node enters the scene tree for the first time.
func _ready():
	var cam = $"../../../Camera3D"
	$FogVolume.set_material(fog_instance)
	fog_instance.set_shader_parameter("pos_size", Vector4($FogVolume.global_position.x, $FogVolume.global_position.y, $FogVolume.global_position.z, $FogVolume.size.x))
	fog_instance.set_shader_parameter("cam_pos", Vector3(cam.global_position.x, cam.global_position.y, cam.global_position.z))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update shader parameters
	fog_instance.set_shader_parameter("negative_p", $"../../NegativeVolumes/Volume0".position)
	fog_instance.set_shader_parameter("negative_b", $"../../NegativeVolumes/Volume0".size if $"../../NegativeVolumes/Volume0".is_visible() else Vector3(0.0, 0.0, 0.0))
	fog_instance.set_shader_parameter("time", time)
	
	# Remove from scene on timeout
	if time > timeout:
		queue_free()
	
	time += delta
