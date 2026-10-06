extends SceneTree

func _initialize() -> void:
    var s = load("res://src/core/Speaker.gd")
    if s:
        print("Loaded: ", s)
        print("Class: ", s.get_class())
        print("Resource path: ", s.resource_path)
    else:
        print("FAILED to load")
    quit()