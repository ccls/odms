class OdmsException < ActiveRecord::Base

	has_many :odms_exception_exceptables

	def to_s
		"#{name}:#{description}"
	end

	def exceptables
		odms_exception_exceptables.collect(&:exceptable)
	end

end
