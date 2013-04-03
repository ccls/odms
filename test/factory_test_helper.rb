module FactoryTestHelper

	#	
	#	If these aren't defined, autotest can hang indefinitely
	#	and you won't know why.
	#
	#	I think that there is a way to tell Factory Girl to use
	#	"save" instead of "save!" which would have removed the
	#	need for this MOSTLY.  There are a few exceptions.
	FactoryGirl.factories.collect(&:name).each do |object|
		#
		#	define a method that is commonly used in these class level tests
		#	I'd actually prefer to not do this, but is very helpful.
		#
		define_method "create_#{object}" do |*args|
			options = args.extract_options!
			new_object = FactoryGirl.build(object,options)
			new_object.save
			new_object
		end
	end

end
ActiveSupport::TestCase.send(:include, FactoryTestHelper)
