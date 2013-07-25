class SettingsController < ApplicationController
	
	def edit
		@active_slots_count = Lacmus::SlotMachine.experiment_slot_ids.count
	end

	def update
		Lacmus::SlotMachine.resize_slot_array(params[:slot_count].to_i)
		redirect_to root_path
	end
end