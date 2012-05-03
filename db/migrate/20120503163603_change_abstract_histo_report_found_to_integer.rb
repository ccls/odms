class ChangeAbstractHistoReportFoundToInteger < ActiveRecord::Migration
	def up
		change_column :abstracts, :histo_report_found, :integer
	end

	def down
		change_column :abstracts, :histo_report_found, :string, :limit => 5
	end
end
