require 'rails_helper'

describe "SocialNetworksService", :service do
  subject { SocialNetworkService.new(http_request) }

  let(:http_request) { HttpRequest.new(url: TAKEHOME_URL) }

  include_context 'http requests'

  describe "#call" do
    before do
      stub_twitter_feed
      stub_facebook_feed
      stub_instagram_feed
    end

    it "returns a hash with all social medias" do
      expect(subject.call).to eq({
        twitter: twitter_body,
        facebook: facebook_body,
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
        twitter: twitter_body,
        facebook: facebook_body,
        instagram:[]
      })
    end
  end
end
