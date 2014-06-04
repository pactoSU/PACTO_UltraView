require 'mongo'

include Mongo

MONGO_SERVER = "localhost"
MONGO_PORT = 27017
DB_NAME = "dicom"
DICOM_TABLE_NAME = "dicomFileTable"
SCP_PORT = 10000


DAYS = 20
SECONDS_PER_HOUR = 60 * 60
SECONDS_PER_DAY = SECONDS_PER_HOUR * 24
db = MongoClient.new(MONGO_SERVER, MONGO_PORT).db(DB_NAME)


loop do
  sleep(60)
  time = Time.now
  deleteDate = (time - (60))
  db["fs.files"].remove({"insertTime"=> {"$lt"=> deleteDate} })
  puts "delete"
end