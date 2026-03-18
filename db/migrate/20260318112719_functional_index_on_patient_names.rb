# frozen_string_literal: true

class FunctionalIndexOnPatientNames < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :patients,
              "lower(given_name), lower(family_name), date_of_birth, address_postcode",
              name: "index_patients_on_lower_names_given_first_dob_address",
              algorithm: :concurrently
    add_index :patients,
              "lower(family_name), lower(given_name), address_postcode",
              name: "index_patients_on_lower_names_family_first_address",
              algorithm: :concurrently
    add_index :patients,
              "date_of_birth, address_postcode, lower(family_name)",
              name: "index_patients_on_lower_family_name_dob_address",
              algorithm: :concurrently
    add_index :patients,
              "address_postcode, date_of_birth, lower(given_name)",
              name: "index_patients_on_lower_given_name_dob_address",
              algorithm: :concurrently
  end
end
