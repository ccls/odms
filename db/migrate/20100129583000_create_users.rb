class CreateUsers < ActiveRecord::Migration
	def self.up
		table_name = 'users'
		create_table :users do |t|
			t.string :uid
			t.string :sn
			t.string :displayname
			t.string :mail, :default => '', :null => false
			t.string :telephonenumber
			t.timestamps
		end
		add_index :users, :uid, :unique => true
		add_index :users, :sn, :unique => true
	end

	def self.down
		drop_table :users
	end
end
