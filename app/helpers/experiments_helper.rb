module ExperimentsHelper

	def slot_is_control_group?(slot)
		(slot == 0)
	end
	

	def class_for_goal_row(conversion, goal_count)
		return 'disabled' if goal_count < 600
		return 'success' if conversion > 3
		return 'warning' if (conversion < -3) && (conversion > -10)
		return 'error' if conversion < -10
	end
end
