# frozen_string_literal: true

class CreateRejectedSignups < ActiveRecord::Migration[7.0]
  def change
    create_table :rejected_signups do |t|
      t.bigint :user_id
      t.bigint :reviewable_id, null: false
      t.bigint :rejected_by_id
      t.bigint :approved_later_by_id
      t.string :username, null: false
      t.string :name
      t.string :email
      t.text :reject_reason
      t.json :payload
      t.datetime :rejected_at, null: false
      t.datetime :approved_later_at
      t.timestamps
    end

    add_index :rejected_signups, :reviewable_id, unique: true
    add_index :rejected_signups, :user_id
    add_index :rejected_signups, :rejected_at
  end
end
