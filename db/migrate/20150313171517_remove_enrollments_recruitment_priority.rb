class RemoveEnrollmentsRecruitmentPriority < ActiveRecord::Migration
  def self.up
		remove_column :enrollments, :recruitment_priority
  end
  def self.down
		add_column :enrollments, :recruitment_priority, :string
  end
end
