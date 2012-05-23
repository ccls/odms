class OdmsExceptionExceptable < ActiveRecord::Base
  attr_accessible :exceptable_id, :exceptable_type, :odms_exception_id

	belongs_to :odms_exception
	belongs_to :exceptable, :polymorphic => true
end
