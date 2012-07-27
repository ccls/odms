class Sunspot::SubjectsController < SunspotController

	before_filter :may_administrate_required
	before_filter :search_method_defined_required
#	before_filter :sunspot_running_required
#
#	def sunspot_running_required
#		#	This seems excessive.  Better to let crash and deal with that.
#		Sunspot::Rails::Server.new.running? ||
#			access_denied("Sunspot server not running!", root_path)
#	end

	def search_method_defined_required
#undefined method `search' for #<Class:0x0000010117da70>
#		StudySubject.method_exists?('search') ||
#undefined method `method_exists?' for #<Class:0x0000010117da70>
#	interesting.  method_exists? works in the console.
#
#	This is effectively caused by me not calling searchable
#	if the sunspot server isn't running as would fail then.
#
		StudySubject.methods.include?(:search) ||
			access_denied("Sunspot server probably wasn't started first!", root_path)
	end

	def index
		@search = StudySubject.search do
#			keywords params[:q]	#	searches names and all the id numbers
#	date :reference_date
#	date :dob
#	date :died_on
#	integer :birth_year 

			all_facets.each do |p|
#				if child_age_facets.include?(p)
#					range_facet_and_filter_for(p,params.dup,:start => 1, :step => 2)
#				elsif parent_age_facets.include?(p)
#					range_facet_and_filter_for(p,params.dup)
#				elsif year_facets.include?(p)
#					range_facet_and_filter_for(p,params.dup,{:start => 1980, :stop => 2010, :step => 5})
#				else
					if params[p]
						params[p] = params[p].dup.reject{|x|x.blank?}
						if params[p+'_op'] && params[p+'_op']=='AND'
							unless params[p].empty?
								with(p).all_of params[p]
							else
								params.delete(p)	#	remove the key so doesn't show in view
							end
						else
							unless params[p].empty?
								with(p).any_of params[p]
							else
								params.delete(p)	#	remove the key so doesn't show in view
							end
						end
					end
#				end
				facet p.to_sym, :sort => :index
			end

#			order_by :created_at, :asc
			order_by *search_order


##dynamic(:enrollments){ 
##	facet :project
##	with( :project, params['enrollments:project'] ) if params['enrollments:project'].present?
##	facet :is_eligible
##	with( :is_eligible, params['enrollments:is_eligible'] ) if params['enrollments:is_eligible'].present?
##	facet :consented
##	with( :consented, params['enrollments:consented'] ) if params['enrollments:consented'].present?
##}
#
facet(:projects)
if params[:projects].present?
	with(:projects, params[:projects]) 
	params[:projects].each do |proj|
#		namespace = "project_#{proj.downcase.gsub(/\W+/,'_')}"
#		namespace = "project_#{proj.html_friendly}"
		namespace = "hex_#{proj.to_s.unpack('H*').first}"
#
#	This ain't quite right, yet.
#
		dynamic(namespace){
			facet(:consented)
			with(:consented,params["#{namespace}:consented"]) if params["#{namespace}:consented"].present?
			facet(:is_eligible)
			with(:is_eligible,params["#{namespace}:is_eligible"]) if params["#{namespace}:is_eligible"].present?
		}
	end
end

			
			if request.format.to_s.match(/csv/)
				#	don't paginate csv file.  Only way seems to be to make BIG query
				#	rather than the arbitrarily big number, I could possibly
				#	use the @search.total from the previous search sent as param?
				paginate :per_page => 100000
			end
			paginate :page => params[:page] 
		end
	rescue Errno::ECONNREFUSED
		flash[:error] = "Solr seems to be down for the moment."
		redirect_to root_path
	end

protected

	#	all facets in order
	def all_facets
		%w( subject_type vital_status case_control_type sex phase races languages organization diagnosis )
	end

	def search_order
		if params[:order] and
				%w( id subject_type vital_status case_control_type reference_date sex dob died_on phase birth_year ).include?(
				params[:order].downcase)
			order_string = params[:order]
			dir = case params[:dir].try(:downcase)
				when 'desc' then 'desc'
				else 'asc'
			end
			return order_string.to_sym, dir.to_sym
		else
			return :id, :asc
		end
	end

end
__END__
class InventoriesController < ApplicationController
#
##	NOTE	Sunspot searching for blank facet values.
##		Searching for '' is not possible and searching for nil
##		A value that is '' will create a facet this is '', but 
##			is not searchable.  PERIOD.  There MAY be a way to do
##			this, but I have not found it.  The '' creates a 
##			search statement that is syntactically incorrect.
##		Nil, however, is searchable, but not as a value in a
##			any_of or all_of array.  It would have to be explicitly
##			parsed out of the param array and explicitly checked for.
##		Due to these restrictions, I am skipping all blank facet
##			values in the view and ignoring them in this controller
##			as a user may manually modify the url.
#
#		@search = Subject.search do
#			keywords params[:q]
#			#	undefined method `name' for "Book":String 
#			#	where Book is params[:class]
#			#	either constantize or create String#name method
#			#	both seem to make Sunspot happy
#			#			with(:class, params[:class].constantize) if params[:class]
#			#			facet :class 
#
##	This isn't really a view helper, so I removed it from the helpers
##	and put it here where it is actually used.
#Sunspot::DSL::Search.class_eval do
#	#
#	#	Add options to control
#	#		under = nil   (-infinity)   boolean to flag under start???
#	#		over  = nil   (infinity)    boolean to flag over stop???
#	#		start = 20
#	#		step  = 10
#	#		end   = 50
#	#
##
##	TODO change "Under 20" to "20 and under"
##	TODO change "Over 50"  to "50 and over"
##
#	def range_facet_and_filter_for(field,params={},options={})
#		start = (options[:start] || 20).to_i
#		stop  = (options[:stop]  || 50).to_i
#		step  = (options[:step]  || 10).to_i
#		if params[field]
#			any_of do
#				params[field].each do |pp|
#					if pp =~ /^Under (\d+)$/
#						with( field.to_sym ).less_than $1     #	actually less than or equal to
#					elsif pp =~ /^Over (\d+)$/
#						with( field.to_sym ).greater_than $1  #	actually greater than or equal to
#					elsif pp =~ /^\d+\.\.\d+$/
#						with( field.to_sym, eval(pp) )
#					elsif pp =~ /^\d+$/
#						with( field.to_sym, pp )	#	primarily for testing?  No range, just value
#					end
#				end
#			end
#		end
#		facet field.to_sym do
#			#	row "text label for facet in view", block for facet.query
#			row "Under #{start}" do
#				#	Is less_than just less_than or does it also include equal_to?
#				#	Results appear to include equal_to which makes it actually incorrect and misleading.
#				with( field.to_sym ).less_than start		#	facet query to pre-show count if selected (NOT A FILTER)
#			end
#			(start..(stop-step)).step(step).each do |range|
#				row "#{range}..#{range+step}" do
#					with( field.to_sym, Range.new(range,range+step) )
#				end
#			end
#			row "Over #{stop}" do
#				#	Is greater_than just greater_than or does it also include equal_to?
#				#	Results appear to include equal_to which makes it actually incorrect and misleading.
#				with( field.to_sym ).greater_than stop
#			end
#		end
#	end
#
end
