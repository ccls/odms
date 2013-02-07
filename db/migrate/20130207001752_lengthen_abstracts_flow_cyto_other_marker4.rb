class LengthenAbstractsFlowCytoOtherMarker4 < ActiveRecord::Migration
	def up
		change_column :abstracts, :flow_cyto_other_marker_4, :string, :limit => 5
	end

	def down
		change_column :abstracts, :flow_cyto_other_marker_4, :string, :limit => 4
	end
end
