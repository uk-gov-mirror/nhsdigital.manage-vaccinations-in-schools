# frozen_string_literal: true

describe ProgrammeSchedule do
  describe ".call" do
    it "returns the legacy MMR schedule for patients born on or before 2019-12-31" do
      schedule =
        described_class.call(
          programme_type: :mmr,
          date_of_birth: Date.new(2019, 12, 31)
        )

      expect(schedule.programme_type).to eq("mmr")

      expect(schedule.doses).to eq(
        [
          ProgrammeSchedule::Dose.new(
            dose_sequence: 1,
            vaccine_type: "mmr",
            age_offset: {
              months: 12
            },
            scheduled_date: Date.new(2020, 12, 31)
          ),
          ProgrammeSchedule::Dose.new(
            dose_sequence: 2,
            vaccine_type: "mmr",
            age_offset: {
              years: 3,
              months: 4
            },
            scheduled_date: Date.new(2023, 4, 30)
          )
        ]
      )
    end

    it "returns an MMR then MMRV schedule for the 2022-09-01 cohort boundary" do
      schedule =
        described_class.call(
          programme_type: "mmr",
          date_of_birth: Date.new(2022, 9, 1)
        )

      expect(schedule.doses).to eq(
        [
          ProgrammeSchedule::Dose.new(
            dose_sequence: 1,
            vaccine_type: "mmr",
            age_offset: {
              months: 12
            },
            scheduled_date: Date.new(2023, 9, 1)
          ),
          ProgrammeSchedule::Dose.new(
            dose_sequence: 2,
            vaccine_type: "mmrv",
            age_offset: {
              years: 3,
              months: 4
            },
            scheduled_date: Date.new(2026, 1, 1)
          )
        ]
      )
    end

    it "returns the three-dose schedule for patients born on or after 2024-07-01 and before 2025-01-01" do
      schedule =
        described_class.call(
          programme_type: :mmr,
          date_of_birth: Date.new(2024, 7, 1)
        )

      expect(schedule.doses).to eq(
        [
          ProgrammeSchedule::Dose.new(
            dose_sequence: 1,
            vaccine_type: "mmr",
            age_offset: {
              months: 12
            },
            scheduled_date: Date.new(2025, 7, 1)
          ),
          ProgrammeSchedule::Dose.new(
            dose_sequence: 2,
            vaccine_type: "mmrv",
            age_offset: {
              months: 18
            },
            scheduled_date: Date.new(2026, 1, 1)
          ),
          ProgrammeSchedule::Dose.new(
            dose_sequence: 3,
            vaccine_type: "mmrv",
            age_offset: {
              years: 3,
              months: 4
            },
            scheduled_date: Date.new(2027, 11, 1)
          )
        ]
      )
    end

    it "returns the all-MMRV schedule for patients born on or after 2025-01-01" do
      schedule =
        described_class.call(
          programme_type: :mmr,
          date_of_birth: Date.new(2025, 1, 1)
        )

      expect(schedule.doses).to eq(
        [
          ProgrammeSchedule::Dose.new(
            dose_sequence: 1,
            vaccine_type: "mmrv",
            age_offset: {
              months: 12
            },
            scheduled_date: Date.new(2026, 1, 1)
          ),
          ProgrammeSchedule::Dose.new(
            dose_sequence: 2,
            vaccine_type: "mmrv",
            age_offset: {
              months: 18
            },
            scheduled_date: Date.new(2026, 7, 1)
          )
        ]
      )
    end

    it "raises for unsupported programmes" do
      expect {
        described_class.call(
          programme_type: :hpv,
          date_of_birth: Date.new(2025, 1, 1)
        )
      }.to raise_error(
        UnsupportedProgrammeType,
        "Unsupported programme type: hpv"
      )
    end

    it "raises a clearer error when a supported programme has no matching cohort" do
      stub_const(
        "ProgrammeSchedule::PROGRAMME_DEFINITIONS",
        {
          "mmr" => [
            ProgrammeSchedule::CohortDefinition.new(
              to: Date.new(2024, 12, 31),
              doses: [
                ProgrammeSchedule::DoseDefinition.new(
                  dose_sequence: 1,
                  vaccine_type: "mmr",
                  age_offset: ProgrammeSchedule::TWELVE_MONTHS
                )
              ]
            )
          ].freeze
        }.freeze
      )

      expect {
        described_class.call(
          programme_type: :mmr,
          date_of_birth: Date.new(2025, 1, 1)
        )
      }.to raise_error(
        ArgumentError,
        "No schedule cohort found for programme mmr and date of birth 2025-01-01"
      )
    end
  end
end
