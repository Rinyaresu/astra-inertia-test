class CreatePdiCore < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :purpose
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, null: false, default: "active"
      t.timestamps
    end

    create_table :goals do |t|
      t.references :plan, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.date :due_date
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :tasks do |t|
      t.references :goal, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :completed_at
      t.timestamps
    end

    create_table :check_ins do |t|
      t.references :plan, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :reflection, null: false
      t.date :checked_in_on, null: false
      t.timestamps
    end

    create_table :xp_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true
      t.integer :points, null: false
      t.string :kind, null: false
      t.string :signature, null: false
      t.timestamps
    end
    add_index :xp_entries, :signature, unique: true

    create_table :exports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "queued"
      t.string :file_path
      t.string :error_message
      t.timestamps
    end
  end
end
