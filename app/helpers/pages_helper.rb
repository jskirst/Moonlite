module PagesHelper
	def translate_user_event(event)
		event.content = event.content.gsub("<%u%>", (link_to event.user.name, user_url(event.user)))
		event.content = event.content.gsub("<%p%>", (link_to event.path.name, path_url(event.path)))
		return event.content
	end
end
