extends ARVROrigin

# Future proofing.
const XRServer = ARVRServer

var _ws := 1.0

onready var _camera = $XRCamera
onready var _camera_near_scale = _camera.near
onready var _camera_far_scale = _camera.far


func _ready():
	var vr = XRServer.find_interface("OpenVR")
	if vr and vr.initialize():
		var viewport = get_viewport()
		viewport.arvr = true
		viewport.hdr = false
		OS.set_window_maximized(true)
		OS.vsync_enabled = false
		Engine.target_fps = 180
	else:
		printerr("Can't initialize OpenVR, exiting.")
		get_tree().quit()


func _process(_delta):
	var new_ws = XRServer.world_scale
	if _ws != new_ws:
		_ws = new_ws
		_camera.near = _ws * _camera_near_scale
		_camera.far = _ws * _camera_far_scale
		var child_count = get_child_count()
		for i in range(3, child_count):
			get_child(i).scale = Vector3.ONE * _ws
