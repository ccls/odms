class RemoveEnrollmentsProjectOutcome < ActiveRecord::Migration
  def self.up
		remove_column :enrollments, :project_outcome
  end
  def self.down
		add_column :enrollments, :project_outcome, :string
  end
end
