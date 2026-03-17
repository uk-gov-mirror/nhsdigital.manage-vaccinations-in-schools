# frozen_string_literal: true

describe EnqueueAutomatedCareplusExportJob do
  subject(:perform_now) { described_class.perform_now }

  context "with a team that does not have CarePlus enabled" do
    before { create(:team) }

    it "does not enqueue any jobs" do
      expect { perform_now }.not_to have_enqueued_job(
        AutomatedCareplusExportJob
      )
    end
  end

  context "with a team that has CarePlus enabled" do
    let(:team) { create(:team, :with_careplus_enabled) }

    before { team }

    it "enqueues a job for the team" do
      expect { perform_now }.to have_enqueued_job(
        AutomatedCareplusExportJob
      ).with(team)
    end
  end

  context "with a mix of teams" do
    let(:careplus_team) { create(:team, :with_careplus_enabled) }

    before do
      careplus_team
      create(:team)
    end

    it "only enqueues a job for the CarePlus-enabled team" do
      expect { perform_now }.to have_enqueued_job(
        AutomatedCareplusExportJob
      ).exactly(:once).with(careplus_team)
    end
  end
end
