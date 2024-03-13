extends Node

# for release version, best use: "users://savegame.bin"
const SAVE_PATH = "res://savegame.bin"

func SaveGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data: Dictionary = {
		"Gold": Global.Gold,
	}
	var jstr = JSON.stringify(data)
	file.store_line(jstr)
	file.close()
	
func LoadGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if (FileAccess.file_exists(SAVE_PATH)):
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				Global.Gold = current_line["Gold"]
	file.close()
