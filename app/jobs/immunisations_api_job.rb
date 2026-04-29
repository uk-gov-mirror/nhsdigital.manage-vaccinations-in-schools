# frozen_string_literal: true

class ImmunisationsAPIJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job

  sidekiq_throttle_as :immunisations_api
end
