extends CanvasLayer

@onready var resume_btn = $menu_holder/resume_btn 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = true
		get_tree().paused = true
		resume_btn.grab_focus()

func _on_resume_btn_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_quit_btn_pressed() -> void:
	get_tree().quit( )

func _on_restart_btn_pressed() -> void:
	get_tree().paused = false
	# Obtém o nome da cena atual
	var current_scene = get_tree().current_scene
	# Recarrega a cena atual
	get_tree().reload_current_scene()
	
