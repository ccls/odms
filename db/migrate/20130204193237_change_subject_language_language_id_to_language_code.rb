class ChangeSubjectLanguageLanguageIdToLanguageCode < ActiveRecord::Migration
  def change
		rename_column :subject_languages, :language_id, :language_code
  end
end
