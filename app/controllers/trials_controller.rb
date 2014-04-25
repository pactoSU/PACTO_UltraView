class TrialsController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  
  def index
	@str = Base64.strict_encode64('Space World')
  end
  
end
