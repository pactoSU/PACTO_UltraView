class ExamsController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  
  def index
	@coll = MONGO_CLIENT["fs.files"]
  end
  
  def show
	@file = Grid.new(MONGO_CLIENT).get(BSON::ObjectId( params[:id] ))
  end
  
  def view
  end
  
  def download
	file_str = Grid.new(MONGO_CLIENT).get(BSON::ObjectId(params[:id])).read
	dcmImg = DICOM::DObject.parse(file_str).image
	stream = StringIO.new
	dcmImg.write(stream)
	send_data stream.string, :filename => "dcm.bmp"
  end
end
