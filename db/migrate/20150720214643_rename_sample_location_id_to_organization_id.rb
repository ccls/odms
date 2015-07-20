class RenameSampleLocationIdToOrganizationId < ActiveRecord::Migration
  def change
		rename_column :samples, :location_id, :organization_id
  end
end
