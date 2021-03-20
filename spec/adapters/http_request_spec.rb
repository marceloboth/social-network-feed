require 'rails_helper'

describe "HttpRequest", :adapter do
  subject { HttpRequest.new(url: "https://takehome.io") }

  let(:stub_twitter_feed) do
    stub_request(:get, "https://takehome.io/twitter").with(
          headers: {
            'Expect'=>'',
            'User-Agent'=>'Faraday v1.3.0'
          }).to_return(status: 200, body: [{username: "someone", tweet: "blabla"}])
  end

  let(:stub_facebook_feed) do
   stub_request(:get, "https://takehome.io/facebook").with(
          headers: {
            'Expect'=>'',
            'User-Agent'=>'Faraday v1.3.0'
          }).to_return(status: 200, body: [{name: "Some friend", status: "working hard"}])
  end

  describe "#run_in_parallel" do
    before do
      stub_twitter_feed
      stub_facebook_feed
    end

    let(:endpoints) { %w(twitter facebook) }

    it "processes endpoints request" do
      responses = subject.run_in_parallel(endpoints: endpoints)

      first_response = responses.first
      expect(first_response[:endpoint]).to eql("twitter")
      expect(first_response[:data]).to include(body: [{tweet: "blabla", username: "someone"}])

      last_response = responses.last
      expect(last_response[:endpoint]).to eql("facebook")
      expect(last_response[:data]).to include(body: [{name: "Some friend", status: "working hard"}])
    end
  end

  describe "#run_single_request" do
    before { stub_facebook_feed }

    it "process a single request" do
      response = subject.run_single_request(endpoint: "facebook")

      expect(response[:endpoint]).to eql("facebook")
      expect(response[:data]).to include(body: [{name: "Some friend", status: "working hard"}])
    end
  end
end
