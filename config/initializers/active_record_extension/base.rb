module ActiveRecordExtension; end
module ActiveRecordExtension::Base

	def self.included(base)
#		base.send(:include, InstanceMethods)
		base.extend(ClassMethods)
	end

	module ClassMethods

#	api says this is deprecated as of 2.3.8, but is in ActiveModel????
#
        def validation_method(on)
          case on
            when :save   then :validate
            when :create then :validate_on_create
            when :update then :validate_on_update
          end
        end

		def acts_like_a_hash(*args)
			options = {
				:key   => :key,
				:value => :description
			}.update(args.extract_options!)

			class_eval do

				validates_presence_of   options[:key], options[:value]
				validates_uniqueness_of options[:key], options[:value]
				validates_length_of     options[:key], options[:value],
					:maximum => 250, :allow_blank => true

				# Treats the class a bit like a Hash and
				# searches for a record with a matching key.
				def self.[](key)
					# may need to deal with options[:key] here, but not needed yet
					find_by_key(key.to_s)
				end

			end	#	class_eval do
		end	#	def acts_like_a_hash(*args)


#		#
#		#	Create virtual attribute accessors for datetime parts,
#		#		year, month, day, hour, minute for use by 
#		#		view selectors and model validations?
#		#
#		#	If this all works, may want to separate it out.
#		#
#		def datetime_accessors_for(*args)
#			options = { 
#			}.update(args.extract_options!)
#			args.each do |field|
#
##				What if there is no 'field'?  Typo?
#
##				When to actually compile the 'field'
#
##				define instance variable "#{field}_year"
#
#				define_method "#{field}_year" do
#					#	return the instance variable? or pull it from 'field'?
#				end
#
#				define_method "#{field}_year=" do |new_year|
#					#	just set the instance variable?
#				end
#
#			end
#		end	#	def datetime_accessors_for(*args)


		def random
			count = count()
			if count > 0
				first(:offset => rand(count))
			else
				nil
			end
		end

		def validates_absence_of(*attr_names)
			configuration = { :on => :save,
				:message => "is present and must be absent." }
			configuration.update(attr_names.extract_options!)

			send(validation_method(configuration[:on]), configuration) do |record|
				attr_names.each do |attr_name|
					unless record.send(attr_name).blank?
#
#	No longer an ActiveRecord::Error class
#		just an attribute and message I guess?
#	    errors.add(:name, "can not be nil")
#
						record.errors.add(attr_name, 
							ActiveRecord::Error.new(record,attr_name,:present,
								{ :message => configuration[:message] }))
					end
				end
			end
		end

		def validates_past_date_for(*attr_names)
			configuration = { :on => :save,
				:allow_today => true,
				:message => "is in the future and must be in the past." }
			configuration.update(attr_names.extract_options!)

			send(validation_method(configuration[:on]), configuration) do |record|
				attr_names.each do |attr_name|
					#	ensure that it is a date and not datetime
					#	in some tests, this is actually set to a datetime (5.years.ago), and need a date for comparison
					#	in some tests, it is nil, so need a try
					date = record.send(attr_name).try(:to_date)

#	When tests run late at night, this fails because of timezones I imagine.
#	However, using Date.today as opposed to Time.now seems to work.
#	Don't know why I ever used Time.now.  Probably because the incoming date could be a datetime.
#	May need to actually call to_date on the incoming 'date' just to be sure.
#	This is just wrong.  Logically, one would expect it to be true, but is not most likely due to time zone conversion.
#	>> Time.now < Date.tomorrow
#	=> false
#	This does work, however, but Time.now.to_date seems to be the same as Date.today
#	>> Time.now.to_date < Date.tomorrow
#	=> true
#
#	>> Time.now
#	=> Fri Dec 02 22:57:34 -0800 2011
#	>> Date.today
#	=> Fri, 02 Dec 2011
#	>> Time.now < Date.yesterday
#	=> false
#	>> Time.now < Date.tomorrow
#	=> false
#	>> Time.now < Date.today
#	=> false
#	>> Date.today < Date.yesterday
#	=> false
#	>> Date.today < Date.tomorrow
#	=> true
#	>> Date.today < Date.today
#	=> false
#					if !date.blank? && Time.now < date


					base_date = if configuration[:allow_today]
						Date.today
					else
						Date.yesterday
					end
#	actually, this allows today by default
#					if !date.blank? && Date.today < date
					if !date.blank? && base_date < date
#
#	No longer an ActiveRecord::Error class
#		just an attribute and message I guess?
#	    errors.add(:name, "can not be nil")
#
						record.errors.add(attr_name, 
							ActiveRecord::Error.new(record,attr_name,:not_past_date,
								{ :message => configuration[:message] }))
					end
				end
			end
		end

		#	This doesn't work as one would expect if the column
		#	is a DateTime instead of just a Date.
		#	For some reason, *_before_type_cast actually
		#	returns a parsed DateTime?
		def validates_complete_date_for(*attr_names)
			configuration = { :on => :save,
				:message => "is not a complete date." }
			configuration.update(attr_names.extract_options!)

			send(validation_method(configuration[:on]), configuration) do |record|
				attr_names.each do |attr_name|

					value = record.send("#{attr_name}_before_type_cast")
					unless( configuration[:allow_nil] && value.blank? ) ||
						( !value.is_a?(String) )
						date_hash = Date._parse(value)
						#	>> Date._parse( '1/10/2011')
						#	=> {:mon=>1, :year=>2011, :mday=>10}
						unless date_hash.has_key?(:year) &&
							date_hash.has_key?(:mon) &&
							date_hash.has_key?(:mday)
#
#	No longer an ActiveRecord::Error class
#		just an attribute and message I guess?
#	    errors.add(:name, "can not be nil")
#
							record.errors.add(attr_name, 
								ActiveRecord::Error.new(record,attr_name,:not_complete_date,
									{ :message => configuration[:message] }))
						end
					end
				end
			end
		end

	end

end	#	module ActiveRecordExtension::Base
ActiveRecord::Base.send(:include, ActiveRecordExtension::Base)
