# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ActorRecordImporter, :clean do
  subject(:importer) do
    described_class.new(error_stream: error_stream, info_stream: info_stream)
  end

  let(:record)        { Darlingtonia::InputRecord.from(metadata: metadata_hash) }
  let(:error_stream)  { [] }
  let(:info_stream)   { [] }
  let(:metadata_hash) { { 'title' => ['Comet in Moominland'] } }

  describe '#import' do
    include_context 'with workflow'

    it 'creates a work for record' do
      expect { importer.import(record: record) }
        .to change { Work.count }
        .by 1
    end

    it 'writes to the info_stream before and after create' do
      expect { importer.import(record: record) }
        .to change { info_stream }
        .to contain_exactly(/^Creating record/, /^Record created/)
    end

    context 'with remote_files' do
      let(:metadata_hash) do
        { 'title'        => ['Comet in Moominland'],
          'remote_files' => [{ url: file_uri }] }
      end

      let(:file_uri) { 'file:///opt/data/file.tif' }

      it 'attaches a remote file' do
        expect { importer.import(record: record) }
          .to have_enqueued_job(IngestLocalFileJob)
      end
    end

    context 'with an invalid input record' do
      let(:record) { Darlingtonia::InputRecord.new } # no title

      it 'logs an error' do
        expect { importer.import(record: record) }
          .to change { error_stream }
          .to contain_exactly(/^Validation failed: Title/)
      end
    end
  end
end