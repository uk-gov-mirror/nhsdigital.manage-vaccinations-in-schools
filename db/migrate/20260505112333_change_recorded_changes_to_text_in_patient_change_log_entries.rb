# frozen_string_literal: true

class ChangeRecordedChangesToTextInPatientChangeLogEntries < ActiveRecord::Migration[
  8.1
]
  def up
    change_column :patient_change_log_entries,
                  :recorded_changes,
                  :text,
                  null: false,
                  default: "{}"
  end

  def down
    change_column :patient_change_log_entries,
                  :recorded_changes,
                  :jsonb,
                  null: false,
                  default: {
                  }
  end
end
