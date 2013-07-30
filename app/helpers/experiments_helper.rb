module ExperimentsHelper

	def slot_is_control_group?(slot)
		(slot == 0)
	end
	

	def class_for_goal_row(performance_percent)
			return 'disabled' if performance_percent > -3 && performance_percent < 3
			return 'success' if performance_percent > 3
			return 'warning' if performance_percent <= -3 && performance_percent > -6
			return 'error' if performance_percent <= -6
	end
end
