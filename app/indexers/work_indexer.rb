# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work Work`
class WorkIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # See https://github.com/UCLALibrary/californica/blob/master/solr/config/schema.xml#194
  # for extensions that can be used below

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['sort_year_isi'] = years.to_a.min
      solr_doc['geographic_coordinates_ssim'] = coordinates
      solr_doc['human_readable_language_sim'] = human_readable_language
      solr_doc['human_readable_language_tesim'] = human_readable_language
      solr_doc['human_readable_resource_type_sim'] = human_readable_resource_type
      solr_doc['human_readable_resource_type_tesim'] = human_readable_resource_type
      solr_doc['human_readable_iiif_text_direction_ssi'] = human_readable_iiif_text_direction
      solr_doc['human_readable_iiif_viewing_hint_ssi'] = human_readable_iiif_viewing_hint
      solr_doc['human_readable_rights_statement_tesim'] = human_readable_rights_statement
      solr_doc['sort_title_ssort'] = object.title.first
      solr_doc['ursus_id_ssi'] = Californica::IdGenerator.blacklight_id_from_ark(object.ark)
      solr_doc['year_isim'] = years
      solr_doc['thumbnail_url_ss'] = thumbnail_url
    end
  end

  def coordinates
    return unless object.latitude.first && object.longitude.first
    [object.latitude.first, object.longitude.first].join(', ')
  end

  def human_readable_language
    terms = Qa::Authorities::Local.subauthority_for('languages').all

    object.language.map do |lang|
      term = terms.find { |entry| entry[:id] == lang }
      term.blank? ? lang : term[:label]
    end
  end

  def human_readable_resource_type
    terms = Qa::Authorities::Local.subauthority_for('resource_types').all

    object.resource_type.map do |rt|
      term = terms.find { |entry| entry[:id] == rt }
      term.blank? ? rt : term[:label]
    end
  end

  def human_readable_iiif_text_direction
    terms = Qa::Authorities::Local.subauthority_for('iiif_text_directions').all
    term = terms.find { |entry| entry[:id] == object.iiif_text_direction }
    term.blank? ? object.iiif_text_direction : term[:label]
  end

  def human_readable_iiif_viewing_hint
    terms = Qa::Authorities::Local.subauthority_for('iiif_viewing_hints').all
    term = terms.find { |entry| entry[:id] == object.iiif_viewing_hint }
    term.blank? ? object.iiif_viewing_hint : term[:label]
  end

  def human_readable_rights_statement
    terms = Qa::Authorities::Local.subauthority_for('rights_statements').all

    object.rights_statement.map do |rs|
      term = terms.find { |entry| entry[:id] == rs }
      term.blank? ? rs : term[:label]
    end
  end

  def thumbnail_url
    # this record has an image path attached
    iiif_url_base = Californica::ManifestBuilderService.new(curation_concern: object).iiif_url
    children = Array.wrap(object.members).clone
    until iiif_url_base || children.empty?
      child = children.shift
      iiif_url_base = Californica::ManifestBuilderService.new(curation_concern: child).iiif_url
    end

    return nil unless iiif_url_base
    "#{iiif_url_base}/full/!200,200/0/default.jpg"
  end

  # The 'to_a' is needed to force ActiveTriples::Relation to resolve into the String value(s), else you get an error trying to parse the date.
  def years
    integer_years = YearParser.integer_years(object.normalized_date.to_a)
    return nil if integer_years.blank?
    integer_years
  end
end
