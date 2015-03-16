class RemoveIneligibleReasonIneligibleContext < ActiveRecord::Migration
  def self.up
		remove_column :ineligible_reasons, :ineligible_context
  end
  def self.down
		add_column :ineligible_reasons, :ineligible_context, :string
  end
end
