require 'rails_helper'

describe SocialNetworksController do
  describe "GET index" do
    include_context 'http requests'

    it "get back a JSON response of the output from the three social networks" do
      allow_any_instance_of(SocialNetworkService).to receive(:call).and_return({
        twitter: twitter_body,
        facebook: facebook_body,
        instagram:[]
      })

      get "/"

      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(json_body).to eq({
        twitter: twitter_body,
        facebook: facebook_body,
        instagram:[]
      })
    end
  end
end
