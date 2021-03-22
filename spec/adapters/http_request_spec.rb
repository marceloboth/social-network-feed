require 'rails_helper'

describe "HttpRequest", :adapter do
  subject { HttpRequest.new(url: "https://takehome.io") }

  include_context 'http requests'

  describe "#run_in_parallel" do
    before do
      stub_twitter_feed
      stub_facebook_feed
    end

    let(:endpoints) { %w(twitter facebook) }
    let(:responses) { subject.run_in_parallel(endpoints: endpoints) }
    let(:first_response) { responses.first }
    let(:last_response) { responses.last }

    it "processes endpoints request" do
      expect(first_response[:endpoint]).to eql("twitter")
      expect(first_response[:data]).to include(body: twitter_body.to_json)

      expect(last_response[:endpoint]).to eql("facebook")
      expect(last_response[:data]).to include(body: facebook_body.to_json)
    end
  end

  describe "#run_single_request" do
    before { stub_facebook_feed }

    let(:response) { subject.run_single_request(endpoint: "facebook") }

    it "process a single request" do
      expect(response[:endpoint]).to eql("facebook")
      expect(response[:data]).to include(body: facebook_body.to_json)
    end
  end
end
