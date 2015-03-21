class PagesController < ApplicationController

	skip_before_filter :login_required, :only => :show
	before_filter :may_maintain_pages_required, :except => :show
	before_filter :id_required, :only => [ :edit, :update, :destroy ]

	def show
		if params[:path]
 			@page = Page.by_path("/#{[params[:path]].flatten.join('/')}")
			raise ActiveRecord::RecordNotFound if @page.nil?
		else
			@page = Page.find(params[:id])
		end
		@page_title = @page.title(session[:locale])
	rescue ActiveRecord::RecordNotFound
		flash_message = "Page not found with "
#		flash_message << (( params[:id].blank? ) ? "path '/#{params[:path].join('/')}'" : "ID #{params[:id]}")
		flash_message << (( params[:id].blank? ) ? "path '/#{[params[:path]].flatten.join('/')}'" : "ID #{params[:id]}")
		flash.now[:error] = flash_message
	end

	def order
		if params[:pages] && params[:pages].is_a?(Array)
			params[:pages].each_with_index { |id,index| 
				Page.find(id).update_column(:position, index+1 ) }
		else
			flash[:error] = "No page order given!"
		end
		redirect_to pages_path(:parent_id=>params[:parent_id])
	end

	def all
		@page_title = "All CCLS Pages"
		@pages = Page.order('parent_id, position')
	end

	def index
		@page_title = "CCLS Pages"
		params[:parent_id] = nil if params[:parent_id].blank?
		@pages = Page.where(:parent_id => params[:parent_id]).order('parent_id, position')
	end

	def new
		@page_title = "Create New CCLS Page"
		@page = Page.new(:parent_id => params[:parent_id])
	end

	def edit
		@page_title = "Edit CCLS Page #{@page.title(session[:locale])}"
	end

	def create
		@page = Page.new(page_params)
		@page.save!
		flash[:notice] = 'Page was successfully created.'
		redirect_to(@page)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "There was a problem creating the page"
		render :action => "new"
	end

	def update
		@page.update_attributes!(page_params)
		flash[:notice] = 'Page was successfully updated.'
		redirect_to(@page)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "There was a problem updating the page."
		render :action => "edit"
	end

	def destroy
		@page.destroy
		redirect_to(pages_path)
	end

protected

	def id_required
		if !params[:id].blank? and Page.exists?(params[:id])
			@page = Page.find(params[:id])
		else
			access_denied("Valid page id required!", pages_path)
		end
	end

	def page_params
		params.require(:page).permit(:parent_id,:hide_menu,:path,:title_en,:menu_en,:body_en)
	end

end
