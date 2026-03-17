# frozen_string_literal: true

describe AutomatedCareplusExportJob do
  subject(:perform_now) { described_class.perform_now(team) }

  let(:team) { create(:team, :with_careplus_enabled) }

  let(:savon_client) { instance_double(Savon::Client) }
  let(:savon_response) do
    instance_double(
      Savon::Response,
      body: {
        add_response: {
          add_result: "2"
        }
      }
    )
  end

  before do
    allow(Savon).to receive(:client).and_return(savon_client)
    allow(savon_client).to receive(:call).and_return(savon_response)
  end

  it "makes a SOAP call" do
    perform_now
    # TODO: replace test call with real CarePlus API call and update this expectation accordingly
    expect(savon_client).to have_received(:call).with(
      :add,
      message: {
        int_a: 1,
        int_b: 1
      }
    )
  end
end
