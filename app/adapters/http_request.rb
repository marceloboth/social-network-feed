require 'faraday'

class HttpRequest
  attr_reader :conn, :responses

  def initialize(url:)
    @conn = Faraday.new(url: url) do |builder|
      builder.request :retry, max: MAX_RETRIES, interval: 0.05,
        interval_randomness: 0.5, backoff_factor: 2,
        exceptions: [ResponseError, 'Timeout::Error']

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
