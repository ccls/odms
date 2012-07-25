class ActiveRecord::Base

	#
	#	I have found that the validations are really cluttering up the models.
	#	Moving them into a yml file and pulling them in like so seems to 
	#	be working well.
	#
	#	Not all validations are going to work, but so far so good.
	#
	def self.validations_from_yaml_file
		validation_file = File.join(Rails.root,"config/validations/#{self.to_s.underscore}.yml")
		if File.exists?(validation_file)
#			puts "Adding validations for #{self} from #{validation_file}"
			h = YAML::load( ERB.new( IO.read( validation_file )).result)
#			puts h.inspect

			h.each do |validation|
#				attributes = validation.delete(:attributes)
				attributes=[validation.delete(:attributes), validation.delete(:attribute)
					].compact.flatten
				self.validates *attributes, validation
			end
#		else
#			puts "YAML validations file not found so not using."
		end
	end

	def self.validates_uniqueness_of_with_nilification(*args)
		#	NOTE ANY field that has a unique index in the database NEEDS
		#	to NOT be blank.  Multiple nils are acceptable in index, 
		#	but multiple blanks are NOT.  Nilify ALL fields with
		#	unique indexes in the database. At least those that
		#	would appear on a form, as an empty text box is sent
		#	as '' and not nil, hence the initial problem.
		#	The first one will work, but will fail after.

		#	ONLY IF THE FIELD IS A STRING!
		class_eval do
			validates_uniqueness_of args, :allow_blank => true
			args.each do |arg|
				before_validation {
					self.send("#{arg}=", nil) if self.send(arg).blank?
				}
			end
		end
	end

	def self.acts_like_a_hash(*args)
		options = {
			:key   => :key,
			:value => :description
		}.update(args.extract_options!)

		#	I guess we must explicitly remember the options
		#	so that can reference the 'key' in []
#		@@acts_like_a_hash_options = options
#		@@acts_like_a_hash_memory  = {}
#
#	Using @@ seems to share the variable in ActiveRecord::Base
#	Using cattr_accessor seems to share it in the subclass
#
		cattr_accessor :acts_like_a_hash_options
		cattr_accessor :acts_like_a_hash_memory

		class_eval do

			self.acts_like_a_hash_options = options
			self.acts_like_a_hash_memory = {}
	
			validates_presence_of   options[:key], options[:value]
			validates_uniqueness_of options[:key], options[:value]
			validates_length_of     options[:key], options[:value],
				:maximum => 250, :allow_blank => true

			# Treats the class a bit like a Hash and
			# searches for a record with a matching key.
			def self.[](key)
				# may need to deal with options[:key] here, but not needed yet
#				find_by_key(key.to_s)
#				where(@@acts_like_a_hash_options[:key] => key.to_s).first

				#	adding a type of memoization
#
#	THIS IS MEMORIZING ACROSS SUBCLASSES!!!
#	THIS MEANS THAT THE *_options IS PROBABLY DOING THE SAME THING!
#
#				@@acts_like_a_hash_memory[key] ||=
				self.acts_like_a_hash_memory[key.downcase.to_s] ||=
#		Is having the table name excessive? This isn't used in joins
#		so shouldn't be ambiguous column name.
#					where("#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(self.acts_like_a_hash_options[:key])} LIKE ?", key.to_s).first
					where("#{connection.quote_column_name(self.acts_like_a_hash_options[:key])} LIKE ?", key.to_s).first
#					where("`#{self.acts_like_a_hash_options[:key]}` LIKE ?", key.to_s).first
#	sqlite is case sensitive, but LIKE desensitizes it
#	mysql DOES NOT LIKE the LIKE.  Actually seems to not like
#		the unquoted key???? so I quoted it with ``
#				self.acts_like_a_hash_memory[key.downcase.to_s] ||=
#					where(self.acts_like_a_hash_options[:key] => key.to_s).first
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
