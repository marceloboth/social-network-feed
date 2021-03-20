class SocialNetworksController < ApplicationController
  def index
    http_request = HttpRequest.new(url: "https://takehome.io")
    render json: SocialNetworkService.new(http_request).call
  end
end
