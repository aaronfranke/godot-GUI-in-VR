extends ARVROrigin

# Future proofing.
const XRServer = ARVRServer

var player_height := 1.9
var scale_power := 0

var _ws := 1.0

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
	var child_count = get_child_count()
	for i in range(3, child_count):
		var new_ws = ARVRServer.world_scale
		if _ws != new_ws:
			_ws = new_ws
			get_child(i).scale = Vector3.ONE * _ws
