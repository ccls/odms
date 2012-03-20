module ActiveRecordExtension; end
module ActiveRecordExtension::Base

	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods

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

		def random
			count = count()
			if count > 0
				first(:offset => rand(count))
			else
				nil
			end
		end

	end

end	#	module ActiveRecordExtension::Base
ActiveRecord::Base.send(:include, ActiveRecordExtension::Base)
