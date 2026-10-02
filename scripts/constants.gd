class_name Constants

const VERSION_NAME = "0.0.1"
const VERSION_CODE = 1

static func get_full_version():
	return "%s (%d)" % [VERSION_NAME, VERSION_CODE]
