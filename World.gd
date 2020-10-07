extends Node2D

export(float) var DA:float
export(float) var f:float
export(float) var DB:float
export(float) var k:float
export(int) var fps_limit:int
export(int) var color_scale:int
export(bool) var exaggerate_colors:bool
export(bool) var display_BorA:bool
export(bool) var paint_BorA:bool

onready var intermediate_display:TextureRect = $Viewport2/TextureRect
onready var sim_shader:ShaderMaterial = $Viewport/BufferTexture.material as ShaderMaterial
onready var render_shader:ShaderMaterial = $finalDisplay.material as ShaderMaterial
var base_image:Image

onready var main_hbox = $UILayer/ColorRect/MarginContainer/HBoxContainer
onready var fps_control = main_hbox.get_node("GridContainer/FPSControl")
onready var true_fps_display = main_hbox.get_node("GridContainer/TrueFPS")
onready var color_scale_button = main_hbox.get_node("ColorScaleButton")
onready var DA_control = main_hbox.get_node("GridContainer2/DAControl")
onready var f_control = main_hbox.get_node("GridContainer2/FControl")
onready var DB_control = main_hbox.get_node("GridContainer3/DBControl")
onready var k_control = main_hbox.get_node("GridContainer3/KControl")
onready var play_button = main_hbox.get_node("VBoxContainer/HBoxContainer/Play")
onready var forward_button = main_hbox.get_node("VBoxContainer/HBoxContainer/Forward")
onready var reset_button = main_hbox.get_node("VBoxContainer/ResetButton")
onready var exaggerate_switch = main_hbox.get_node("VBoxContainer2/ExaggerateSwitch")
onready var display_AorB_control = main_hbox.get_node("VBoxContainer2/HBoxContainer/AorBSwitch")
onready var paint_AorB_control = main_hbox.get_node("VBoxContainer2/HBoxContainer/AorBPaintSwitch")

var sim_w:int = 1000
var sim_h:int = 500

var flagDrawOnDisplay = false

func _ready():
	randomize()
	
	var texture:Texture = intermediate_display.texture
	base_image = texture.get_data()
	
	update_sim_parameters()
	update_render_parameters()
	
	sim_shader.set_shader_param("pause_shader", true)
	
	intermediate_display.connect("draw", self, "draw_on_child")
	
	# init gui
	color_scale_button.add_item("viridis", 0)
	color_scale_button.add_item("inferno", 1)
	color_scale_button.selected = 0
	fps_control.value = fps_limit
	DA_control.value = DA
	f_control.value = f
	DB_control.value = DB
	k_control.value = k

	# setup rendering
	sim_shader.set_shader_param("previous_image", $Viewport2.get_texture())
	intermediate_display.texture = $Viewport.get_texture()


var frame = 0
var flagContinue = false
var fps_refresh_rate = 30
func _process(_delta):
	frame += 1
	
	# avoid refreshing the fps label every frame
	if frame > fps_refresh_rate:
		frame = 0
		true_fps_display.text = str(Engine.get_frames_per_second())
	
	if flagDrawOnDisplay:
			intermediate_display.update()
		
	if flagContinue:
		# where the magic happens
		intermediate_display.texture = $Viewport.get_texture()
		sim_shader.set_shader_param("previous_image", $Viewport2.get_texture())
		
		sim_shader.set_shader_param("pause_shader", false)
	else:
		sim_shader.set_shader_param("pause_shader", true)


func _input(event):
	if event.is_action_pressed("mouse_click"):
		flagDrawOnDisplay = true
	elif event.is_action_released("mouse_click"):
		flagDrawOnDisplay = false
		intermediate_display.update()


func draw_on_child():
	if flagDrawOnDisplay:
		var mouse_pos = $finalDisplay.get_local_mouse_position()
		var painting_color
		if paint_BorA:
			painting_color = Color.blue
		else:
			painting_color = Color.red
		intermediate_display.draw_circle( mouse_pos, 10, painting_color)


func update_sim_parameters():
	Engine.target_fps = fps_limit
	sim_shader.set_shader_param("DA", DA)
	sim_shader.set_shader_param("f", f)
	sim_shader.set_shader_param("DB", DB)
	sim_shader.set_shader_param("k", k)


func update_render_parameters():
	render_shader.set_shader_param("color_scale", color_scale)
	render_shader.set_shader_param("exaggerate_colors", exaggerate_colors)
	render_shader.set_shader_param("display_BorA", display_BorA)


## the rest is pure gui stuff ##


func _on_ColorScaleButton_item_selected(index):
	color_scale = index
	update_render_parameters()


func _on_FPSControl_value_changed(value):
	fps_limit = value
	update_sim_parameters()


func _on_DAControl_value_changed(value):
	DA = value
	update_sim_parameters()


func _on_FControl_value_changed(value):
	f = value
	update_sim_parameters()


func _on_DBControl_value_changed(value):
	DB = value
	update_sim_parameters()


func _on_KControl_value_changed(value):
	k = value
	update_sim_parameters()


func _on_Forward_button_down():
	flagContinue = true


func _on_Forward_button_up():
	flagContinue = false


func _on_Play_toggled(button_pressed):
	if button_pressed:
		forward_button.disabled = true
		flagContinue = true
		play_button.text = "Pause"
	else:
		forward_button.disabled = false
		flagContinue = false
		play_button.text = "Play"


func _on_ExaggerateSwitch_toggled(button_pressed):
	exaggerate_colors = button_pressed
	update_render_parameters()


func _on_AorBSwitch_toggled(button_pressed):
	display_BorA = button_pressed
	update_render_parameters()
	if button_pressed:
		display_AorB_control.text = "Displaying B"
	else:
		display_AorB_control.text = "Displaying A"


func _on_AorBPaintSwitch_toggled(button_pressed):
	paint_BorA = button_pressed
	if button_pressed:
		paint_AorB_control.text = "Painting B"
	else:
		paint_AorB_control.text = "Painting A"


func _on_ResetButton_pressed():
	if play_button.pressed:
		play_button.pressed = false
	var start_texture = ImageTexture.new()
	start_texture.create_from_image(base_image)
	intermediate_display.texture = start_texture


func _on_HelpButton_pressed():
	if play_button.pressed:
		play_button.pressed = false
	$UILayer/ColorRect/HelpPopup.popup_centered(Vector2(900,350))
