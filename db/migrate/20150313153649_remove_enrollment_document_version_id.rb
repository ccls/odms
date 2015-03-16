class RemoveEnrollmentDocumentVersionId < ActiveRecord::Migration
  def self.up
		remove_column :enrollments, :document_version_id
  end
  def self.down
		add_column :enrollments, :document_version_id, :integer
  end
end
