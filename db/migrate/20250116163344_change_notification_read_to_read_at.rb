class ChangeNotificationReadToReadAt < ActiveRecord::Migration[8.1]
  def change
    remove_index :notifications,  %i[ user_id read created_at ], order: { read: :desc, created_at: :desc }

    change_table :notifications do |t|
      t.remove :read
      t.datetime :read_at

      t.index %i[ user_id read_at created_at ], order: { read_at: :desc, created_at: :desc }
    end
  end
end
