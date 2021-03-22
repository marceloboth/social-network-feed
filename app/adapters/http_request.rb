require 'faraday'

# This class wraps Faraday class.
#
# The idea of doing this is to avoid to bring Faraday to the core logic and create a dependencie on the class
# By having this class if Faraday it's not a good choice anymore it can be replaced without create a big change.
class HttpRequest
  attr_reader :conn, :responses

  def initialize(url:)
    @conn = Faraday.new(url: url) do |builder|
      builder.request :retry, max: MAX_RETRIES, interval: 0.05,
        interval_randomness: 0.5, backoff_factor: 2

      builder.request  :url_encoded
      builder.response :logger
      builder.adapter  :typhoeus
    end
  end

  def run_in_parallel(endpoints:)
    conn.in_parallel do
      @responses = endpoints.map do |endpoint|
        request_data(endpoint)
      end
    end

    @responses
  end

  def run_single_request(endpoint:)
    request_data(endpoint)
  end

  private

  def request_data(endpoint)
    { endpoint: endpoint, data: conn.get("/#{endpoint}") }
  end
end
