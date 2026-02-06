# frozen_string_literal: true

describe "Find team contacts" do
  let(:team) { create(:team) }

  scenario "Search with no match" do
    given_a_school_with_a_team_exists("Test School")
    when_i_visit_the_school_step
    and_i_search_for_a_school("Nonexistent XYZ")
    then_i_see_no_schools_found_message
  end

  scenario "Search, select school, see contact details" do
    given_a_school_with_a_team_exists("Test School")
    when_i_visit_the_school_step
    and_i_search_for_a_school("Test")
    and_i_choose_school("Test School")
    and_i_click_find_contact_details
    then_i_am_on_the_contact_details_step
    and_i_see_school_name("Test School")
    and_i_see_contact_details_heading
    and_i_see_search_for_another_school_link
  end

  scenario "Submit without selecting school" do
    given_a_school_with_a_team_exists("Test School")
    when_i_visit_the_school_step_with_query("Test")
    and_i_click_find_contact_details
    then_i_see_validation_error("Select a school")
    and_i_see_school_in_results("Test School")
  end

  scenario "Contact details without selection" do
    when_i_visit_contact_details_directly
    then_i_am_redirected_to_the_school_step
  end

  scenario "Search again clears selection" do
    given_a_school_with_a_team_exists("Test School")
    when_i_visit_the_school_step
    and_i_search_for_a_school("Test")
    and_i_choose_school("Test School")
    and_i_click_find_contact_details
    when_i_click_search_for_another_school
    and_i_search_for_a_school("Test")
    and_i_click_find_contact_details
    then_i_see_validation_error("Select a school")
  end

  def given_a_school_with_a_team_exists(school_name)
    team = create(:team)
    create(:school, team:, name: school_name)
  end

  def when_i_visit_find_team_contact
    visit "/find-team-contact"
  end

  def when_i_visit_the_school_step
    visit "/find-team-contact/school"
  end

  def when_i_visit_the_school_step_with_query(query)
    visit "/find-team-contact/school?#{{ q: query }.to_query}"
  end

  def when_i_visit_contact_details_directly
    visit "/find-team-contact/contact-details"
  end

  def then_i_am_on_the_school_step
    expect(page).to have_current_path("/find-team-contact/school")
  end

  def and_i_see_the_school_search_heading
    expect(page).to have_content("Find contact details for your child")
    expect(page).to have_content("school vaccinations team")
  end

  def and_i_see_the_search_form
    expect(page).to have_content("Search for a school")
  end

  def and_i_do_not_see_school_search_results
    expect(page).not_to have_content("School search results")
  end

  def and_i_search_for_a_school(query)
    fill_in "Search for a school", with: query
    click_button "Search"
  end

  def then_i_see_no_schools_found_message
    expect(page).to have_content("No schools matching search criteria found.")
  end

  def and_i_choose_school(school_name)
    choose school_name
  end

  def and_i_click_find_contact_details
    click_button "Find contact details"
  end

  def then_i_am_on_the_contact_details_step
    expect(page).to have_current_path("/find-team-contact/contact-details")
  end

  def and_i_see_school_name(name)
    expect(page).to have_content(name)
  end

  def and_i_see_contact_details_heading
    expect(page).to have_content("Contact details")
  end

  def and_i_see_search_for_another_school_link
    expect(page).to have_content("Search for another school")
  end

  def then_i_see_validation_error(message)
    expect(page).to have_content(message)
  end

  def and_i_see_school_in_results(name)
    expect(page).to have_content(name)
  end

  def then_i_am_redirected_to_the_school_step
    expect(page).to have_current_path("/find-team-contact/school")
  end

  def when_i_click_search_for_another_school
    click_link "Search for another school"
  end
end
