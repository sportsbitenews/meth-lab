# -*- encoding : utf-8 -*-

#Used to allow sending in either real exceptions, or just messages for reporting.  
def hoptoad_message(klass, message, exception=nil, level = 0, facility = 'fiverr-v2-app')

  Rails.logger.warn "#{message}. #{exception}"
end
