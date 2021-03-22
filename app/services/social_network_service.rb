class SocialNetworkService
  attr_accessor :parsed_response

  def initialize(http_request)
    # HTTP Request class is injected to this class
    #
    # By doing so, it not depend directly to HttpRequest class,
    # the only thing that metters is that the injected object responds to the expected methods:
    # - run_in_parallel
    # - run_single_request
    #
    # This will allow to change or to use other implementations of a "http request" without adding more complexity.
    @http_request = http_request
    @parsed_response = {}
  end

  def call
    responses = @http_request.run_in_parallel(endpoints: TAKEHOME_ENDPOINTS)
    responses = validate_responses(responses)
    format_response(responses)
  end

  private

  # this method will validate and retry a request when something went wrong.
  # The number of times to retry is defined on MAX_RETRIES constant.
  def validate_responses(responses)
    failed_responses = responses.select { |response| !response[:data].success? }

    failed_responses.each do |response|
      new_response = retry_response(response)
      responses.delete_if { |res| res[:endpoint] == new_response[:endpoint] }
      responses << new_response
    end

    responses
  end

  def retry_response(response)
    retried_response = @http_request.run_single_request(endpoint: response[:endpoint])

    raise ResponseError unless retried_response[:data].success?

    retried_response
  rescue ResponseError
    retries ||= 1
    Rails.logger.info "retries for #{response[:endpoint]}: #{retries}"
    return retried_response if retries == MAX_RETRIES
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
    return @parsed_response.store(endpoint.to_sym, []) unless response.success?

    @parsed_response.store(endpoint.to_sym, JSON.parse(response.body, symbolize_names: true))
  end
end
