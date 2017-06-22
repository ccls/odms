class UploadsController < ApplicationController

	before_filter :may_administrate_required

	def new
	end
	def create
		dir = File.join(Rails.root,'uploads')
		Dir.mkdir(dir) unless Dir.exists?(dir)
		uploaded_io = params[:file]
		infilename = Time.now.strftime("%Y%m%d%H%M%S") + "-" + uploaded_io.original_filename
		filename = File.join( dir.to_s, infilename )
		File.open(filename, 'wb') do |file|
			file.write(uploaded_io.read)
		end
		flash[:notice] = "File uploaded"
		redirect_to root_path
	end
end
