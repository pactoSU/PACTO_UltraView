class ExamsController < ApplicationController

  
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
