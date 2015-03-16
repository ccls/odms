class RemoveSamplesFutureUseProhibited < ActiveRecord::Migration
  def self.up
		remove_column :samples, :future_use_prohibited
  end
  def self.down
		add_column :samples, :future_use_prohibited, :boolean, :default => false, :null => false
  end
end
