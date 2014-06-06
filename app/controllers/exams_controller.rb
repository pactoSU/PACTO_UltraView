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
  
  def delete
  		nameOfFile = params[:id]
		MONGO_CLIENT["fs.files"].remove("_id"=> BSON::ObjectId(nameOfFile))
		flash[:success] = "Image deleted."
		redirect_to :back
		end
		
		
	def search
		@parameter = params[:tag]
		@value = params[:val]
	end
	
	
	
	
	def share
		@id =  params[:id]
		@cursor = MONGO_CLIENT["fs.files"].find("_id"=>BSON::ObjectId(@id ))
	end
	
	def addUser
	userName = params[:user]
	id = params[:id]
	
	if User.exists?(:name => userName)
	
	MONGO_CLIENT["fs.files"].update({"_id"=>BSON::ObjectId(id )}, { "$addToSet" => { "accessList" =>userName} } )
	flash[:success] = "File shared with "+userName+"."
	redirect_to root_path
	else
	flash[:failure] = "User not found"
	redirect_to  :back 
	end

		
	end
		
end
