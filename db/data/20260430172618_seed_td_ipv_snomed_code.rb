# frozen_string_literal: true

class SeedTdIpvSnomedCode < ActiveRecord::Migration[8.1]
  def up
    Rails.logger.debug "Seeding vaccines"
    Rake::Task['vaccines:seed'].execute
    Rails.logger.debug "Seeding complete"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
