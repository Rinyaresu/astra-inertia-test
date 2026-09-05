class AddEventIdToXpEntries < ActiveRecord::Migration[8.1]
  def up
    add_column :xp_entries, :event_id, :string
    execute("UPDATE xp_entries SET event_id = lower(hex(randomblob(16))) WHERE event_id IS NULL")
    change_column_null :xp_entries, :event_id, false
    add_index :xp_entries, :event_id, unique: true
  end

  def down
    remove_index :xp_entries, :event_id
    remove_column :xp_entries, :event_id
  end
end
