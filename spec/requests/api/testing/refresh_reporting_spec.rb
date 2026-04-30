# frozen_string_literal: true

describe "/api/testing/refresh-reporting" do
  before { Flipper.enable(:testing_api) }

  describe "GET" do
    context "without wait param" do
      it "enqueues the job and responds with accepted" do
        expect { get "/api/testing/refresh-reporting" }.to have_enqueued_job(
          ReportingAPI::RefreshJob
        )
        expect(response).to have_http_status(:accepted)
      end
    end

    context "with wait=true" do
      before { allow(ReportingAPI::RefreshJob).to receive(:perform_now) }

      it "runs the job synchronously and responds with ok" do
        get "/api/testing/refresh-reporting", params: { wait: "true" }
        expect(ReportingAPI::RefreshJob).to have_received(:perform_now)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
