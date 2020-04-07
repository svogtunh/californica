# frozen_string_literal: true
require 'rails_helper'

RSpec.describe WorkIndexer do
  let(:solr_document) { indexer.generate_solr_document }
  let(:work) { Work.new(attributes) }
  let(:indexer) { described_class.new(work) }

  describe 'resource type' do
    context 'a work with a resource type' do
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          resource_type: ['http://id.loc.gov/vocabulary/resourceTypes/img']
        }
      end

      it 'indexes a human-readable resource type' do
        expect(solr_document['human_readable_resource_type_tesim']).to eq ['still image']
      end
    end

    # This should never happen in production data,
    # but if it does, handle it gracefully.
    context 'when there is no human-readable value' do
      let(:no_match) { "a resource type that doesn't have a matching value in config/authorities/resource_types.yml" }
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          resource_type: [no_match, 'http://id.loc.gov/vocabulary/resourceTypes/img']
        }
      end

      it 'just returns the original value' do
        expect(solr_document['human_readable_resource_type_tesim']).to contain_exactly(no_match, 'still image')
      end
    end
  end

  describe 'IIIF Text direction' do
    context 'a work with a IIIF Text direction' do
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          iiif_text_direction: 'http://iiif.io/api/presentation/2#leftToRightDirection'
        }
      end

      it 'indexes a human-readable IIIF Text direction' do
        expect(solr_document['human_readable_iiif_text_direction_ssi']).to eq 'left-to-right'
      end
    end

    # This should never happen in production data,
    # but if it does, handle it gracefully.
    context 'when there is no human-readable value' do
      let(:no_match) { "a IIIF Text direction that doesn't have a matching value in config/authorities/iiif_text_directions.yml" }
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          iiif_text_direction: 'http://iiif.io/api/presentation/2#leftToRightDirection'
        }
      end

      it 'just returns the original value' do
        expect(solr_document['human_readable_iiif_text_direction_ssi']).to eq 'left-to-right'
      end
    end
  end

  describe 'Iiif viewing hint' do
    context 'a work with a Iiif viewing hint' do
      let(:attributes) do
        {
          ark: 'ark:/123/458',
          iiif_viewing_hint: 'http://iiif.io/api/presentation/2#pagedHint'
        }
      end

      it 'indexes a human-readable Iiif viewing hint' do
        expect(solr_document['human_readable_iiif_viewing_hint_ssi']).to eq 'paged'
      end
    end

    # This should never happen in production data,
    # but if it does, handle it gracefully.
    context 'when there is no human-readable value' do
      let(:no_match) { "a Iiif viewing hint that doesn't have a matching value in config/authorities/iiif_viewing_hint.yml" }
      let(:attributes) do
        {
          ark: 'ark:/123/458',
          iiif_viewing_hint: 'http://iiif.io/api/presentation/2#pagedHint'
        }
      end

      it 'just returns the original value' do
        expect(solr_document['human_readable_iiif_viewing_hint_ssi']).to eq 'paged'
      end
    end
  end

  describe 'rights statement' do
    context 'a work with a rights statement' do
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          rights_statement: ['http://vocabs.library.ucla.edu/rights/copyrighted']
        }
      end

      it 'indexes a human-readable rights statement' do
        expect(solr_document['human_readable_rights_statement_tesim']).to eq ['copyrighted']
      end
    end

    # This should never happen in production data,
    # but if it does, handle it gracefully.
    context 'when there is no human-readable value' do
      let(:no_match) { "a rights statement that doesn't have a matching value in config/authorities/rights_statements.yml" }
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          rights_statement: [no_match, 'http://vocabs.library.ucla.edu/rights/copyrighted']
        }
      end

      it 'just returns the original value' do
        expect(solr_document['human_readable_rights_statement_tesim']).to contain_exactly(no_match, 'copyrighted')
      end
    end
  end

  describe 'language' do
    context 'a work with a language' do
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          language: ['eng']
        }
      end

      it 'indexes a human-readable language' do
        expect(solr_document['human_readable_language_tesim']).to eq ['English']
      end
    end

    # This should never happen in production data,
    # but if it does, handle it gracefully.
    context 'when there is no human-readable value' do
      let(:no_match) { "a language that doesn't have a matching value in config/authorities/languages.yml" }
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          language: [no_match, 'ang']
        }
      end

      it 'just returns the original value' do
        expect(solr_document['human_readable_language_tesim']).to contain_exactly(
          no_match,
          'English, Old (ca. 450-1100)'
        )
      end
    end
  end

  describe 'latitude and longitude' do
    context 'a work with latitude and longitude' do
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          latitude: ['45.0'],
          longitude: ['-93.0']
        }
      end

      it 'indexes the coordinates in a single field' do
        expect(solr_document['geographic_coordinates_ssim']).to eq '45.0, -93.0'
      end
    end

    context 'a work that is missing latitude' do
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          longitude: ['-93.0']
        }
      end

      it 'doesn\'t index the coordinates' do
        expect(solr_document['geographic_coordinates_ssim']).to eq nil
      end
    end

    context 'a work that is missing longitude' do
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          latitude: ['45.0']
        }
      end

      it 'doesn\'t index the coordinates' do
        expect(solr_document['geographic_coordinates_ssim']).to eq nil
      end
    end
  end

  describe 'integer years for date slider facet' do
    context 'with a normalized_date' do
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          normalized_date: ['1940-10-15']
        }
      end

      it 'indexes the year' do
        expect(solr_document['year_isim']).to eq [1940]
      end
    end

    context 'when normalized_date field is blank' do
      let(:attributes) do
        {
          ark: 'ark:/123/456'
        }
      end

      it 'doesn\'t index the year' do
        expect(solr_document['year_isim']).to eq nil
      end
    end
  end

  describe 'sort_year' do
    context 'with a normalized_date' do
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          normalized_date: ['1940-10-15']
        }
      end

      it 'indexes the earliest year' do
        expect(solr_document['sort_year_isi']).to eq 1940
      end
    end

    context 'when normalized_date field is blank' do
      let(:attributes) do
        {
          ark: 'ark:/123/456'
        }
      end

      it 'doesn\'t index the earliest year' do
        expect(solr_document['sort_year_isi']).to eq nil
      end
    end

    context 'when normalized_date field is a range' do
      let(:attributes) do
        {
          ark: 'ark:/123/456',
          normalized_date: ['1934-06/1937-07']
        }
      end

      it 'indexes the earliest year' do
        expect(solr_document['sort_year_isi']).to eq 1934
      end
    end
  end

  describe 'ark' do
    let(:attributes) do
      {
        ark: 'ark:/123/456'
      }
    end

    it 'indexes as a single value "string" without duplicating the prefix ("ark:/ark:/")' do
      expect(solr_document['ark_ssi']).to eq 'ark:/123/456'
    end

    it 'indexes a simplified id for ursus' do
      expect(solr_document['ursus_id_ssi']).to eq '123-456'
    end
  end

  describe 'sort_title' do
    let(:attributes) do
      {
        ark: 'ark:/123/456',
        title: ['Primary title']
      }
    end

    it 'indexs the only value' do
      expect(solr_document['sort_title_ssort']).to eq 'Primary title'
    end
  end

  describe '#thumbnail_url' do
    let(:attributes) do
      {
        ark: 'ark:/123/456',
        access_copy: access_copy,
        iiif_manifest_url: iiif_manifest_url,
        thumbnail_url_explicit: thumbnail_url_explicit
      }
    end
    let(:access_copy) { nil }
    let(:expected_url) { 'http://test.url/thumb.png' }
    let(:iiif_manifest_url) { nil }
    let(:thumbnail_url_explicit) { nil }

    context 'when the work has thumbnail_url_explicit' do
      let(:thumbnail_url_explicit) { expected_url }

      it 'uses that URL' do
        expect(solr_document['thumbnail_url_ss']).to eq expected_url
      end
    end

    context 'when the work has an image path' do
      let(:access_copy) { 'http://test.url/thumb' }
      let(:expected_url) { "http://test.url/thumb/full/!200,200/0/default.jpg" }

      it 'uses that image' do
        expect(solr_document['thumbnail_url_ss']).to eq expected_url
      end
    end

    context 'when the work has no image' do
      let(:child_work) { instance_double('ChildWork', ark: 'ark:/abc/xyz', thumbnail_url_explicit: expected_url) }
      before { allow(work).to receive(:ordered_members).and_return([child_work]) }

      it 'asks the document\'s children' do
        expect(solr_document['thumbnail_url_ss']).to eq expected_url
      end
    end

    context 'when the document has neither an image path nor children' do
      let(:expected_url) { 'https://iiif.library.ucla.edu/iiif/2/ark%3A%2F21198%2Fzz001dwdv2/full/!200,200/0/default.jpg' }
      let(:iiif_manifest_url) { 'http://test.url/manifest' }
      let(:manifest_response) do
        instance_double('HTTParty::Response', code: 200, parsed_response: {
                          "sequences" => [{
                            "canvases" => [{
                              "label" => "c99_Kemble_Biglow Papers_A2362.tif",
                              "images" => [{
                                "resource" => {
                                  "service" => {
                                    "@id" => "https://iiif.library.ucla.edu/iiif/2/ark%3A%2F21198%2Fzz001dwdv2"
                                  }
                                }
                              }]
                            }]
                          }]
                        })
      end

      before do
        allow(HTTParty).to receive(:get).with(iiif_manifest_url).and_return(manifest_response)
      end

      it 'queries the IIIF manifest' do
        expect(solr_document['thumbnail_url_ss']).to eq expected_url
      end
    end

    context 'when no thumbnail can be generated' do
      it 'returns nil' do
        expect(solr_document['thumbnail_url_ss']).to eq nil
      end
    end
  end

  describe '#thumbnail_from_access_copy' do
    let(:attributes) do
      {
        ark: 'ark:/123/456',
        access_copy: access_copy,
        thumbnail_url_explicit: nil
      }
    end

    context 'when there is an access_copy' do
      let(:access_copy) { 'http://test.url/image' }

      it 'calls thumbnail_with_suffix with the access_copy' do
        allow(indexer).to receive(:thumbnail_with_suffix).with(access_copy).and_return('bingo')
        expect(indexer.thumbnail_from_access_copy).to eq 'bingo'
      end
    end

    context 'when there isn\'t an access_copy' do
      let(:access_copy) { nil }

      it 'returns nil' do
        expect(indexer.thumbnail_from_access_copy).to be_nil
      end
    end
  end

  describe '#thumbnail_from_child_works' do
    let(:attributes) do
      {
        ark: 'ark:/123/456',
        access_copy: nil,
        thumbnail_url_explicit: nil
      }
    end
    let(:child_with_thumbnail) { FactoryBot.build('child_work', thumbnail_url_explicit: 'thumb.png') }
    let(:child_without_thumbnail) { FactoryBot.build('child_work', thumbnail_url_explicit: nil, access_copy: nil, ordered_members: []) }

    context 'where there are no children' do
      it 'returns nil' do
        allow(work).to receive(:ordered_members).and_return([])
        expect(indexer.thumbnail_from_child_works).to be_nil
      end
    end

    context 'when the children do not have thumbnails' do
      it 'returns nil' do
        allow(work).to receive(:ordered_members).and_return([child_without_thumbnail])
        expect(indexer.thumbnail_from_child_works).to be_nil
      end
    end

    context 'when a child work has a thumbnail' do
      it 'returns thumbnail from the first child that has one' do
        allow(work).to receive(:ordered_members).and_return([child_without_thumbnail, child_with_thumbnail])
        expect(indexer.thumbnail_from_child_works).to eq 'thumb.png'
      end
    end
  end

  describe '#thumbnail_from_manifest' do
    let(:attributes) do
      {
        ark: 'ark:/123/456',
        access_copy: nil,
        iiif_manifest_url: iiif_manifest_url,
        thumbnail_url_explicit: nil
      }
    end
    let(:access_copy) { nil }
    let(:iiif_manifest_url) { 'http://test.url/manifest' }

    context 'when there is not IIIF manifest URL' do
      let(:iiif_manifest_url) { nil }

      it 'returns nil' do
        expect(indexer.thumbnail_from_manifest).to be_nil
      end
    end

    context 'when the call to the manifest service fails' do
      let(:manifest_response) { instance_double('HTTParty::Response', code: 404) }

      before { allow(HTTParty).to receive(:get).with(iiif_manifest_url).and_return(manifest_response) }

      it 'returns nil' do
        expect(indexer.thumbnail_from_manifest).to be_nil
      end
    end

    context 'when the parsed manifest doesn\'t have the expected content' do
      let(:manifest_response) do
        instance_double('HTTParty::Response', code: 200, parsed_response: {
                          "sequences" => [{
                            "canvases" => [{
                              "images" => [{
                                "resource" => {
                                  "service" => {
                                    "@id" => "https://iiif.library.ucla.edu/iiif/2/ark%3A%2F21198%2Fzz001dwdv2"
                                  }
                                }
                              }]
                            }]
                          }]
                        })
      end

      before { allow(HTTParty).to receive(:get).with(iiif_manifest_url).and_return(manifest_response) }

      it 'returns nil' do
        expect(indexer.thumbnail_from_manifest).to be_nil
      end
    end

    context 'when the manifest has an image titled "f. 001r"' do
      let(:manifest_response) do
        instance_double('HTTParty::Response', code: 200, parsed_response: {
                          "sequences" => [{
                            "canvases" => [
                              {
                                "label" => "abc",
                                "images" => [{
                                  "resource" => {
                                    "service" => {
                                      "@id" => "https://iiif.library.ucla.edu/iiif/2/ark%3A%2F21198%2Fzz001dwdv2"
                                    }
                                  }
                                }]
                              },
                              {
                                "label" => "f. 001r",
                                "images" => [{
                                  "resource" => {
                                    "service" => {
                                      "@id" => "target"
                                    }
                                  }
                                }]
                              }
                            ]
                          }]
                        })
      end

      before { allow(HTTParty).to receive(:get).with(iiif_manifest_url).and_return(manifest_response) }

      it 'uses that image' do
        expect(indexer.thumbnail_from_manifest).to eq 'target/full/!200,200/0/default.jpg'
      end
    end

    context 'when the manifest doesn\'t have "f.001r"' do
      let(:manifest_response) do
        instance_double('HTTParty::Response', code: 200, parsed_response: {
                          "sequences" => [{
                            "canvases" => [
                              {
                                "label" => "abc",
                                "images" => [{
                                  "resource" => {
                                    "service" => {
                                      "@id" => "target"
                                    }
                                  }
                                }]
                              },
                              {
                                "label" => "def",
                                "images" => [{
                                  "resource" => {
                                    "service" => {
                                      "@id" => "not.target"
                                    }
                                  }
                                }]
                              }
                            ]
                          }]
                        })
      end

      before { allow(HTTParty).to receive(:get).with(iiif_manifest_url).and_return(manifest_response) }

      it 'uses the first image in the manifest' do
        expect(indexer.thumbnail_from_manifest).to eq 'target/full/!200,200/0/default.jpg'
      end
    end
  end

  describe '#thumbnail_with_suffix' do
    let(:attributes) do
      { ark: 'ark:/123/456' }
    end

    it 'adds the IIIF parameters to the url' do
      expect(indexer.thumbnail_with_suffix('target')).to eq 'target/full/!200,200/0/default.jpg'
    end

    it 'returns nil if given a nil argument' do
      expect(indexer.thumbnail_with_suffix(nil)).to be_nil
    end
  end
end
