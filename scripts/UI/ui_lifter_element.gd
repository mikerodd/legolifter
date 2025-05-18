class_name UILifterElement extends Control


var speed : float = 1
var stored_darken : bool = false 
var size_x: float 
static var null_np: NodePath


func _ready() -> void:
	# FIXME size is set to 0 by the parent container ?
	size_x = self.size.x
	pass

func _show_me(darken : bool = false ) -> void :
	stored_darken = darken
	if darken:
		Messenger.ui_darken_display.emit()
	create_tween().tween_property(self,"position:x", size_x, speed)\
		.set_trans(Tween.TRANS_ELASTIC)
	Logger.debug("show position for %s : %f" % [name, size_x])

func _hide_me(lighten : bool = false) -> void:
	if (lighten or stored_darken): 
		Messenger.ui_englight_display.emit()
	create_tween().tween_property(self,"position:x", 0, speed)\
	.set_trans(Tween.TRANS_ELASTIC)
	if Messenger.ui_show_previous_dialog.has_connections():
		Messenger.ui_show_previous_dialog.emit(lighten)
		cancel_return_to_previous()


func show_modal(previous:UILifterElement,sig: Signal, darken : bool = true):
	Messenger.ui_show_previous_dialog.connect(previous._show_me)
	sig.emit(darken)


func cancel_return_to_previous() -> void:
	for c in Messenger.ui_show_previous_dialog.get_connections():
		Messenger.ui_show_previous_dialog.disconnect(c.callable)
	
