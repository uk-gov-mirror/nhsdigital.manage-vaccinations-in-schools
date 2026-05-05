# frozen_string_literal: true

class AddVaccsHistoryAlphaParentalConsentToPatient < ActiveRecord::Migration[
  8.1
]
  def change
    add_column :patients,
               :vaccs_history_alpha_parental_consent,
               :boolean,
               default: false,
               null: false
  end
end
