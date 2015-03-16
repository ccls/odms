class RemoveEnrollmentsIsClosed < ActiveRecord::Migration
  def self.up
		remove_column :enrollments, :is_closed
  end
  def self.down
		add_column :enrollments, :is_closed, :boolean
  end
end
