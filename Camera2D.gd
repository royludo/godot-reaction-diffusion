extends Camera2D


var dragging_camera:bool = false
var drag_start_pos:Vector2
var camera_start_pos:Vector2
var zoom_strength:float = 0.1
var zoom_up_limit:float = 1.0 

func _input(event):
	if event.is_action_pressed("camera_drag"):
		dragging_camera = true
		
		# update camera pos to get true pos (if limits used)
		var camera_screen_size = get_viewport().size * zoom
		camera_start_pos = get_position()
		if camera_start_pos.x < limit_left:
			camera_start_pos.x = limit_left
		if camera_start_pos.x > (limit_right - camera_screen_size.x):
			camera_start_pos.x = limit_right - camera_screen_size.x
		if camera_start_pos.y < limit_top:
			camera_start_pos.y = limit_top
		if camera_start_pos.y > (limit_bottom - camera_screen_size.y):
			camera_start_pos.y = limit_bottom - camera_screen_size.y
		
		drag_start_pos = get_viewport().get_mouse_position()
		
		#print(str(drag_start_pos))
	elif event.is_action_released("camera_drag"):
		dragging_camera = false
	
	if event.is_action_pressed("zoom_in"):
		zoom *= (1 - zoom_strength)
	elif event.is_action_pressed("zoom_out"):
		var current_zoom = zoom.x
		current_zoom *= (1 + zoom_strength)
		var limited_zoom = min(current_zoom, zoom_up_limit)
		zoom = Vector2(limited_zoom, limited_zoom)

func _process(_delta):
	if dragging_camera:
		var current_mouse_pos = get_viewport().get_mouse_position()
		var movement = current_mouse_pos - drag_start_pos
		#print(str(camera_start_pos)+" "+str(movement))
		set_position(camera_start_pos - (movement * zoom.x))
		#print("offset "+str(camera.position))
