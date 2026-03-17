# frozen_string_literal: true

class EnqueueAutomatedCareplusExportJob < ApplicationJob
  queue_as :default

  def perform
    Team.find_each do |team|
      next unless team.careplus_enabled?

      AutomatedCareplusExportJob.perform_later(team)
    end
  end
end
