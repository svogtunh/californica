# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalifornicaCsvParser do
  subject(:parser)    { described_class.new(file: file, csv_import_id: 0, import_file_path: import_file_path, error_stream: error_stream, info_stream: info_stream) }
  let(:file)          { File.open(csv_path) }
  let(:csv_path)      { 'spec/fixtures/example.csv' }
  let(:import_file_path) { fixture_path }
  let(:info_stream)   { [] }
  let(:error_stream)  { [] }

  after do
    ENV['SKIP'] = '0'
  end

  describe '#build_iiif_manifests' do
    it 'enqueues a CreateManifestJob for each Work and ChildWork' do
      allow(CreateManifestJob).to receive(:perform_now)
      parser.records.each { |r| r } # just cycle through the iterator to populate @manifests_needing_build
      parser.build_iiif_manifests
      expect(CreateManifestJob).to have_received(:perform_now).with('ark:/21198/zz0002nq4w', create_manifest_object_id: CsvImportCreateManifest.last.id)
    end
  end

  describe 'use in an importer', :clean do
    include_context 'with workflow'

    it 'has an import_file_path' do
      expect(parser.import_file_path).to eq fixture_path
    end

    let(:importer) do
      Darlingtonia::Importer.new(parser: parser, record_importer: ActorRecordImporter.new, info_stream: info_stream, error_stream: error_stream)
    end

    it 'imports records' do
      expect { importer.import }.to change { Work.count }.by 1
    end

    it 'skips records if ENV[\'SKIP\'] is set' do
      ENV['SKIP'] = '1'
      expect { importer.import }.to change { Work.count }.by 0
    end
  end

  describe '#records' do
    it 'lists records' do
      expect(parser.records.count).to eq 1
    end

    it 'can build attributes' do
      expect { parser.records.map(&:attributes) }.not_to raise_error
    end
  end

  describe '#headers' do
    let(:expected_headers) do
      ['Object Type',
       'Project Name',
       'Parent ARK',
       'Item ARK',
       'Subject',
       'Type.typeOfResource',
       'Rights.copyrightStatus',
       'Type.genre',
       'Name.subject',
       'Coverage.geographic',
       'Relation.isPartOf',
       'Publisher.publisherName',
       'Rights.countryCreation',
       'Rights.rightsHolderContact',
       'Name.architect',
       'Name.photographer',
       'Name.repository',
       'Date.normalized',
       'AltIdentifier.local',
       'Title',
       'Date.creation',
       'Format.extent',
       'Format.medium',
       'Format.dimensions',
       'Description.note',
       'Description.fundingNote',
       'Description.longitude',
       'Description.latitude',
       'Description.caption',
       'File Name',
       'AltTitle.other',
       'AltTitle.translated',
       'Place of origin',
       'AltTitle.uniform',
       'Support',
       'Author',
       'Summary',
       'Page layout',
       'Text direction',
       'Binding note',
       'viewingHint',
       'IIIF Range',
       'Illustrations note',
       'Provenance',
       'Table of Contents',
       'Subject.conceptTopic',
       'Subject.descriptiveTopic',
       'Collation',
       'Foliation note',
       'Foliation',
       'Illuminator',
       'Name.illuminator',
       'Name.lyricist',
       'Name.composer',
       'Scribe',
       'Name.scribe',
       'Condition note',
       'Rights.statementLocal',
       'Masthead',
       'Representative image',
       'Featured image',
       'Tagline',
       'Commentator',
       'Name.commentator',
       'Translator',
       'Name.translator',
       'Subject temporal',
       'Opac url',
       'Subject geographic',
       'Colophon',
       'Description.colophon',
       'Finding Aid URL',
       'Alt ID.url',
       'Rubricator',
       'Name.rubricator',
       'Name.creator']
    end

    it 'knows the headers for this CSV file' do
      expect(parser.headers).to eq expected_headers
    end

    context 'headers that are wrapped in quotes' do
      let(:csv_path) { File.join(fixture_path, 'quoted_headers.csv') }
      let(:expected_headers) { ['Item ARK', 'Title'] }

      it 'knows the headers for this CSV file' do
        expect(parser.headers).to eq expected_headers
      end
    end
  end

  describe '#reindex_collections' do
    let(:queued_collection) { FactoryBot.create(:csv_collection_reindex, csv_import_id: 0, status: 'queued') }
    let(:in_progress_collection) { FactoryBot.create(:csv_collection_reindex, csv_import_id: 0, status: 'in progress') }
    let(:complete_collection) { FactoryBot.create(:csv_collection_reindex, csv_import_id: 0, status: 'complete') }
    let(:error_collection) { FactoryBot.create(:csv_collection_reindex, csv_import_id: 0, status: 'error') }

    before do
      allow(ReindexCollectionJob).to receive(:perform_now)
    end

    it 'reindexes collections with status "queued"' do
      queued_collection
      parser.reindex_collections
      expect(ReindexCollectionJob).to have_received(:perform_now).with(queued_collection.id)
    end

    it 'reindexes collections with status "in progress"' do
      in_progress_collection
      parser.reindex_collections
      expect(ReindexCollectionJob).to have_received(:perform_now).with(in_progress_collection.id)
    end

    it 'does not reindex collections with status "complete"' do
      complete_collection
      parser.reindex_collections
      expect(ReindexCollectionJob).not_to have_received(:perform_now).with(complete_collection.id)
    end

    it 'does not reindex collections with status "error"' do
      error_collection
      parser.reindex_collections
      expect(ReindexCollectionJob).not_to have_received(:perform_now).with(error_collection.id)
    end
  end

  describe '#build_iiif_manifests' do
    let(:queued_work) { FactoryBot.create(:csv_import_create_manifest, csv_import_id: 0, status: 'queued') }
    let(:in_progress_work) { FactoryBot.create(:csv_import_create_manifest, csv_import_id: 0, status: 'in progress') }
    let(:complete_work) { FactoryBot.create(:csv_import_create_manifest, csv_import_id: 0, status: 'complete') }
    let(:error_work) { FactoryBot.create(:csv_import_create_manifest, csv_import_id: 0, status: 'error') }

    before do
      allow(CreateManifestJob).to receive(:perform_now)
    end

    it 'reindexes works with status "queued"' do
      queued_work
      parser.build_iiif_manifests
      expect(CreateManifestJob).to have_received(:perform_now).with(Ark.ensure_prefix(queued_work.ark), create_manifest_object_id: queued_work.id)
    end

    it 'reindexes works with status "in progress"' do
      in_progress_work
      parser.build_iiif_manifests
      expect(CreateManifestJob).to have_received(:perform_now).with(Ark.ensure_prefix(in_progress_work.ark), create_manifest_object_id: in_progress_work.id)
    end

    it 'does not reindex works with status "complete"' do
      complete_work
      parser.build_iiif_manifests
      expect(CreateManifestJob).not_to have_received(:perform_now).with(Ark.ensure_prefix(complete_work.ark), complete_work.id)
    end

    it 'does not reindex works with status "error"' do
      error_work
      parser.build_iiif_manifests
      expect(CreateManifestJob).not_to have_received(:perform_now).with(Ark.ensure_prefix(error_work.ark), error_work.id)
    end
  end

  describe '#order_child_works' do
    let(:queued_work) { FactoryBot.create(:csv_import_order_child, csv_import_id: 0, status: 'queued') }
    let(:in_progress_work) { FactoryBot.create(:csv_import_order_child, csv_import_id: 0, status: 'in progress') }
    let(:complete_work) { FactoryBot.create(:csv_import_order_child, csv_import_id: 0, status: 'complete') }
    let(:error_work) { FactoryBot.create(:csv_import_order_child, csv_import_id: 0, status: 'error') }
    let(:service) { instance_double('Californica::OrderChildWorksService') }

    before do
      allow(Californica::OrderChildWorksService).to receive(:new).and_return(service)
      allow(service).to receive(:order)
    end

    it 'reindexes works with status "queued"' do
      queued_work
      parser.order_child_works
      expect(service).to have_received(:order)
    end

    it 'reindexes works with status "in progress"' do
      in_progress_work
      parser.order_child_works
      expect(service).to have_received(:order)
    end

    it 'does not reindex works with status "complete"' do
      complete_work
      parser.order_child_works
      expect(service).not_to have_received(:order)
    end

    it 'does not reindex works with status "error"' do
      error_work
      parser.order_child_works
      expect(service).not_to have_received(:order)
    end
  end
end
