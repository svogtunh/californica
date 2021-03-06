# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImporterDocumentationController do
  let(:admin_user) { FactoryBot.create(:admin) }
  before { sign_in admin_user }
  describe "GET csv" do
    it "provides a csv download" do
      get :csv
      expect(response.headers['Content-Type']).to eq('text/csv; charset=utf-8')
      expect(response.headers['Content-Disposition']).to eq('attachment; filename="import_manifest.csv"')
    end
  end
end
