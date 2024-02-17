extends Node
class_name Menu_Entry

var module_index: int = -1
var description: String = ""

func set_info(new_description, new_icon):
	description = new_description
	if new_icon != null:
		get_node("Icon").texture = new_icon

#func _your_function():
#	# This could fail if, for example, mod.pck cannot be found.
#	var success = ProjectSettings.load_resource_pack("res://mod.pck")
#
#	if success:
#		# Now one can use the assets as if they had them in the project from the start.
#		var imported_scene = load("res://mod_scene.tscn")
