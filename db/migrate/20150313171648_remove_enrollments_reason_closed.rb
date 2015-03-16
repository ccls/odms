class RemoveEnrollmentsReasonClosed < ActiveRecord::Migration
  def self.up	
		remove_column :enrollments, :reason_closed
  end
  def self.down
		add_column :enrollments, :reason_closed, :string
  end
end
