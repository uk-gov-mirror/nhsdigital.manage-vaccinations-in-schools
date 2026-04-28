# frozen_string_literal: true

class GIASImportJob < ApplicationJob
  include SingleConcurrencyConcern

  queue_as :far_future

  def perform(dry_run: false)
    GIAS.download

    results = GIAS.check_import
    GIAS.log_import_check_results(results)

    GIAS.import unless dry_run
  end
end
