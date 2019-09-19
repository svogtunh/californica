# frozen_string_literal: true

# Import CSV files according to UCLA ingest rules
class CalifornicaImporter
  attr_reader :error_stream, :info_stream, :depositor_id, :import_file_path

  # @param [CsvImport] csv_import
  def initialize(csv_import, error_stream: Darlingtonia.config.default_error_stream, info_stream: Darlingtonia.config.default_info_stream)
    @info_stream = info_stream
    @error_stream = error_stream
    @csv_import = csv_import
    @csv_file = csv_import.manifest.to_s
    @import_file_path = csv_import.import_file_path
    @depositor_id = csv_import.user_id
    raise "Cannot find expected input file #{@csv_file}" unless File.exist?(@csv_file)
  end

  def import
    raise "Cannot find expected input file #{@csv_file}" unless File.exist?(@csv_file)

    attrs = {
      depositor_id: @depositor_id,
      batch_id: @csv_import.id
    }
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    record_importer = ::RecordImporter.new(error_stream: @error_stream, info_stream: @info_stream, attributes: attrs)
    raise "CSV file #{@csv_file} did not validate" unless parser.validate
    Darlingtonia::Importer.new(parser: parser, record_importer: record_importer, info_stream: @info_stream, error_stream: @error_stream).import

    finalize_import

    end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed_time = end_time - start_time
    elapsed_time_per_record = elapsed_time / parser.records.count
    @csv_import.elapsed_time = elapsed_time
    @csv_import.elapsed_time_per_record = elapsed_time_per_record
    @csv_import.save
    @info_stream << @csv_import

  rescue => e
    @error_stream << "CsvImportJob failed: #{e.message}"
  end

  def finalize_import
    parser.order_child_works
    parser.records.each do |row|
      csv_row = CsvRow.where(ark: row.ark, csv_import: csv_import)
      CreateManifestJob.perform_now(row.ark, row_id: csv_row.id) if ['Work', 'Manuscript'].include? row.mapper.metadata['Object Type']
    end
    parser.reindex_collections
    @csv_import.csv_rows.where(status: 'pending finalization').update_all(status: 'complete')
  end

  def parser
    @parser ||=
      CalifornicaCsvParser.new(file:         File.open(@csv_file),
                               import_file_path: @import_file_path,
                               error_stream: @error_stream,
                               info_stream:  @info_stream)
  end

  def timestamp
    @timestamp ||= Time.zone.now.strftime('%Y-%m-%d-%H-%M-%S')
  end
end
