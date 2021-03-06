# frozen_string_literal: true
RSpec.shared_examples 'a work with UCLA metadata' do
  context 'UCLA metadata attributes' do
    describe '#genre' do
      let(:values) { ['SciFi'] }

      it 'can set a genre' do
        expect { work.genre = values }
          .to change { work.genre.to_a }
          .to contain_exactly(*values)
      end

      it 'sets to edm:hasType' do
        expect { work.genre = values }
          .to change { work.resource.predicates }
          .to include RDF::Vocab::EDM.hasType
      end
    end

    it "has access_copy" do
      work.access_copy = 'dlmasters/ethiopian/masters/abc123.tif'
      expect(work.access_copy).to eq 'dlmasters/ethiopian/masters/abc123.tif'
      expect(work.resource.dump(:ttl)).to match(/www.europeana.eu\/schemas\/edm\/object/)
    end

    it "has a single-valued ark" do
      work.ark = 'ark:/abc/123456'
      expect(work.ark).to eq 'ark:/abc/123456'
      expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/elements\/1.1\/identifier/)
    end

    it "has a single-valued binding_note" do
      work.binding_note = 'binding note'
      expect(work.binding_note).to eq 'binding note'
      expect(work.resource.dump(:ttl)).to match(/http:\/\/marc21rdf\.info\/elements\/5XX\/M563__a/)
    end

    it "alternative_title" do
      work.alternative_title = ['Alternative title']
      expect(work.alternative_title).to include 'Alternative title'
      expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/alternative/)
    end

    it "has architect" do
      work.architect = ['Imhotep']
      expect(work.architect).to include 'Imhotep'
      expect(work.resource.dump(:ttl)).to match(/id.loc.gov\/vocabulary\/relators\/arc/)
    end

    it "has publisher" do
      work.publisher = ['publisher']
      expect(work.publisher).to include 'publisher'
      expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/elements\/1.1\/publisher/)
    end

    it "has extent" do
      work.extent = ['1 photograph']
      expect(work.extent).to include '1 photograph'
      expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/elements\/1.1\/format/)
    end

    it "has preservation_copy" do
      work.preservation_copy = 'dlmasters/ethiopian/masters/abc123.tif'
      expect(work.preservation_copy).to eq 'dlmasters/ethiopian/masters/abc123.tif'
      expect(work.resource.dump(:ttl)).to match(/https\:\/\/pcdm\.org\/models\#hasFile/)
    end

    it "has repository" do
      work.repository = ['a repository']
      expect(work.repository).to include 'a repository'
      expect(work.resource.dump(:ttl)).to match(/loc.gov\/mods\/rdf\/v1#locationCopySublocation/)
    end

    it "has normalized date" do
      work.normalized_date = ['01/01/01']
      expect(work.normalized_date).to include '01/01/01'
      expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/elements\/1.1\/date/)
    end

    it "has local_identifier" do
      work.local_identifier = ['local_identifier']
      expect(work.local_identifier).to include 'local_identifier'
      expect(work.resource.dump(:ttl)).to match(/id.loc.gov\/vocabulary\/identifiers\/local/)
    end

    it "has funding_note" do
      work.funding_note = ['funding_note']
      expect(work.funding_note).to include 'funding_note'
      expect(work.resource.dump(:ttl)).to match(/bibfra.me\/vocab\/marc\/fundingInformation/)
    end

    it "has latitude" do
      work.latitude = ['39']
      expect(work.latitude).to include '39'
      expect(work.resource.dump(:ttl)).to match(/w3.org\/2003\/12\/exif\/ns#gpsLatitude/)
    end

    it "has longitude" do
      work.longitude = ['-94']
      expect(work.longitude).to include '-94'
      expect(work.resource.dump(:ttl)).to match(/w3.org\/2003\/12\/exif\/ns#gpsLongitude/)
    end

    it "has named subject" do
      work.named_subject = ['Person, A']
      expect(work.named_subject).to include 'Person, A'
      expect(work.resource.dump(:ttl)).to match(/loc.gov\/mods\/rdf\/v1#subjectName/)
    end

    it "has rights country" do
      work.rights_country = ['rights_country']
      expect(work.rights_country).to include 'rights_country'
      expect(work.resource.dump(:ttl)).to match(/ebu.ch\/metadata\/ontologies\/ebucore\/ebucore#rightsType/)
    end

    it "has rights holder" do
      work.rights_holder = ['rights_holder']
      expect(work.rights_holder).to include 'rights_holder'
      expect(work.resource.dump(:ttl)).to match(/ebu.ch\/metadata\/ontologies\/ebucore\/ebucore#hasRightsHolder/)
    end

    it "has medium" do
      work.medium = ['Capacitance Electronic Disc']
      expect(work.medium).to include 'Capacitance Electronic Disc'
      expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/medium/)
    end

    it "has dimensions" do
      work.dimensions = ['2x4']
      expect(work.dimensions).to include '2x4'
      expect(work.resource.dump(:ttl)).to match(/loc.gov\/mods\/rdf\/v1#physicalExtent/)
    end

    it "has caption" do
      work.caption = ['a caption']
      expect(work.caption).to include 'a caption'
      expect(work.resource.dump(:ttl)).to match(/schema.org\/caption/)
    end

    it "has location" do
      work.location = ['a location']
      expect(work.location).to include 'a location'
      expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/coverage/)
    end

    it "has photographer" do
      work.photographer = ['Ansel Adams']
      expect(work.photographer).to include 'Ansel Adams'
      expect(work.resource.dump(:ttl)).to match(/id.loc.gov\/vocabulary\/relators\/pht.html/)
    end

    it "has a collection name" do
      work.dlcs_collection_name = ["Connell (Will) Papers, 1928-1961"]
      expect(work.dlcs_collection_name).to include "Connell (Will) Papers, 1928-1961"
      expect(work.resource.dump(:ttl)).to match(/bib.schema.org\/Collection/)
    end

    it "has services_contact" do
      work.services_contact = ['UCLA Charles E. Young Research Library Department of Special Collections']
      expect(work.services_contact).to include 'UCLA Charles E. Young Research Library Department of Special Collections'
      expect(work.resource.dump(:ttl)).to match(/www.ebu.ch\/metadata\/ontologies\/ebucore\/ebucore\#hasRightsContact/)
    end
  end
end
