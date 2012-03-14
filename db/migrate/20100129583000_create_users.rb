class CreateUsers < ActiveRecord::Migration
	def self.up
		create_table :users do |t|
			t.string :uid
			t.string :sn
			t.string :displayname
			t.string :mail	#, :default => '', :null => false	#	why is mail '' and non-null?
			t.string :telephonenumber
			t.timestamps
		end
		add_index :users, :uid, :unique => true
		add_index :users, :sn
	end

	def self.down
		drop_table :users
	end
end
