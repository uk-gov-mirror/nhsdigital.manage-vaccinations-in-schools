# frozen_string_literal: true

class ReportingAPI::RefreshJob < ApplicationJob
  sidekiq_options queue: :far_future

  def perform = ReportingAPI::Total.refresh!
end
