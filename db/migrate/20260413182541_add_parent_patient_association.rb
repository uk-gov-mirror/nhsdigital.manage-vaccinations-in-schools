# frozen_string_literal: true

class AddParentPatientAssociation < ActiveRecord::Migration[8.1]
  def change
    create_enum "parent_relationship_type",
                %w[father guardian mother other unknown]

    change_table :parents do |t|
      t.references :patient, null: true, foreign_key: true
      t.enum :type, enum_type: :parent_relationship_type, null: true
      t.string :other_name, null: true
    end
  end
end
