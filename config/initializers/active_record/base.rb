class ActiveRecord::Base

	def self.acts_like_a_hash(*args)
		options = {
			:key   => :key,
			:value => :description
		}.update(args.extract_options!)

		#	I guess we must explicitly remember the options
		#	so that can reference the 'key' in []
		@@acts_like_a_hash_options = options

		class_eval do

			validates_presence_of   options[:key], options[:value]
			validates_uniqueness_of options[:key], options[:value]
			validates_length_of     options[:key], options[:value],
				:maximum => 250, :allow_blank => true

			# Treats the class a bit like a Hash and
			# searches for a record with a matching key.
			def self.[](key)
				# may need to deal with options[:key] here, but not needed yet
#				find_by_key(key.to_s)
				where(@@acts_like_a_hash_options[:key] => key.to_s).first
			end

#NameError: undefined local variable or method `options' for #<Class:0x107229540>
#class << self
#			define_method "[]" do |key|
#				where(options[:key] => key.to_s)
#			end
#end

		end	#	class_eval do
	end	#	def acts_like_a_hash(*args)

	def self.random
		count = count()
		if count > 0
#			first(:offset => rand(count))
			offset(rand(count)).limit(1).first
		else
			nil
		end
	end

end	#	class ActiveRecord::Base
