# frozen_string_literal: true

class LocationPositionUpdaterJob
  include Sidekiq::Job

  sidekiq_options queue: :far_future, lock: :until_executing

  def perform(location_id)
    location = Location.find(location_id)
    LocationPositionUpdater.call(location)
  rescue LocationPositionUpdater::NoResults => e
    Sentry.capture_exception(e, level: "warning")
  end
end
