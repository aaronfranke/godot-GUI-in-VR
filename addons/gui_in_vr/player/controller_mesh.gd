extends MeshInstance

# Future proofing.
const XRServer = ARVRServer

signal controller_activated(controller)

var _ws := 1.0

onready var _parent = get_parent()
onready var ovr_render_model = preload("res://addons/godot-openvr/OpenVRRenderModel.gdns").new()
onready var vive_material = preload("res://addons/gui_in_vr/vive/vive.tres")
onready var touchpad_cylinder = $Touchpad/Cylinder
onready var touchpad_selection_dot = $Touchpad/SelectionDot

func _ready():
	_parent.visible = false


func _process(_delta):
	_base_controller_mesh_stuff()

	# Show a hint where the user's finger is on the touchpad.
	var touchpad_input = Vector2(_parent.get_joystick_axis(0), _parent.get_joystick_axis(1))
	if touchpad_input == Vector2.ZERO:
		touchpad_selection_dot.translation = Vector3.ZERO
	else:
		touchpad_selection_dot.translation = Vector3(touchpad_input.x, 0.5, -touchpad_input.y) * 0.018


func _base_controller_mesh_stuff():
	if !_parent.get_is_active():
		_parent.visible = false
		return

	_scale_controller_mesh()

	# Was active before, we don't need to do anything.
	if _parent.visible:
		return

	# Became active, handle it.
	var controller_name = _parent.get_controller_name()
	print("Controller " + controller_name + " became active")

	# Attempt to load a mesh for this controller.
	mesh = load_controller_mesh(controller_name)
	touchpad_cylinder.visible = controller_name.find("vive") < 0
	if !touchpad_cylinder.visible:
		material_override = vive_material

	# Make it visible.
	_parent.visible = true
	emit_signal("controller_activated", _parent)


func load_controller_mesh(controller_name):
	if ovr_render_model.load_model(controller_name.substr(0, controller_name.length() - 2)):
		return ovr_render_model
	if ovr_render_model.load_model("generic_controller"):
		return ovr_render_model

	printerr("Unable to load a controller mesh.")
	return Mesh.new()


func _scale_controller_mesh():
	var new_ws = XRServer.world_scale
	if _ws != new_ws:
		_ws = new_ws
		scale = Vector3.ONE * _ws
