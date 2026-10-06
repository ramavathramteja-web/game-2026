extends SceneTree

func _initialize() -> void:
    var s = load("res://src/core/LightSwitch.gd")
    if s:
        print("Loaded: ", s)
        print("Class: ", s.get_class())
        print("Resource path: ", s.resource_path)
        print("Members: ", s.get_member_list())
    else:
        print("FAILED to load")
    quit()