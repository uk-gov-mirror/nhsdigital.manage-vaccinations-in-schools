# frozen_string_literal: true

# Creates join records between an import and the records created for it as part
# of the import process, e.g. +Patient+, +Parent+, +VaccinationRecord+, etc,
# records.
#
# This module is intended to be used as a small service object:
#
#   Imports::JoinRecords.call(import, records)
#
# It determines:
# - +import_type+ from +import.class.name+ (e.g. +ClassImport+, +CohortImport+)
# - +records_type+ either from +records_type:+ (if provided) or by inferring
#   from +records+ (all records must be the same class).
#
# The join table model is resolved in one of two ways:
# 1) If a join model constant exists (e.g. +"ClassImportsPatient"+), it is used.
# 2) Otherwise, an anonymous +ApplicationRecord+ subclass is created with:
#    - +table_name+ set to +"<import_type.tableize>_<records_type.tableize>"+,
#      for example +"class_imports_patients"+ (depending on inflections)
#    - a stable +model_name+ suitable for ActiveModel integration
#
# When calling {#call}, rows are bulk-inserted using +#import+ on the join model,
# ignoring duplicates:
# - columns: +"<records_type.underscore>_id"+ and +"<import_type.underscore>_id"+
# - values: each record id paired with the import's +id+
#
# Duplicate join rows are ignored via +on_duplicate_key_ignore: true+.
#
# @attr_reader import [ApplicationRecord] the import instance being joined
# @attr_reader import_type [String] class name of the import (e.g. "ClassImport")
# @attr_reader records [Array<ApplicationRecord>] records to be joined to the import
# @attr_reader records_type [String] class name of the records (e.g. "Patient")
module Imports
  class JoinRecords
    attr_reader :import, :import_type, :records, :records_type

    def initialize(import, records, records_type: nil)
      @import = import
      @records = records

      # e.g. ClassImport, CohortImport, ImmunisationImport
      @import_type = import.class.name

      # We don't do this sooner because it may be useful for debugging to
      # populate what we can in instances where there are no records to actually
      # operate on.
      return if records.blank?

      # e.g. Patient, Parent, ParentRelationship, VaccinationRecord
      @records_type =
        records_type&.classify || records.map(&:class).uniq.sole.name
    end

    def self.call(...) = new(...).call

    def call
      return [] if records.blank?

      join_table_class.import(
        ["#{records_type.underscore}_id", "#{import_type.underscore}_id"],
        records.map(&:id).product([import.id]).uniq,
        on_duplicate_key_ignore: true
      )
    end

    private

    # Resolve (or generate) the ActiveRecord model representing the join table.
    #
    # @return [Class<ApplicationRecord>] join model class
    def join_table_class
      join_table_name = "#{import_type.pluralize}#{records_type}"
      outer_import_type = @import_type
      outer_records_type = @records_type

      join_table_name.safe_constantize ||
        Class.new(ApplicationRecord) do
          @import_type = outer_import_type
          @records_type = outer_records_type

          self.table_name = "#{@import_type.tableize}_#{@records_type.tableize}"

          def self.model_name
            ActiveModel::Name.new(
              self,
              nil,
              [@import_type, @records_type].sort.join
            )
          end
        end
    end
  end
end
