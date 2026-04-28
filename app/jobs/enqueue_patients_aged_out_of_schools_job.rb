# frozen_string_literal: true

class EnqueuePatientsAgedOutOfSchoolsJob < ApplicationJob
  queue_as :far_future

  def perform
    academic_year = AcademicYear.pending
    ids = Location.gias_school.with_team(academic_year:).pluck(:id)
    PatientsAgedOutOfSchoolJob.perform_bulk(ids.zip)
  end
end
