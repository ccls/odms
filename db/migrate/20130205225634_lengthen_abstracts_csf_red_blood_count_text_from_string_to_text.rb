class LengthenAbstractsCsfRedBloodCountTextFromStringToText < ActiveRecord::Migration
	def up
		change_column :abstracts, :csf_red_blood_count_text, :text
	end

	def down
		change_column :abstracts, :csf_red_blood_count_text, :string
	end
end
