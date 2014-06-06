class AdminController < ApplicationController
require 'async.rb'

  def index
	AsyncTask.new.run
	end


end