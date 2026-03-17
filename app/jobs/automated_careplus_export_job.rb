# frozen_string_literal: true

class AutomatedCareplusExportJob < ApplicationJob
  queue_as :default

  def perform(team)
    today = Date.current
    academic_year = AcademicYear.current

    Reports::AutomatedCareplusExporter.call(
        team:,
        academic_year:,
        start_date: today,
        end_date: today
      )

    Rails.application.credentials.dig(
        :careplus,
        :teams,
        team.workgroup.to_sym
      )

    # TODO: replace test call with real CarePlus API call using csv
    # and team_credentials
    # TODO: error if the csv is too large?
    # or split into multiple calls if necessary

    client = Savon.client(wsdl: "http://www.dneonline.com/calculator.asmx?wsdl")

    response = client.call(:add, message: { int_a: 1, int_b: 1 })

    Rails.logger.info("CarePlus test SOAP response: #{response.body}")
  end
end
