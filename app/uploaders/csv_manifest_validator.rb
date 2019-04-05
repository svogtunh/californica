# frozen_string_literal: true

# Validate a CSV file.
#
# Don't put expensive validations in this class.
# This is meant to be used for running a few quick
# validations before starting a CSV-based import.
# It will be called during the HTTP request/response,
# so long-running validations will make the page load
# slowly for the user.  Any validations that are slow
# should be run in background jobs during the import
# instead of here.

class CsvManifestValidator
  # @param manifest_uploader [CsvManifestUploader] The manifest that's mounted to a CsvImport record.  See carrierwave gem documentation.  This is basically a wrapper for the CSV file.
  def initialize(manifest_uploader)
    @csv_file = manifest_uploader.file
    @errors = []
    @warnings = []
  end

  # Errors and warnings for the CSV file.
  attr_reader :errors, :warnings
  attr_reader :csv_file

  def validate
    @rows = CSV.read(csv_file.path)

    missing_headers
    unrecognized_headers
  end

  # One record per row
  def record_count
    return nil unless @rows
    @rows.size - 1 # Don't include the header row
  end

  def required_headers
    [
      'Item Ark',
      'Title',
      'Object Type',
      'Parent ARK',
      'Rights.copyrightStatus',
      'File Name'
    ]
  end

  def optional_headers
    [
      'AltIdentifier.local',
      'Coverage.geographic',
      'Date.creation',
      'Date.normalized',
      'Description.caption',
      'Description.fundingNote',
      'Description.latitude',
      'Description.longitude',
      'Description.note',
      'Format.dimensions',
      'Format.extent',
      'Format.medium',
      'Language',
      'Name.photographer',
      'Name.repository',
      'Name.subject',
      'Project Name',
      'Publisher.publisherName',
      'Relation.isPartOf',
      'Rights.countryCreation',
      'Rights.rightsHolderContact',
      'Subject',
      'Type.genre',
      'Type.typeOfResource'
    ]
  end

  def valid_headers
    required_headers + optional_headers
  end

private

  def missing_headers
    required_headers.each do |required_header|
      missing_required_header?(@rows.first, required_header)
    end
  end

  def missing_required_header?(row, header)
    return if row.include?(header)
    @errors << "Missing required column: #{header}.  Your spreadsheet must have this column.  If you already have this column, please check the spelling and capitalization."
  end

  # Warn the user if we find any unexpected headers.
  def unrecognized_headers
    extra_headers = @rows.first - valid_headers
    extra_headers.each do |header|
      @warnings << "The field name \"#{header}\" is not supported.  This field will be ignored, and the metadata for this field will not be imported."
    end
    extra_headers
  end
end