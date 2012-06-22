class PartialAbstractController < ApplicationController

	before_filter :may_create_abstracts_required,
		:only => [:new,:create]
	before_filter :may_read_abstracts_required,
		:only => [:show,:index]
	before_filter :may_update_abstracts_required,
		:only => [:edit,:update]
	before_filter :may_destroy_abstracts_required,
		:only => :destroy

	before_filter :set_page_title
	before_filter :valid_abstract_id_required

	layout 'subject'

	def update
		@abstract.update_attributes!(params[:abstract])
		flash[:notice] = "Abstract updated"
		sections = Abstract.sections
		ci = sections.find_index{|i| i[:controller] =~ /^#{self.class.name.demodulize}$/i }
		if( params[:edit_next] && !ci.nil? && ci < ( sections.length - 1 ) )
			redirect_to send(sections[ci+1][:edit],@abstract)
		elsif( params[:edit_previous] && !ci.nil? && ci > 0 )
			redirect_to send(sections[ci-1][:edit],@abstract)
		else 
			redirect_to :action => 'show'
		end
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Abstract update failed"
		render :action => 'edit'
	end

protected

#	demodulize will remove the Abstract:: namespace prefix

	def set_page_title
		@page_title = "#{self.action_name.capitalize}: Abstract /" <<
			" #{Abstract.sections.find{|a|a[:controller] == self.class.name.demodulize}[:label]}"
	end

	def valid_abstract_id_required
		if !params[:abstract_id].blank? and Abstract.exists?(params[:abstract_id])
			@abstract = Abstract.find(params[:abstract_id])
			@study_subject = @abstract.study_subject
		else
			access_denied("Valid abstract id required!", 
				abstracts_path)
		end
	end

end
