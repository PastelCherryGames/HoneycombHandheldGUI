extends Control
class_name Menu

export var color_schemes: Array = []
export var entries: Array = []
var modules: Array = []
export var settings_desc: String
export var settings_icon: Texture
export var tama_desc: String
export var tama_icon: Texture
export var get_games_desc: String
export var get_games_icon: Texture
export var power_off_desc: String
export var power_off_icon: Texture

var hovered_entry: Control
var input_timeout: float = -1.0
var input_timeout_length = 0.3
onready var pointer: Control = get_node("Menu Background/Menu Pointer")
onready var menu_desc: Control = get_node("Menu Background/Menu Desc")

enum Submenus {SETTINGS, GAME}
var submenu_open: bool = false
var current_submenu = Submenus.SETTINGS
var current_option: int = 0
var volume: int = 5
var color_scheme: int = 0

func _ready():
	material.set_shader_param("base_color_1", Plane(color_schemes[0][0].r, color_schemes[0][0].g, color_schemes[0][0].b, color_schemes[0][0].a))
	material.set_shader_param("base_color_2", Plane(color_schemes[0][1].r, color_schemes[0][1].g, color_schemes[0][1].b, color_schemes[0][1].a))
	material.set_shader_param("base_color_3", Plane(color_schemes[0][2].r, color_schemes[0][2].g, color_schemes[0][2].b, color_schemes[0][2].a))
	material.set_shader_param("base_color_4", Plane(color_schemes[0][3].r, color_schemes[0][3].g, color_schemes[0][3].b, color_schemes[0][3].a))
	set_color_scheme()
	get_node("Splash").show()
	OS.window_position = Vector2(0, 0)
	
	var settings = Module.new()
	modules.append(settings)
	settings.description = settings_desc
	settings.icon = settings_icon
	var tamagotchi = Module.new()
	modules.append(tamagotchi)
	tamagotchi.description = tama_desc
	tamagotchi.icon = tama_icon
	
	# load games here
	
	var get_games = Module.new()
	modules.append(get_games)
	get_games.description = get_games_desc
	get_games.icon = get_games_icon
	var power_off = Module.new()
	modules.append(power_off)
	power_off.description = power_off_desc
	power_off.icon = power_off_icon
	
	var count = 0
	for module in modules:
		var entry = get_node(entries[count])
		entry.module_index = count
		entry.set_info(module.description, module.icon)
		entry.show()
		count += 1
	
	get_node("Settings Menu/Volume Value").text = String(volume)
	get_hovered_entry()

func _process(delta):
	if input_timeout >= 0:
		input_timeout -= delta

func _input(event):
	if (input_timeout < 0):
		if (submenu_open):
			if (event.as_text() == "Up"):
				if (current_option > 0 and current_submenu == Submenus.GAME):
					get_node("Game Menu/Arrow").rect_position = Vector2(40, get_node("Game Menu/Arrow").rect_position.y - 40)
					current_option -= 1
				elif (current_option > 0 and current_submenu == Submenus.SETTINGS):
					get_node("Settings Menu/Arrow").rect_position = Vector2(12, get_node("Settings Menu/Arrow").rect_position.y - 40)
					current_option -= 1
			elif (event.as_text() == "Down"):
				if (current_option < 2 and current_submenu == Submenus.GAME):
					get_node("Game Menu/Arrow").rect_position = Vector2(40, get_node("Game Menu/Arrow").rect_position.y + 40)
					current_option += 1
				elif (current_option < 2 and current_submenu == Submenus.SETTINGS):
					get_node("Settings Menu/Arrow").rect_position = Vector2(12, get_node("Settings Menu/Arrow").rect_position.y + 40)
					current_option += 1
			elif (event.as_text() == "Left"):
				if (current_submenu == Submenus.SETTINGS and current_option == 0 and volume > 0):
					volume -= 1
					get_node("Settings Menu/Volume Value").text = String(volume)
				elif (current_submenu == Submenus.SETTINGS and current_option == 1):
					if (color_scheme > 0):
						color_scheme -= 1
					else:
						color_scheme = color_schemes.size() - 1
					set_color_scheme()
			elif (event.as_text() == "Right"):
				if (current_submenu == Submenus.SETTINGS and current_option == 0 and volume < 5):
					volume += 1
					get_node("Settings Menu/Volume Value").text = String(volume)
				elif (current_submenu == Submenus.SETTINGS and current_option == 1):
					if (color_scheme < (color_schemes.size() - 1)):
						color_scheme += 1
					else:
						color_scheme = 0
					set_color_scheme()
			elif (event.as_text() == "X"):
				if (
					(current_submenu == Submenus.SETTINGS and current_option == 2)
					or current_submenu == Submenus.GAME and current_option == 2
				):
					toggle_submenu(false)
				elif (current_submenu == Submenus.GAME and current_option == 0):
					start_game()
				elif (current_submenu == Submenus.GAME and current_option == 1):
					delete_game()
			elif (event.as_text() == "Z"):
				toggle_submenu(false)
		else:
			var new_x = pointer.rect_position.x
			var new_y = pointer.rect_position.y
			if (event.as_text() == "Up"):
				if (new_y == 58):
					new_x -= 26
				elif (new_y == 101):
					new_x += 26
				if (new_y > 15):
					new_y -= 43
			elif (event.as_text() == "Down"):
				if (new_y == 15):
					new_x += 26
				elif (new_y == 58):
					new_x -= 26
				if (new_y < 101):
					new_y += 43
			elif (event.as_text() == "Left"):
				if (new_x > 29):
					new_x -= 52
			elif (event.as_text() == "Right"):
				if (new_x < 159):
					new_x += 52
			elif (event.as_text() == "X"):
				toggle_submenu(true)
			pointer.rect_position = Vector2(new_x, new_y)
			get_hovered_entry()
		input_timeout = input_timeout_length

func get_hovered_entry():
	var index: int = 0
	var current_x = get_node("Menu Background/Menu Pointer").rect_position.x
	var current_y = get_node("Menu Background/Menu Pointer").rect_position.y
	if (current_y == 58):
		index += 4
		current_x -= 26
	elif (current_y == 101):
		index += 8
	index += (current_x - 3) / 52
	
	hovered_entry = get_node(entries[index])
	if (hovered_entry.description == ""):
		menu_desc.text = "Empty slot"
	else:
		menu_desc.text = hovered_entry.description

func toggle_submenu(open: bool):
	submenu_open = open
	if open and hovered_entry.description == "Power off":
		get_node("Power Menu").show()
		OS.execute("shutdown", ["-h", "now"], true)
	elif open and hovered_entry.description == "Settings":
		current_submenu = Submenus.SETTINGS
		get_node("Settings Menu").show()
	elif open and hovered_entry.description == "Get new games":
		submenu_open = false
	elif !open:
		get_node("Settings Menu").hide()
		get_node("Game Menu").hide()
		get_node("Settings Menu/Arrow").rect_position = Vector2(12, 29)
		get_node("Game Menu/Arrow").rect_position = Vector2(40, 29)
		current_option = 0
	elif hovered_entry.description == "":
		submenu_open = false
	else:
		current_submenu = Submenus.GAME
		get_node("Game Menu").show()

func set_color_scheme():
	material.set_shader_param("palette_color_1", Plane(color_schemes[color_scheme][0].r, color_schemes[color_scheme][0].g, color_schemes[color_scheme][0].b, color_schemes[color_scheme][0].a))
	material.set_shader_param("palette_color_2", Plane(color_schemes[color_scheme][1].r, color_schemes[color_scheme][1].g, color_schemes[color_scheme][1].b, color_schemes[color_scheme][1].a))
	material.set_shader_param("palette_color_3", Plane(color_schemes[color_scheme][2].r, color_schemes[color_scheme][2].g, color_schemes[color_scheme][2].b, color_schemes[color_scheme][2].a))
	material.set_shader_param("palette_color_4", Plane(color_schemes[color_scheme][3].r, color_schemes[color_scheme][3].g, color_schemes[color_scheme][3].b, color_schemes[color_scheme][3].a))

func start_game():
	pass

func delete_game():
	pass
