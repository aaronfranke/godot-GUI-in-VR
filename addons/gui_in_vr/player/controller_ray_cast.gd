extends RayCast

# Future proofing.
const XRServer = ARVRServer

var _is_activating_gui := false
var _old_raycast_collider: PhysicsBody = null
var _old_viewport_point: Vector2

onready var _controller = get_parent()

func _process(_delta):
	var raycast_collider = get_collider()
	# First of all, check if we need to release a previous mouse click.
	if _old_raycast_collider and raycast_collider != _old_raycast_collider:
		_release_mouse()
	elif raycast_collider:
		_try_send_input_to_gui(raycast_collider)


func _try_send_input_to_gui(raycast_collider):
	var viewport = raycast_collider.get_child(0)
	if not (viewport is Viewport):
		return # This isn't something we can give input to.

	var collider_transform = raycast_collider.global_transform
	if collider_transform.xform_inv(global_transform.origin).z < 0:
		return # Don't allow pressing if we're behind the GUI.

	# Convert the collision to a relative position. Expects the 2nd child to be a CollisionShape.
	var shape_size = raycast_collider.get_child(1).shape.extents * 2
	var collision_point = get_collision_point()
	var collider_scale = collider_transform.basis.get_scale()
	var local_point = collider_transform.xform_inv(collision_point)
	local_point /= (collider_scale * collider_scale)
	local_point /= shape_size
	local_point += Vector3(0.5, -0.5, 0) # X is about 0 to 1, Y is about 0 to -1.

	# Find the viewport position by scaling the relative position by the viewport size. Discard Z.
	var viewport_point = Vector2(local_point.x, -local_point.y) * viewport.size

	# Send mouse motion to the GUI.
	var event = InputEventMouseMotion.new()
	event.position = viewport_point
	viewport.input(event)

	# Figure out whether or not we should trigger a click.
	var desired_activate_gui := false
	var distance = global_transform.origin.distance_to(collision_point) / XRServer.world_scale
	if distance < 0.1:
		desired_activate_gui = true # Allow "touching" the GUI.
	else:
		desired_activate_gui = _is_trigger_pressed() # Else, use the trigger.

	# Send a left click to the GUI depending on the above.
	if desired_activate_gui != _is_activating_gui:
		event = InputEventMouseButton.new()
		event.pressed = desired_activate_gui
		event.button_index = BUTTON_LEFT
		event.position = viewport_point
		viewport.input(event)
		_is_activating_gui = desired_activate_gui
		_old_raycast_collider = raycast_collider
		_old_viewport_point = viewport_point


func _release_mouse():
	var event = InputEventMouseButton.new()
	event.button_index = 1
	event.position = _old_viewport_point
	_old_raycast_collider.get_child(0).input(event)
	_old_raycast_collider = null
	_is_activating_gui = false


func _is_trigger_pressed():
	return _controller.get_joystick_axis(JOY_VR_ANALOG_TRIGGER) > 0.6
