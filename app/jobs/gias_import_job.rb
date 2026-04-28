# frozen_string_literal: true

class GIASImportJob < ApplicationJob
  include SingleConcurrencyConcern

  sidekiq_options queue: :far_future

  def perform
    GIAS.download

    results = GIAS.check_import
    GIAS.log_import_check_results(results)

    GIAS.import
  end
end
