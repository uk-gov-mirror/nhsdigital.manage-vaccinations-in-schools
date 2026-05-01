# frozen_string_literal: true

describe "Record already vaccinated" do
  around { |example| travel_to(Date.new(2026, 5, 1)) { example.run } }

  scenario "Flu rejects a future date" do
    given_i_am_signed_in

    when_i_go_to_a_patient
    and_i_click_on_the_programme
    then_i_see_the_patient_page

    when_i_click_record_already_vaccinated
    and_i_choose_a_future_date
    then_i_see_an_error_for_the_future_date
  end

  def given_i_am_signed_in
    programmes = [Programme.flu]

    team = create(:team, :with_one_nurse, programmes:)
    school = create(:gias_school, :primary, team:, programmes:)

    @patient = create(:patient, :consent_no_response, school:, programmes:)

    sign_in team.users.first
  end

  def when_i_go_to_a_patient
    visit patient_path(@patient)
  end

  def and_i_click_on_the_programme
    within(".app-secondary-navigation") { click_on "Flu" }
  end

  def then_i_see_the_patient_page
    expect(page).to have_content(@patient.full_name)
  end

  def when_i_click_record_already_vaccinated
    click_on "Record as already vaccinated"
  end

  def and_i_choose_a_future_date
    fill_in "Day", with: "2"
    fill_in "Month", with: "5"
    fill_in "Year", with: "2026"
    click_on "Continue"
  end

  def then_i_see_an_error_for_the_future_date
    expect(page).to have_content(
      "The vaccination cannot take place after 1 May 2026"
    )
    expect(page).not_to have_content("Check and confirm")
  end
end
