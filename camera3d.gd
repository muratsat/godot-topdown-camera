extends Camera3D

@export var pan_speed: float = 0.05
@export var zoom_speed: float = 2
@export var zoom_scale: float = 0.05
@export var camera_friction: float = 0.9
@export var min_height: float = 10 
@export var max_height: float = 20
var camera_velocity: Vector2
var touch_points: Dictionary
var zoom_start_distance: float
var zoom_end_distance: float


func _input(event: InputEvent):
	if event is InputEventScreenTouch:
		_handle_touch(event)
		pass
	elif event is InputEventScreenDrag:
		_handle_drag(event)
		pass


func _physics_process(_delta):
	_move2d(camera_velocity * pan_speed);
	camera_velocity *= camera_friction


func _handle_touch(event: InputEventScreenTouch):
	if event.pressed:
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)

	if touch_points.size() == 2:
		var touch_points_positions = touch_points.values()
		zoom_start_distance = touch_points_positions[0].distance_to(touch_points_positions[1])
	else:
		zoom_start_distance = 0
		zoom_end_distance = 0


func _handle_drag(event: InputEventScreenDrag):
	touch_points[event.index] = event.position

	if touch_points.size() == 1:
		camera_velocity += event.relative
	elif touch_points.size() == 2:
		var touch_points_positions = touch_points.values()
		zoom_end_distance = touch_points_positions[0].distance_to(touch_points_positions[1])
		_process_zoom()
		zoom_start_distance = zoom_end_distance
	else:
		zoom_start_distance = 0
		zoom_end_distance = 0


func _move2d(vector: Vector2) -> void:
	position -= Vector3(vector.x, 0, vector.y) * pan_speed


func _process_zoom():
	var delta = (zoom_start_distance - zoom_end_distance ) * zoom_scale
	var camera_direction = get_global_transform().basis.z
	var target_direction = camera_direction * delta
	if _can_zoom(target_direction):
		position += target_direction


func _can_zoom(target_direction: Vector3) -> bool:
	var target = position + target_direction
	return min_height < target.y and target.y < max_height;
