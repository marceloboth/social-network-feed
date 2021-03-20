class SocialNetworkService
  SOCIAL_MEDIAS = %w(twitter facebook instagram)
  MAX_RETRIES = 5

  attr_accessor :parsed_response

  def initialize(http_concurrent)
    @http_concurrent = http_concurrent
    @parsed_response = {}
  end

  def call
    responses = @http_concurrent.run_in_parallel(endpoints: SOCIAL_MEDIAS)
    responses = validate_responses(responses)
    format_response(responses)
  end

  private

  def validate_responses(responses)
    failed_responses = responses.select { |response| response[:data].status == 500 }

    failed_responses.each do |response|
      new_response = retry_response(response)
      responses.delete_if { |res| res[:endpoint] == new_response[:endpoint] }
      responses << new_response
    end

    responses
  end

  def retry_response(response)
    retried_response = @http_concurrent.run_single_request(endpoint: response[:endpoint])

    raise ResponseError if retried_response[:data].status == 500

    retried_response
  rescue ResponseError
    retries ||= 1
    return [] if retries == MAX_RETRIES
    retries += 1
    retry
  end

  def format_response(responses)
    responses.each do |response|
      parse_response(endpoint: response[:endpoint] , response: response[:data])
    end

    @parsed_response
  end

  def parse_response(endpoint:, response:)
    return @parsed_response.store(endpoint.to_sym, []) unless response.status == 200

    @parsed_response.store(endpoint.to_sym, JSON.parse(response.body, symbolize_names: true))
  end
end
