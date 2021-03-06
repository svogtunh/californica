# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  class WorkPresenter < Hyrax::WorkShowPresenter
    delegate(
      :access_copy,
      :alternative_title,
      :architect,
      :ark,
      :author,
      :binding_note,
      :caption,
      :collation,
      :colophon,
      :commentator,
      :composer,
      :condition_note,
      :dimensions,
      :dlcs_collection_name,
      :extent,
      :featured_image,
      :finding_aid_url,
      :foliation,
      :funding_note,
      :genre,
      :geographic_coordinates,
      :iiif_manifest_url,
      :iiif_range,
      :illustrations_note,
      :iiif_viewing_hint,
      :illuminator,
      :local_identifier,
      :location,
      :lyricist,
      :masthead_parameters,
      :medium,
      :named_subject,
      :normalized_date,
      :opac_url,
      :page_layout,
      :photographer,
      :place_of_origin,
      :preservation_copy,
      :provenance,
      :repository,
      :representative_image,
      :resource_type,
      :rights_country,
      :rights_holder,
      :rubricator,
      # :local_rights_statement, # This invokes License renderer from hyrax gem
      :scribe,
      :subject_topic,
      :subject_geographic,
      :subject_temporal,
      :summary,
      :support,
      :tagline,
      :translator,
      :toc,
      :iiif_text_direction,
      :uniform_title,
      to: :solr_document
    )
  end
end
