module ExperimentsHelper

	def slot_is_control_group?(slot)
		(slot == 0)
	end

	def experiment_preview_url(experiment)
		"#{experiment.url}?render-variation=experiment"
	end
	
	def control_preview_url(experiment)
		"#{experiment.url}?render-variation=control"
	end

	def force_experiment_cookie_url(experiment_id)
		slot_ids 				= Lacmus::SlotMachine.experiment_slot_ids
		amount_of_slots = slot_ids.size
		slot_index 		  = slot_ids.index(experiment_id)
		new_user_id     = amount_of_slots + slot_index
		return "#{$lacmus_settings[:host]}/lacmus/force_exp?id=#{new_user_id}"
	end

	def class_for_goal_row(experiment, kpi)
			performance_percent = experiment.performance_perc(kpi)
			total_goals = experiment.control_kpis[kpi].to_i + experiment.experiment_kpis[kpi].to_i

			return if performance_percent.nil?
			return 'disabled' if (total_goals < 500) || performance_percent > -3 && performance_percent < 3
			return 'success' if performance_percent > 3
			return 'warning' if performance_percent <= -3 && performance_percent > -6
			return 'error' if performance_percent <= -6
	end
end
