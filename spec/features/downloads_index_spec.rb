# frozen_string_literal: true

describe "Downloads index" do
  let(:team) { create(:team, :with_one_nurse) }
  let(:user) { team.users.first }

  before { sign_in user }

  it "shows the page" do
    visit downloads_path
    expect(page).to have_content("Downloads")
  end

  it "shows an empty list when no exports exist" do
    visit downloads_path
    within(".app-grid-column-results") do
      expect(page).not_to have_css(".nhsuk-card")
    end
  end

  describe "location export card" do
    context "when location is a clinic" do
      before do
        exportable = create(:location_export)
        create(:export, exportable:, team:, user:)
        visit downloads_path
      end

      it "does not show a school row" do
        within(".nhsuk-card", text: "Community clinic offline session") do
          expect(page).not_to have_css("dt", text: "School")
        end
      end
    end

    context "when location is a school" do
      let(:school) { create(:gias_school, team:) }

      before do
        exportable = create(:location_export, location: school)
        create(:export, exportable:, team:, user:)
        visit downloads_path
      end

      it "shows the school name" do
        within(".nhsuk-card", text: school.name) do
          expect(page).to have_css("dt", text: "School")
          expect(page).to have_content(school.name)
        end
      end
    end
  end

  describe "offline session export card" do
    let(:programme) { Programme.hpv }
    let(:location) { create(:gias_school, team:, programmes: [programme]) }
    let(:session) do
      create(:session, team:, location:, programmes: [programme])
    end

    before do
      exportable = create(:session_export, session:)
      create(:export, exportable:, team:, user:)
      visit downloads_path
    end

    it "shows the school name" do
      within(".nhsuk-card", text: location.name) do
        expect(page).to have_css("dt", text: "School")
        expect(page).to have_content(location.name)
      end
    end
  end

  describe "type filter" do
    let(:programme) { Programme.hpv }
    let(:school) { create(:gias_school, team:, programmes: [programme]) }
    let(:session) do
      create(:session, team:, location: school, programmes: [programme])
    end

    before do
      exportable = create(:location_export, location: school)
      create(:export, exportable:, team:, user:)

      exportable = create(:session_export, session:)
      create(:export, exportable:, team:, user:)

      visit downloads_path
    end

    it "shows only offline session exports when that filter is selected" do
      choose "Offline session"
      click_on "Update results"

      within(".app-grid-column-results") do
        expect(page).to have_content("#{school.name} offline session")
      end
    end
  end
end
