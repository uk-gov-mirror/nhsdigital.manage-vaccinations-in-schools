# frozen_string_literal: true

describe PatientDeleter do
  subject(:call) { described_class.call(patients:, confirm_production_delete:) }

  let(:confirm_production_delete) { false }
  let(:programme) { Programme.hpv }
  let(:team) { create(:team, programmes: [programme]) }
  let(:session) { create(:session, team:, programmes: [programme]) }
  let(:patients) { Patient.where(id: patient.id) }
  let!(:patient) { create(:patient) }

  it "deletes the patient" do
    expect { call }.to change(Patient, :count).by(-1)
    expect { patient.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  context "with multiple patients" do
    let!(:other_patient) { create(:patient) }
    let(:patients) { Patient.where(id: [patient.id, other_patient.id]) }

    it "deletes all patients" do
      expect { call }.to change(Patient, :count).by(-2)
    end
  end

  context "in production" do
    before { allow(Rails.env).to receive(:production?).and_return(true) }

    context "when confirm_production_delete is false" do
      let(:confirm_production_delete) { false }

      it "raises an error" do
        expect { call }.to raise_error(PatientDeleter::ProductionDeletionError)
      end

      it "does not delete the patient" do
        expect { call }.to raise_error(PatientDeleter::ProductionDeletionError)
        expect { patient.reload }.not_to raise_error
      end
    end

    context "when confirm_production_delete is true" do
      let(:confirm_production_delete) { true }

      it "deletes the patient" do
        expect { call }.to change(Patient, :count).by(-1)
      end
    end
  end

  context "with associated records" do
    let(:archive_reason) do
      create(:archive_reason, :moved_out_of_area, patient:, team:)
    end
    let(:attendance_record) { create(:attendance_record, :present, patient:) }
    let(:patient_changeset) do
      create(:patient_changeset, :class_import, patient:)
    end
    let(:clinic_notification) do
      create(:clinic_notification, :initial_invitation, patient:, session:)
    end
    let(:consent_notification) do
      create(:consent_notification, :request, patient:, session:)
    end
    let(:consent) { create(:consent, patient:, programme:) }
    let(:gillick_assessment) do
      create(:gillick_assessment, :competent, patient:)
    end
    let(:important_notice) { create(:important_notice, :deceased, patient:) }
    let(:note) { create(:note, patient:, session:) }
    let(:patient_programme_vaccinations_search) do
      create(:patient_programme_vaccinations_search, patient:, programme:)
    end
    let(:patient_specific_direction) do
      create(:patient_specific_direction, patient:, programme:)
    end
    let(:patient_location) { create(:patient_location, session:, patient:) }
    let(:pre_screening) { create(:pre_screening, patient:) }
    let(:school_move) { create(:school_move, :to_school, patient:) }
    let(:session_notification) do
      create(:session_notification, :school_reminder, patient:, session:)
    end
    let(:triage) { create(:triage, :safe_to_vaccinate, patient:, programme:) }
    let(:vaccination_record) do
      create(:vaccination_record, patient:, session:, programme:)
    end
    let(:discarded_vaccination_record) do
      create(:vaccination_record, :discarded, patient:, session:, programme:)
    end

    it "deletes archive reasons" do
      archive_reason
      expect { call }.to change(ArchiveReason, :count).by(-1)
    end

    it "deletes attendance records" do
      attendance_record
      expect { call }.to change(AttendanceRecord, :count).by(-1)
    end

    it "deletes patient changesets" do
      patient_changeset
      expect { call }.to change(PatientChangeset, :count).by(-1)
    end

    it "deletes clinic notifications" do
      clinic_notification
      expect { call }.to change(ClinicNotification, :count).by(-1)
    end

    it "deletes consent notifications" do
      consent_notification
      expect { call }.to change(ConsentNotification, :count).by(-1)
    end

    it "deletes consents" do
      consent
      expect { call }.to change(Consent, :count).by(-1)
    end

    it "deletes gillick assessments" do
      gillick_assessment
      expect { call }.to change(GillickAssessment, :count).by(-1)
    end

    it "deletes important notices" do
      important_notice
      expect { call }.to change(ImportantNotice, :count).by(-1)
    end

    it "deletes notes" do
      note
      expect { call }.to change(Note, :count).by(-1)
    end

    it "deletes patient programme vaccinations searches" do
      patient_programme_vaccinations_search
      expect { call }.to change(PatientProgrammeVaccinationsSearch, :count).by(
        -1
      )
    end

    it "deletes patient specific directions" do
      patient_specific_direction
      expect { call }.to change(PatientSpecificDirection, :count).by(-1)
    end

    it "deletes patient locations" do
      patient_location
      expect { call }.to change(PatientLocation, :count).by(-1)
    end

    it "deletes pre-screenings" do
      pre_screening
      expect { call }.to change(PreScreening, :count).by(-1)
    end

    it "deletes school moves" do
      school_move
      expect { call }.to change(SchoolMove, :count).by(-1)
    end

    it "deletes session notifications" do
      session_notification
      expect { call }.to change(SessionNotification, :count).by(-1)
    end

    it "deletes triages" do
      triage
      expect { call }.to change(Triage, :count).by(-1)
    end

    it "deletes vaccination records" do
      vaccination_record
      expect { call }.to change(VaccinationRecord.with_discarded, :count).by(-1)
    end

    it "deletes discarded vaccination records" do
      discarded_vaccination_record
      expect { call }.to change(VaccinationRecord.with_discarded, :count).by(-1)
    end
  end

  context "with import associations" do
    let(:class_import) { create(:class_import) }
    let(:cohort_import) { create(:cohort_import) }
    let(:immunisation_import) { create(:immunisation_import, team:) }

    before do
      patient.class_imports << class_import
      patient.cohort_imports << cohort_import
      patient.immunisation_imports << immunisation_import
    end

    it "does not delete class imports" do
      expect { call }.not_to change(ClassImport, :count)
    end

    it "does not delete cohort imports" do
      expect { call }.not_to change(CohortImport, :count)
    end

    it "does not delete immunisation imports" do
      expect { call }.not_to change(ImmunisationImport, :count)
    end
  end

  context "with parent relationships" do
    let(:parent_relationship) { create(:parent_relationship, patient:) }
    let(:parent) { parent_relationship.parent }

    it "deletes the parent relationship" do
      parent_relationship
      expect { call }.to change(ParentRelationship, :count).by(-1)
    end

    it "destroys orphaned parents" do
      parent_relationship
      expect { call }.to change(Parent, :count).by(-1)
      expect { parent.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when the parent has another child" do
      let!(:other_patient) { create(:patient) }

      before { create(:parent_relationship, parent:, patient: other_patient) }

      context "when only one child is deleted" do
        it "removes only 1 parent relationship" do
          expect { call }.to change(ParentRelationship, :count).by(-1)
        end

        it "keeps the parent" do
          expect { call }.not_to change(Parent, :count)
          expect { parent.reload }.not_to raise_error
        end

        it "does not remove the parent relationship with the other child" do
          call
          expect(other_patient.parents.reload).to contain_exactly(parent)
        end
      end
    end

    context "when all the parent's children are being deleted" do
      let!(:other_patient) { create(:patient) }
      let(:patients) { Patient.where(id: [patient.id, other_patient.id]) }

      before { create(:parent_relationship, parent:, patient: other_patient) }

      it "deletes both parent relationships" do
        parent_relationship
        expect { call }.to change(ParentRelationship, :count).by(-2)
      end

      it "destroys the parent" do
        parent_relationship
        expect { call }.to change(Parent, :count).by(-1)
        expect { parent.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  # This test ensures that if a new table is added with a non-cascading FK
  # to patients, and prompt the developer to handle it in PatientDeleter.
  describe "non-cascading patient FK coverage" do
    it "covers all non-cascading FK relationships to the patients table" do
      non_cascading_fk_tables =
        ActiveRecord::Base.connection.tables.flat_map do |table|
          foreign_key =
            ActiveRecord::Base
              .connection
              .foreign_keys(table)
              .select do |fk|
                fk.to_table == "patients" && fk.options[:on_delete] != :cascade
              end
          foreign_key.map(&:from_table)
        end
      non_cascading_fk_tables = non_cascading_fk_tables.to_set

      # Tables explicitly handled by PatientDeleter
      explicitly_handled = %w[
        archive_reasons
        attendance_records
        clinic_notifications
        consent_notifications
        consents
        gillick_assessments
        important_notices
        notes
        parent_relationships
        patient_changesets
        patient_locations
        patient_programme_vaccinations_searches
        patient_specific_directions
        pre_screenings
        school_moves
        session_notifications
        triages
        vaccination_records
      ].to_set

      unhandled = non_cascading_fk_tables - explicitly_handled

      expect(unhandled).to(
        be_empty,
        "The following tables have non-cascading FKs to patients but are " \
          "not handled in PatientDeleter: #{unhandled.to_a.sort.join(", ")}"
      )
    end
  end
end
