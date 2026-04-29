# frozen_string_literal: true

class API::Testing::TeamLocationsController < API::Testing::BaseController
  def create
    organisation = Organisation.find_by!(ods_code: params[:workgroup])
    school = Location.school.find(params[:school_id])
    academic_year = AcademicYear.pending

    team_locations =
      organisation.teams.map do |team|
        TeamLocation.find_or_create_by!(
          team:,
          location: school,
          academic_year:
        )
      end

    render json: team_locations, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end
end
