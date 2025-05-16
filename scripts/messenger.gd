# warnings-disable
extends Node

@warning_ignore("unused_signal")
signal player_landing
@warning_ignore("unused_signal")
signal update_scores
@warning_ignore("unused_signal")
signal exit_game
@warning_ignore("unused_signal")
signal play_game
@warning_ignore("unused_signal")
signal begin_game
@warning_ignore("unused_signal")
signal demo_timer_authorized
@warning_ignore("unused_signal")
signal demo_timer_forbidden

@warning_ignore("unused_signal")
signal release_hostages
@warning_ignore("unused_signal")
signal show_side_buttons
@warning_ignore("unused_signal")
signal return_to_start
@warning_ignore("unused_signal")
signal begin_play
@warning_ignore("unused_signal")
signal level_started(level: int)
@warning_ignore("unused_signal")
signal end_game
@warning_ignore("unused_signal")
signal start_screen      # start screen
@warning_ignore("unused_signal")
signal return_to_base    # signal the game we are ready to restart at base
@warning_ignore("unused_signal")
signal level_complete
@warning_ignore("unused_signal")
signal set_live_demo_mode(mode: String)

## UI Signals
@warning_ignore("unused_signal")
signal ui_darken_display
@warning_ignore("unused_signal")
signal ui_total_dark_display
@warning_ignore("unused_signal")
signal ui_englight_display
@warning_ignore("unused_signal")
signal ui_show_pause_buttons
@warning_ignore("unused_signal")
signal ui_show_previous_dialog
@warning_ignore("unused_signal")
signal ui_show_instructions
@warning_ignore("unused_signal")
signal ui_show_confirm
@warning_ignore("unused_signal")
signal ui_show_level
@warning_ignore("unused_signal")
signal ui_show_parameters
@warning_ignore("unused_signal")
signal ui_show_hall_of_fame
@warning_ignore("unused_signal")
signal ui_new_high_score(score : Dictionary)


func display_signal_mapping() -> void:
	for s in get_signal_list():
		print("Signal %s" % s.name)
		print("   Mapped to : ")
		for c in get_signal_connection_list(s.name):
			print("     - %s : %s " % [c.callable.get_object(), c.callable.get_method()])
	
