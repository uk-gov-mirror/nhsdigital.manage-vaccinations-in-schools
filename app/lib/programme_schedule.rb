# frozen_string_literal: true

class ProgrammeSchedule
  TWELVE_MONTHS = { months: 12 }.freeze
  EIGHTEEN_MONTHS = { months: 18 }.freeze
  THREE_YEARS_FOUR_MONTHS = { years: 3, months: 4 }.freeze

  Dose =
    Struct.new(
      :dose_sequence,
      :vaccine_type,
      :age_offset,
      :scheduled_date,
      keyword_init: true
    )

  Schedule = Struct.new(:programme_type, :doses, keyword_init: true)

  DoseDefinition =
    Struct.new(:dose_sequence, :vaccine_type, :age_offset, keyword_init: true)

  CohortDefinition =
    Struct.new(:from, :to, :doses, keyword_init: true) do
      def covers?(date_of_birth)
        return false if from && date_of_birth < from
        return false if to && date_of_birth > to

        true
      end
    end

  class << self
    def call(...) = new(...).call

    def dose(dose_sequence, vaccine_type, age_offset)
      DoseDefinition.new(dose_sequence:, vaccine_type:, age_offset:)
    end

    def cohort(doses:, from: nil, to: nil)
      CohortDefinition.new(from:, to:, doses:)
    end

    private :dose, :cohort
  end

  PROGRAMME_DEFINITIONS = {
    "mmr" => [
      cohort(
        to: Date.new(2019, 12, 31),
        doses: [
          dose(1, "mmr", TWELVE_MONTHS),
          dose(2, "mmr", THREE_YEARS_FOUR_MONTHS)
        ]
      ),
      cohort(
        from: Date.new(2020, 1, 1),
        to: Date.new(2022, 8, 31),
        doses: [
          dose(1, "mmr", TWELVE_MONTHS),
          dose(2, "mmr", THREE_YEARS_FOUR_MONTHS)
        ]
      ),
      cohort(
        from: Date.new(2022, 9, 1),
        to: Date.new(2024, 6, 30),
        doses: [
          dose(1, "mmr", TWELVE_MONTHS),
          dose(2, "mmrv", THREE_YEARS_FOUR_MONTHS)
        ]
      ),
      cohort(
        from: Date.new(2024, 7, 1),
        to: Date.new(2024, 12, 31),
        doses: [
          dose(1, "mmr", TWELVE_MONTHS),
          dose(2, "mmrv", EIGHTEEN_MONTHS),
          dose(3, "mmrv", THREE_YEARS_FOUR_MONTHS)
        ]
      ),
      cohort(
        from: Date.new(2025, 1, 1),
        doses: [
          dose(1, "mmrv", TWELVE_MONTHS),
          dose(2, "mmrv", EIGHTEEN_MONTHS)
        ]
      )
    ].freeze
  }.freeze

  def initialize(programme_type:, date_of_birth:)
    @programme_type = programme_type.to_s
    @date_of_birth = date_of_birth.to_date
  end

  def call
    Schedule.new(programme_type:, doses: build_doses)
  end

  private

  attr_reader :programme_type, :date_of_birth

  def cohort_definition
    definitions =
      PROGRAMME_DEFINITIONS.fetch(programme_type) do
        raise UnsupportedProgrammeType, programme_type
      end

    definitions.find { it.covers?(date_of_birth) } ||
      raise(
        ArgumentError,
        "No schedule cohort found for programme #{programme_type} and date of birth #{date_of_birth}"
      )
  end

  def build_doses
    cohort_definition.doses.map do |dose_definition|
      Dose.new(
        dose_sequence: dose_definition.dose_sequence,
        vaccine_type: dose_definition.vaccine_type,
        age_offset: dose_definition.age_offset,
        scheduled_date: date_of_birth.advance(dose_definition.age_offset)
      )
    end
  end
end
