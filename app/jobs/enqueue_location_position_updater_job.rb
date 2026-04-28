# frozen_string_literal: true

class EnqueueLocationPositionUpdaterJob < ApplicationJob
  queue_as :far_future

  def perform
    ids = Location.where(position: nil).has_address.ids
    LocationPositionUpdaterJob.perform_bulk(ids.zip)
  end
end
