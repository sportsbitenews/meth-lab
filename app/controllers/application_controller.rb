class ApplicationController < ActionController::Base
  protect_from_forgery

  include Lacmus::Lab
  # helper_method Lacmus::Lab.instance_methods
end
