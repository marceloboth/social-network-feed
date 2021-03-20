require 'rails_helper'

describe SocialNetworksController do
  describe "GET index" do
    it "get back a JSON response of the output from the three social networks" do
      allow_any_instance_of(SocialNetworkService).to receive(:call).and_return({
        twitter:[{tweet: "blabla", username: "someone"}],
        facebook:[{name: "Some friend", status: "working hard"}],
        instagram:[]
      })

      get "/"

      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(json_body).to eq({
        twitter:[{tweet: "blabla", username: "someone"}],
        facebook:[{name: "Some friend", status: "working hard"}],
        instagram:[]
      })
    end
  end
end
