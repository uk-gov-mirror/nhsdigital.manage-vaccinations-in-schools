# frozen_string_literal: true

class EnqueuePatientsAgedOutOfSchoolsJob < ApplicationJob
  sidekiq_options queue: :far_future

  def perform
    academic_year = AcademicYear.pending
    ids = Location.gias_school.with_team(academic_year:).pluck(:id)
    PatientsAgedOutOfSchoolJob.perform_bulk(ids.zip)
  end
end
