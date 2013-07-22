module ApplicationHelper
	def nice_datetime(time_as_int)
		return '' if time_as_int.blank?
		t = Time.at(time_as_int)
    t.strftime("%d %b, %H:%M")
	end

	def time_ago_from_int(time_as_int)
		return '' if time_as_int.blank?
		t = Time.at(time_as_int)
		"about #{time_ago_in_words(t)} ago"
	end
end
