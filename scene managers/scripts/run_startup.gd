extends Resource
class_name RunStartup

enum Type {NEW_RUN, CONTINUED_RUN}

@export var type: Type
@export var character_setup: CharStats
