class ContextDataSource < ActiveRecord::Base
	belongs_to :context
	belongs_to :data_source
end
