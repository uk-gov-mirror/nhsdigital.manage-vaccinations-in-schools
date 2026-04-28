# frozen_string_literal: true

class API::Testing::PatientsController < API::Testing::BaseController
  def create
    patient = Patient.new(patient_params)
    patient.birth_academic_year = patient.date_of_birth.academic_year

    if patient.save
      render json: patient, status: :created
    else
      render json: patient.errors, status: :unprocessable_content
    end
  end

  private

  def patient_params
    params.require(:patient).permit(
      :given_name,
      :family_name,
      :date_of_birth,
      :nhs_number,
      :gender_code,
      :address_line_1,
      :address_line_2,
      :address_town,
      :address_postcode,
      :school_id,
      :gp_practice_id
    )
  end
end
