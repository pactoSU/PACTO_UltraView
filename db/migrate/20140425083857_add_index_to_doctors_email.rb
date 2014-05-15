class AddIndexToDoctorsEmail < ActiveRecord::Migration
  def change
  	add_index :doctors, :email, unique: true
  end
end
