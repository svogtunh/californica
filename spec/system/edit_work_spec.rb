# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Edit an existing work', :clean, type: :system, js: true do
  let(:work) { Work.create!(work_attrs) }

  let(:work_attrs) do
    {
      alternative_title: ['Alternative title'],
      architect: ['Old Architect'],
      ark: 'ark:/abc/3456',
      author: ['Old Author'],
      caption: ['Old Caption'],
      contributor: ['Old Contributor'],
      creator: ['Old Creator'],
      date_created: ['Old Creation Date'],
      description: ['Old Desc'],
      dimensions: ['Old Dim'],
      extent: ['Old Extent'],
      funding_note: ['Old Fund Note'],
      genre: ['Old Genre'],
      language: ['Old Lang'],
      location: ['Old Loc'],
      latitude: ['Old Lat'],
      longitude: ['Old Long'],
      local_identifier: ['Old Local ID'],
      master_file_path: 'dlmasters/ethiopian/masters/abc123.tif',
      medium: ['Old Medium'],
      named_subject: ['Old Name/Subj'],
      normalized_date: ['Old Normalized Date'],
      photographer: ['Old Photographer'],
      place_of_origin: ['Old Place of origin'],
      publisher: ['Old Pub'],
      repository: ['Old Repository'],
      resource_type: ['http://id.loc.gov/vocabulary/resourceTypes/img'], # "image"
      rights_country: ['Old Rights Country'],
      rights_holder: ['Old Rights Holder'],
      rights_statement: ['http://vocabs.library.ucla.edu/rights/copyrighted'], # "copyrighted"
      subject: ['Old Subj'],
      summary: ['Old Summary'],
      support: ['Old Support'],
      text_direction: ['Old Text direction'],
      title: ['Old Title'],
      uniform_title: ['Old Uniform title']
    }
  end

  include_context 'with workflow'

  context 'logged in as an admin user' do
    let(:admin) { FactoryBot.create :admin }

    before { login_as admin }

    scenario 'successfully edits the work' do
      visit edit_hyrax_work_path(work.id)

      # When the form first loads, it should contain all the old values
      expect(find_field('Title').value).to eq 'Old Title'
      expect(find_field('Ark').value).to eq 'ark:/abc/3456'
      expect(page.all(:css, 'div.select.work_rights_statement').first.has_content?('copyrighted')).to eq true

      click_on 'Additional fields'
      expect(find(:xpath, '//label[@for="work_based_near"]').text).to eq 'Based Near'
      expect(first(:css, '#work_description').value).to eq 'Old Desc'
      expect(find_field('Alternative title').value).to eq 'Alternative title'
      expect(find_field('Architect').value).to eq 'Old Architect'
      expect(find_field('Author').value).to eq 'Old Author'
      expect(find_field('Date Created').value).to eq 'Old Creation Date'
      expect(find_field('Subject').value).to eq 'Old Subj'
      expect(find_field('Language').value).to eq 'Old Lang'
      expect(find_field('Resource type').value).to eq ['http://id.loc.gov/vocabulary/resourceTypes/img']
      expect(find_field('Extent').value).to eq 'Old Extent'
      expect(find_field('Caption').value).to eq 'Old Caption'
      expect(find_field('Dimensions').value).to eq 'Old Dim'
      expect(find_field('Funding Note').value).to eq 'Old Fund Note'
      expect(find_field('Genre').value).to eq 'Old Genre'
      expect(find_field('Latitude').value).to eq 'Old Lat'
      expect(find_field('Longitude').value).to eq 'Old Long'
      expect(find_field('Local Identifier').value).to eq 'Old Local ID'
      expect(find_field('Master file path').value).to eq 'dlmasters/ethiopian/masters/abc123.tif'
      expect(find_field('Medium').value).to eq 'Old Medium'
      expect(find_field('Name (Subject)').value).to eq 'Old Name/Subj'
      expect(find_field('Normalized Date').value).to eq 'Old Normalized Date'
      expect(find_field('Publisher').value).to eq 'Old Pub'
      expect(find_field('Photographer').value).to eq 'Old Photographer'
      expect(find_field('Place of origin').value).to eq 'Old Place of origin'
      expect(find_field('Repository').value).to eq 'Old Repository'
      expect(find_field('Location').value).to eq 'Old Loc'
      expect(find_field('Rights (country of creation)').value).to eq 'Old Rights Country'
      expect(find_field('Rights Holder').value).to eq 'Old Rights Holder'
      expect(find_field('Summary').value).to eq 'Old Summary'
      expect(find_field('Text direction').value).to eq 'Old Text direction'
      expect(find_field('Uniform title').value).to eq 'Old Uniform title'

      # Edit some fields in the form
      fill_in 'Title', with: 'New Title'
      fill_in 'Dimensions', with: 'New Dim'
      fill_in 'Ark', with: 'ark:/not/myark' # This field is read-only and an attempt to change it should not result in a change

      # Submit the form.  When the page reloads, it should be on the show page.
      click_on 'Save changes'
      expect(page).to have_current_path(hyrax_work_path(work.id, locale: I18n.locale))

      # When the show page loads, it should have the new values
      expect(page).to     have_content 'New Title'
      expect(page).to_not have_content 'Old Title'
      expect(page).to     have_content 'New Dim'
      expect(page).to_not have_content 'Old Dim'
      expect(page).to     have_content 'ark:/abc/3456'
      expect(page).to_not have_content 'ark:/not/myark'
    end
  end
end
