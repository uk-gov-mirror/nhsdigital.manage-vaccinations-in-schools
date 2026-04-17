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

  describe "school moves export card" do
    before do
      exportable = create(:school_moves_export)
      create(:export, exportable:, team:, user:)
      visit downloads_path
    end

    it "does not show a date range row when no dates set" do
      expect(page).not_to have_content("Date range")
    end

    context "when date_from and date_to are set" do
      before do
        exportable =
          create(
            :school_moves_export,
            date_from: Date.new(2024, 9, 1),
            date_to: Date.new(2025, 7, 31)
          )
        create(:export, exportable:, team:, user:)
        visit downloads_path
      end

      it "shows a date range row" do
        expect(page).to have_content("Date range")
        expect(page).to have_content("1 September 2024")
        expect(page).to have_content("31 July 2025")
      end
    end
  end

  describe "type filter" do
    before do
      exportable = create(:school_moves_export)
      create(:export, exportable:, team:, user:)

      visit downloads_path
    end

    it "shows only school moves exports when that filter is selected" do
      choose "School moves"
      click_on "Update results"

      within(".app-grid-column-results") do
        expect(page).to have_content("School moves")
      end
    end
  end
end
