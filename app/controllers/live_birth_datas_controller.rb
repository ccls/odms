class LiveBirthDatasController < ApplicationController
#	# GET /live_birth_datas
#	# GET /live_birth_datas.xml
#	def index
#		@live_birth_datas = LiveBirthData.all
#
#		respond_to do |format|
#			format.html # index.html.erb
#			format.xml	{ render :xml => @live_birth_datas }
#		end
#	end
#
#	# GET /live_birth_datas/1
#	# GET /live_birth_datas/1.xml
#	def show
#		@live_birth_data = LiveBirthData.find(params[:id])
#
#		respond_to do |format|
#			format.html # show.html.erb
#			format.xml	{ render :xml => @live_birth_data }
#		end
#	end
#
#	# GET /live_birth_datas/new
#	# GET /live_birth_datas/new.xml
#	def new
#		@live_birth_data = LiveBirthData.new
#
#		respond_to do |format|
#			format.html # new.html.erb
#			format.xml	{ render :xml => @live_birth_data }
#		end
#	end
#
#	# GET /live_birth_datas/1/edit
#	def edit
#		@live_birth_data = LiveBirthData.find(params[:id])
#	end
#
#	# POST /live_birth_datas
#	# POST /live_birth_datas.xml
#	def create
#		@live_birth_data = LiveBirthData.new(params[:live_birth_data])
#
#		respond_to do |format|
#			if @live_birth_data.save
#				format.html { redirect_to(@live_birth_data, :notice => 'LiveBirthData was successfully created.') }
#				format.xml	{ render :xml => @live_birth_data, :status => :created, :location => @live_birth_data }
#			else
#				format.html { render :action => "new" }
#				format.xml	{ render :xml => @live_birth_data.errors, :status => :unprocessable_entity }
#			end
#		end
#	end
#
#	# PUT /live_birth_datas/1
#	# PUT /live_birth_datas/1.xml
#	def update
#		@live_birth_data = LiveBirthData.find(params[:id])
#
#		respond_to do |format|
#			if @live_birth_data.update_attributes(params[:live_birth_data])
#				format.html { redirect_to(@live_birth_data, :notice => 'LiveBirthData was successfully updated.') }
#				format.xml	{ head :ok }
#			else
#				format.html { render :action => "edit" }
#				format.xml	{ render :xml => @live_birth_data.errors, :status => :unprocessable_entity }
#			end
#		end
#	end
#
#	# DELETE /live_birth_datas/1
#	# DELETE /live_birth_datas/1.xml
#	def destroy
#		@live_birth_data = LiveBirthData.find(params[:id])
#		@live_birth_data.destroy
#
#		respond_to do |format|
#			format.html { redirect_to(live_birth_datas_url) }
#			format.xml	{ head :ok }
#		end
#	end
end
