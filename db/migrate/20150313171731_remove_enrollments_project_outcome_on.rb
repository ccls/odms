class RemoveEnrollmentsProjectOutcomeOn < ActiveRecord::Migration
  def self.up
		remove_column :enrollments, :project_outcome_on
  end
  def self.down
		add_column :enrollments, :project_outcome_on, :date
  end
end
