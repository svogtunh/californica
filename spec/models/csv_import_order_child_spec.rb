# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CsvImportOrderChild, type: :model do
  subject(:order_child) { FactoryBot.build(:csv_import_order_child) }

  describe '#ark' do
    it 'is stored' do
      expect(order_child.ark).to be_instance_of(String)
    end
  end

  describe '#csv_import_id' do
    let(:csv_import_1) { FactoryBot.create(:csv_import) }
    let(:csv_import_2) { FactoryBot.create(:csv_import) }

    it 'is stored' do
      expect(order_child.csv_import_id).to be_instance_of(Integer)
    end

    it 'validates uniqueness of ark per csv_import' do
      expect do
        FactoryBot.create(:csv_collection_reindex, csv_import_id: csv_import_1.id, ark: 'ark:/abc/123')
        FactoryBot.create(:csv_collection_reindex, csv_import_id: csv_import_1.id, ark: 'ark:/abc/123')
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Ark must be unique per CsvImport')
    end

    it 'allows the same ark in different csv_imports' do
      expect do
        FactoryBot.create(:csv_collection_reindex, csv_import_id: csv_import_1.id, ark: 'ark:/abc/123')
        FactoryBot.create(:csv_collection_reindex, csv_import_id: csv_import_2.id, ark: 'ark:/abc/123')
      end.not_to raise_error
    end

    it 'can be followed from the CsvImport object' do
      reindex = FactoryBot.create(:csv_collection_reindex, csv_import_id: csv_import_1.id, ark: 'ark:/abc/123')
      expect(csv_import_1.csv_collection_reindices).to contain_exactly(reindex)
    end
  end

  describe '#status' do
    it 'is stored' do
      expect(order_child.status).to be_instance_of(String)
    end
  end

  describe '#error_messages' do
    it 'is stored' do
      expect(order_child.error_messages).to be_instance_of(Array)
    end
  end

  describe '#start_time' do
    it 'is stored' do
      expect(order_child.start_time).to be_instance_of(ActiveSupport::TimeWithZone)
    end
  end

  describe '#end_time' do
    it 'is stored' do
      expect(order_child.end_time).to be_instance_of(ActiveSupport::TimeWithZone)
    end
  end

  describe '#elapsed_time' do
    it 'is stored' do
      expect(order_child.elapsed_time).to be_instance_of(Float)
    end
  end

  describe '#no_of_children' do
    it 'is stored' do
      expect(order_child.no_of_children).to be_instance_of(Integer)
    end
  end
end
