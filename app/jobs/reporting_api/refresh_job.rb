# frozen_string_literal: true

class ReportingAPI::RefreshJob < ApplicationJob
  queue_as :far_future

  def perform = ReportingAPI::Total.refresh!
end
