class ScreeningDatumUpdatesController < ApplicationController
#  # GET /screening_datum_updates
#  # GET /screening_datum_updates.json
#  def index
#    @screening_datum_updates = ScreeningDatumUpdate.all
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.json { render json: @screening_datum_updates }
#    end
#  end
#
#  # GET /screening_datum_updates/1
#  # GET /screening_datum_updates/1.json
#  def show
#    @screening_datum_update = ScreeningDatumUpdate.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.json { render json: @screening_datum_update }
#    end
#  end
#
#  # GET /screening_datum_updates/new
#  # GET /screening_datum_updates/new.json
#  def new
#    @screening_datum_update = ScreeningDatumUpdate.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.json { render json: @screening_datum_update }
#    end
#  end
#
#  # GET /screening_datum_updates/1/edit
#  def edit
#    @screening_datum_update = ScreeningDatumUpdate.find(params[:id])
#  end
#
#  # POST /screening_datum_updates
#  # POST /screening_datum_updates.json
#  def create
#    @screening_datum_update = ScreeningDatumUpdate.new(params[:screening_datum_update])
#
#    respond_to do |format|
#      if @screening_datum_update.save
#        format.html { redirect_to @screening_datum_update, notice: 'Screening datum update was successfully created.' }
#        format.json { render json: @screening_datum_update, status: :created, location: @screening_datum_update }
#      else
#        format.html { render action: "new" }
#        format.json { render json: @screening_datum_update.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  # PUT /screening_datum_updates/1
#  # PUT /screening_datum_updates/1.json
#  def update
#    @screening_datum_update = ScreeningDatumUpdate.find(params[:id])
#
#    respond_to do |format|
#      if @screening_datum_update.update_attributes(params[:screening_datum_update])
#        format.html { redirect_to @screening_datum_update, notice: 'Screening datum update was successfully updated.' }
#        format.json { head :no_content }
#      else
#        format.html { render action: "edit" }
#        format.json { render json: @screening_datum_update.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  # DELETE /screening_datum_updates/1
#  # DELETE /screening_datum_updates/1.json
#  def destroy
#    @screening_datum_update = ScreeningDatumUpdate.find(params[:id])
#    @screening_datum_update.destroy
#
#    respond_to do |format|
#      format.html { redirect_to screening_datum_updates_url }
#      format.json { head :no_content }
#    end
#  end
end
