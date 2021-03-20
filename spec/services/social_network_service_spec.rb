require 'rails_helper'

describe "SocialNetworksService", :service do
  subject { SocialNetworkService.new(http_request) }

  let(:http_request) { HttpRequest.new(url: "https://takehome.io") }

  let(:stub_twitter_feed) do
    stub_request(:get, "https://takehome.io/twitter").with(
          headers: {
            'Expect'=>'',
            'User-Agent'=>'Faraday v1.3.0'
          }).to_return(status: 200, body: [{username: "someone", tweet: "blabla"}].to_json)
  end

  let(:stub_facebook_feed) do
   stub_request(:get, "https://takehome.io/facebook").with(
          headers: {
            'Expect'=>'',
            'User-Agent'=>'Faraday v1.3.0'
          }).to_return(status: 200, body: [{name: "Some friend", status: "working hard"}].to_json)
  end

  let(:stub_with_one_failed_facebook_feed) do
   stub_request(:get, "https://takehome.io/facebook").with(
          headers: {
            'Expect'=>'',
            'User-Agent'=>'Faraday v1.3.0'
          }).to_return(status: 500, body: "I am trapped in a social media factory send help").times(2).then
          .to_return(status: 200, body: [{name: "Some friend", status: "working hard"}].to_json)
  end

  let(:stub_instagram_feed) do
   stub_request(:get, "https://takehome.io/instagram").with(
          headers: {
            'Expect'=>'',
            'User-Agent'=>'Faraday v1.3.0'
          }).to_return(status: 404, body: "Page not found")
  end

  describe "#call" do
    before do
      stub_twitter_feed
      stub_facebook_feed
      stub_instagram_feed
    end

    it "returns a hash with all social medias" do
      expect(subject.call).to eq({
        twitter:[{tweet: "blabla", username: "someone"}],
        facebook:[{name: "Some friend", status: "working hard"}],
        instagram:[]
      })
    end
  end

  describe "#call with retry" do
    before do
      stub_twitter_feed
      stub_with_one_failed_facebook_feed
      stub_instagram_feed
    end

    it "returns a hash with all social medias" do
      expect(subject.call).to eq({
        twitter:[{tweet: "blabla", username: "someone"}],
        facebook:[{name: "Some friend", status: "working hard"}],
        instagram:[]
      })
    end
  end
end
