class CreateContextContextables < ActiveRecord::Migration
	def change
		create_table :context_contextables do |t|
			t.integer :context_id
			t.integer :contextable_id
			t.string :contextable_type
			t.timestamps
		end
		add_index :context_contextables, [:context_id,
			:contextable_id, :contextable_type ],:unique => true,:name => 'ccc'
	end
end
