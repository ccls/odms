class OdmsException < ActiveRecord::Base

	belongs_to :exceptable, :polymorphic => true

	def to_s
		"#{name}:#{description}"
	end

end
