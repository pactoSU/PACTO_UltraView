class ExamsController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  
  def index
	@coll = MONGO_CLIENT["fs.files"]
  end
  
  def show
	@file = Grid.new(MONGO_CLIENT).get(BSON::ObjectId("5359ab1468d60607ac000001"))
  end
  
  def view
  end
  
end
