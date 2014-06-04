class ExamsController < ApplicationController

  
  def index
	@cursor = MONGO_CLIENT["fs.files"].find("filename" => "A dicom file")
	
  end
  
  def show
	@file = Grid.new(MONGO_CLIENT).get(BSON::ObjectId( params[:id] ))
  end
  
  def view
  end
    
  def download
  
	nameOfFile = params[:id]
	file_str = Grid.new(MONGO_CLIENT).get(BSON::ObjectId(nameOfFile)).read
	dcmImg = DICOM::DObject.parse(file_str).image
	stream = StringIO.new
	dcmImg.write(stream)
	send_data stream.string, :filename => nameOfFile+".bmp"
  end
  
    def dispImage
	@@curFrame = params[:frame].to_i
	file_str = Grid.new(MONGO_CLIENT).get(BSON::ObjectId(params[:id])).read
	@@dcmFile = DICOM::DObject.parse(file_str)
  end
  
  def updateFrame
	dcmImg = @@dcmFile.image(:frame => @@curFrame)
	stream = StringIO.new
	dcmImg.write(stream)
	send_data stream.string, :type => 'image/png',:disposition => 'inline'
  end
  
  def incrementFrame
	@@curFrame = @@curFrame+1
	controller.updateFrame
	end


  def delete
  		nameOfFile = params[:id]
		MONGO_CLIENT["fs.files"].remove("_id"=> BSON::ObjectId(nameOfFile))
		flash[:success] = "Image deleted."
		redirect_to exams_path
		end
		
		
	def search
		@cursor = MONGO_CLIENT["fs.files"].find({params[:tag] => params[:val]})
	end
end
