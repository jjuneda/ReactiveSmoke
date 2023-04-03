extends Node3D


var _physic_state: PhysicsDirectSpaceState3D
var _camera: Camera3D
var smoke_grenade = preload("res://smoke_grenade.tscn")
var shader_updater = preload("res://shader_updater.gd")
var MAX_FRAGS = 16
var MAX_BULLETS = 16


func _ready() -> void:
	_physic_state = get_viewport().get_world_3d().get_direct_space_state()
	_camera = get_viewport().get_camera_3d()

# Spawn a frag grenade with sequential ID for consistent data sharing with fog shader
func add_frag(pos):
	var frags = $Grenades/FragGrenades
	var frag_num = frags.get_child_count()
	var sorted = []
	# Get sorted children
	for f in frags.get_children():
		sorted.append(f)
	sorted.sort_custom(func(a, b): return int(a.name.substr(1)) < int(b.name.substr(1)))
	
	# Find next id
	var prev = 0
	for f in sorted:
		var num = int(f.name.substr(1))
		if num != prev:
			break
		prev += 1
	
	# Only allow sixteen frag grenades for now
	if prev < MAX_FRAGS:
		var frag = Node3D.new()
		frag.set_script(shader_updater)
		frag.size = 3.0
		frag.name = "F" + str(prev)
		frag.set_position(pos)
		frags.add_child(frag)

# Spawn a bullet trail with sequential ID
func add_bullet(pos):
	var bullets = $Grenades/BulletTrails
	var frag_num = bullets.get_child_count()
	var sorted = []
	# Get sorted children
	for f in bullets.get_children():
		sorted.append(f)
	sorted.sort_custom(func(a, b): return int(a.name.substr(1)) < int(b.name.substr(1)))
	
	# Find next id
	var prev = 0
	for f in sorted:
		var num = int(f.name.substr(1))
		if num != prev:
			break
		prev += 1
	
	# Only allow sixteen trails for now
	if prev < MAX_BULLETS:
		var bullet = Node3D.new()
		bullet.set_script(shader_updater)
		bullet.size = 0.9
		bullet.name = "B" + str(prev)
		bullet.set_position(pos)
		bullets.add_child(bullet)

func ray_query():
	var ray_query := PhysicsRayQueryParameters3D.new()
	var mouse_pos = get_viewport().get_mouse_position()
	ray_query.from = _camera.project_ray_origin(mouse_pos)
	ray_query.to = ray_query.from + _camera.project_ray_normal(mouse_pos) * 100.0
	var hit := _physic_state.intersect_ray(ray_query)
	return null if hit.is_empty() else hit.position

func _physics_process(_delta):
	# Smoke grenades on hit with geometry
	if Input.is_action_just_released("throw_smoke"):
		# Mouse position to world coordinates
		var hit = ray_query()
		if hit == null:
			return
		
		# Spawn a smoke cloud
		var grenade = smoke_grenade.instantiate()
		grenade.set_position(hit)
		$Grenades/SmokeGrenades.add_child(grenade)
		return
		
	# Frag grenades on hit with geometry
	if Input.is_action_just_released("throw_frag"):
		# Mouse position to world coordinates
		var hit = ray_query()
		if hit == null:
			return
		
		add_frag(hit)
		
	# Bullets on click, no hit necessary
	if Input.is_action_just_released("shoot_rifle"):
		# Mouse position to world coordinates
		var ray_query := PhysicsRayQueryParameters3D.new()
		var mouse_pos = get_viewport().get_mouse_position()
		ray_query.from = _camera.project_ray_origin(mouse_pos)
		ray_query.to = ray_query.from + _camera.project_ray_normal(mouse_pos) * 100.0
		add_bullet(ray_query.to)
