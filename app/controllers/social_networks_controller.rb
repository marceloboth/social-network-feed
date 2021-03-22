class SocialNetworksController < ApplicationController
  def index
    http_request = HttpRequest.new(url: TAKEHOME_URL)
    render json: SocialNetworkService.new(http_request).call
  end
end
