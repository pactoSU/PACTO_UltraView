require 'dicom'
require 'mongo'
require 'json'
include DICOM
include Mongo



MONGO_SERVER = "localhost"
MONGO_PORT = 27017
DB_NAME = "dicom"
DICOM_TABLE_NAME = "dicomFileTable"
SCP_PORT = 10000

class FileHandler
	def self.save_file(grid, dcm, transfer_syntax)
      dcm.write(grid, :transfer_syntax => transfer_syntax, :tags => dcm.to_hash)
      message = [:info, "DICOM file saved to gridfs"]
      return message
    end
	
	def self.receive_files(grid, objects, transfer_syntaxes)
      all_success = true
      successful, too_short, parse_fail, handle_fail = 0, 0, 0, 0
      total = objects.length
      message = nil
      messages = Array.new
      # Process each DICOM object:
      objects.each_index do |i|
        if objects[i].length > 8
          # Temporarily increase the log threshold to suppress messages from the DObject class:
          server_level = DICOM.logger.level
          DICOM.logger.level = Logger::FATAL
          # Parse the received data string and load it to a DICOM object:
          dcm = DObject.parse(objects[i], :no_meta => true, :syntax => transfer_syntaxes[i])
          # Reset the logg threshold:
          DICOM.logger.level = server_level
          if dcm.read?
            begin
              message = self.save_file(grid, dcm, transfer_syntaxes[i])
              successful += 1
            rescue
              handle_fail += 1
              all_success = false
              messages << [:error, "Saving file failed!"]
            end
          else
            parse_fail += 1
            all_success = false
            messages << [:error, "Invalid DICOM data encountered: The received string was not parsed successfully."]
          end
        else
          too_short += 1
          all_success = false
          messages << [:error, "Invalid data encountered: The received string was too small to contain any DICOM data."]
        end
      end
      # Create a summary status message, when multiple files have been received:
      if total > 1
        if successful == total
          messages << [:info, "All #{total} DICOM files received successfully."]
        else
          if successful == 0
            messages << [:warn, "All #{total} received DICOM files failed!"]
          else
            messages << [:warn, "Only #{successful} of #{total} DICOM files received successfully!"]
          end
        end
      else
        messages = [message] if all_success
      end
      return all_success, messages
    end
end

class Parent
	def write_elements(options={})
	  @file = options[:grid]
      # Go ahead and write if the file was opened successfully:
      if @file
        # Initiate necessary variables:
        @transfer_syntax = options[:syntax]
        # Until a DICOM write has completed successfully the status is 'unsuccessful':
        @write_success = false
        # Default explicitness of start of DICOM file:
        @explicit = true
        # Default endianness of start of DICOM files (little endian):
        @str_endian = false
        # When the file switch from group 0002 to a later group we will update encoding values, and this switch will keep track of that:
        @switched = false
        # Items contained under the Pixel Data element needs some special attention to write correctly:
        @enc_image = false
        # Create a Stream instance to handle the encoding of content to a binary string:
        @stream = Stream.new(nil, @str_endian)
        # Tell the Stream instance which file to write to:
        @stream.set_file(@file)
        # Write the DICOM signature:
        write_signature if options[:signature]
        write_data_elements(children)
		
		@stream.write()
        # Mark this write session as successful:
        @write_success = true
      end
    end
	
	def add_encoded(string)
        # Are we writing to a single (big) string, or multiple (smaller) strings?
        unless @segments
          @stream.add_last(string)
        else
          # As the encoded DICOM string will be cut in multiple, smaller pieces, we need to monitor the length of our encoded strings:
          if (string.length + @stream.length) > @max_size
            # Duplicate the string as not to ruin the binary of the data element with our slicing:
            segment = string.dup
            append = segment.slice!(0, @max_size-@stream.length)
            # Join these strings together and add them to the segments:
            @segments << @stream.export + append
            if (30 + segment.length) > @max_size
              # The remaining part of the string is bigger than the max limit, fill up more segments:
              # How many full segments will this string fill?
              number = (segment.length/@max_size.to_f).floor
              number.times {@segments << segment.slice!(0, @max_size)}
              # The remaining part is added to the stream:
              @stream.add_last(segment)
            else
              # The rest of the string is small enough that it can be added to the stream:
              @stream.add_last(segment)
            end
          elsif (30 + @stream.length) > @max_size
            # End the current segment, and start on a new segment for this string.
            @segments << @stream.export
            @stream.add_last(string)
          else
            # We are nowhere near the limit, simply add the string:
            @stream.add_last(string)
          end
        end
      end
	  
	def write_signature
      # Write the string "DICM" which along with the empty bytes that
      # will be put before it, identifies this as a valid DICOM file:
      identifier = @stream.encode("DICM", "STR")
      # Fill in 128 empty bytes:
      filler = @stream.encode("00"*128, "HEX")
      @stream.add_last(filler)
      @stream.add_last(identifier)
    end
end

class Stream
	def write()
			meta = @file[1].merge({:filename => "A dicom file"})
      @file[0].put(@string, meta) #@file is now a gridfs object
    end
end

class DObject
	def write(grid, options={})
      #raise ArgumentError, "Invalid file_name. Expected String, got #{file_name.class}." unless file_name.is_a?(String)
      @include_empty_parents = options[:include_empty_parents]
      insert_missing_meta unless options[:ignore_meta]
      write_elements(:grid => [grid, options[:tags]], :signature => true, :syntax => transfer_syntax)
    end
end

	
db = MongoClient.new(MONGO_SERVER, MONGO_PORT).db(DB_NAME)
grid = Grid.new(db)
dicomServer = DServer.new(SCP_PORT)
dicomServer.start_scp(grid)



	
