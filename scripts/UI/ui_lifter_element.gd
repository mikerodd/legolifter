class_name UILifterElement extends Control


var speed : float = 1
var stored_darken : bool = false 

static var null_np: NodePath
func _ready() -> void:
	pass
	if not "ui_show_position" in self or \
		not "ui_hide_position" in self:
		push_error ("UILifterElement descendant '%s' without ui_show_position or ui_hide_position " % self.name)


func _show_me(darken : bool = false ) -> void :
	stored_darken = darken
	if darken:
		Messenger.ui_darken_display.emit()
	if "ui_show_position" in self:
		create_tween().tween_property(self,"position:x",self.ui_show_position, speed)\
			.set_trans(Tween.TRANS_ELASTIC)

func _hide_me(lighten : bool = false) -> void:
	if (lighten or stored_darken): 
		Messenger.ui_englight_display.emit()
	if "ui_hide_position" in self:
		create_tween().tween_property(self,"position:x",self.ui_hide_position, speed)\
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
	
