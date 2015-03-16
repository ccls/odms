class RemoveEnrollmentsPosition < ActiveRecord::Migration
  def self.up
		remove_column :enrollments, :position
  end
  def self.down
		add_column :enrollments, :position, :integer
  end
end
