# frozen_string_literal: true

describe Imports::JoinRecords do
  let(:import) { create(:class_import) }
  let(:patients) { create_list(:patient, 2) }

  describe ".call" do
    subject(:call) { described_class.call(import, patients) }

    it "inserts join records between the import and records" do
      expect { call }.to change(ClassImportsPatient, :count).by(2)
    end
  end

  describe "#call" do
    subject(:call) { described_class.new(import, records).call }

    context "when records is empty" do
      let(:records) { [] }

      it { should eq([]) }

      it "does not insert any records" do
        expect { call }.not_to change(ClassImportsPatient, :count)
      end
    end

    context "with a named join model constant" do
      let(:records) { patients }

      it "uses ClassImportsPatient and inserts join records" do
        expect { call }.to change(ClassImportsPatient, :count).by(2)
      end

      it "associates the records with the import" do
        call
        expect(ClassImportsPatient.distinct.pluck(:class_import_id)).to eq(
          [import.id]
        )
        expect(ClassImportsPatient.pluck(:patient_id)).to match_array(
          patients.map(&:id)
        )
      end

      context "when called twice with the same records" do
        before { described_class.new(import, records).call }

        it "ignores duplicate rows" do
          expect { call }.not_to change(ClassImportsPatient, :count)
        end
      end
    end

    context "without a named join model constant" do
      let(:import) { create(:immunisation_import) }
      let(:records) { patients }
      let(:join_table) do
        Class.new(ApplicationRecord) do
          self.table_name = "immunisation_imports_patients"
        end
      end

      it "inserts join records using the inferred table name" do
        expect { call }.to change(join_table, :count).by(2)
      end
    end

    context "with records_type provided as a string" do
      let(:records) { patients }

      it "classifies and uses the provided records_type" do
        expect {
          described_class.new(import, records, records_type: "patient").call
        }.to change(ClassImportsPatient, :count).by(2)
      end
    end
  end

  describe "#import_type" do
    subject(:join_records) { described_class.new(import, patients) }

    it "equals the import class name" do
      expect(join_records.import_type).to eq("ClassImport")
    end
  end

  describe "#records_type" do
    context "when inferred from records" do
      subject(:join_records) { described_class.new(import, patients) }

      it "equals the records class name" do
        expect(join_records.records_type).to eq("Patient")
      end
    end

    context "when provided via keyword argument" do
      subject(:join_records) do
        described_class.new(import, patients, records_type: "patient")
      end

      it "is classified from the given string" do
        expect(join_records.records_type).to eq("Patient")
      end
    end

    context "when records is empty" do
      subject(:join_records) { described_class.new(import, []) }

      it "is nil" do
        expect(join_records.records_type).to be_nil
      end
    end
  end
end
