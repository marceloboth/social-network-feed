require 'rails_helper'

describe SocialNetworksController do
  describe "GET index" do
    it "get back a JSON response of the output from the three social networks" do
      get "/"

      expect(json_body).to eq({twitter:[],facebook:[],instagram:[]})
      expect(response.content_type).to eq("application/json; charset=utf-8")
    end
  end
end
