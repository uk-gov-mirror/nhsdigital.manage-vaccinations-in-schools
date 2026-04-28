# frozen_string_literal: true

class EnqueueAutomatedCareplusReportsJob < ApplicationJob
  sidekiq_options queue: :far_future

  def perform
    ids = Team.eligible_for_automated_careplus_reports.ids
    SendAutomatedCareplusReportsJob.perform_bulk(ids.zip)
  end
end
