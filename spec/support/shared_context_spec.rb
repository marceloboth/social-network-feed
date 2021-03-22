shared_context 'http requests' do
  let(:twitter_body) do
    [
      {username: "someone", tweet: "blabla"},
      {username: "someone", tweet: "extra tweet"},
    ]
  end

  let(:facebook_body) do 
    [
      {name: "Some friend", status: "working hard"},
      {name: "Some friend", status: "sleeping hard"}
    ]
  end

  let(:stub_twitter_feed) do
    stub_request(:get, "https://takehome.io/twitter").with(
      headers: {
        'Expect'=>'',
        'User-Agent'=>'Faraday v1.3.0'
      }).to_return(status: 200, body: twitter_body.to_json)
  end

  let(:stub_facebook_feed) do
    stub_request(:get, "https://takehome.io/facebook").with(
      headers: {
        'Expect'=>'',
        'User-Agent'=>'Faraday v1.3.0'
      }).to_return(status: 200, body: facebook_body.to_json)
  end

  let(:stub_with_one_failed_facebook_feed) do
    stub_request(:get, "https://takehome.io/facebook").with(
      headers: {
        'Expect'=>'',
        'User-Agent'=>'Faraday v1.3.0'
      }).to_return(status: 500, body: "I am trapped in a social media factory send help").times(2).then
        .to_return(status: 200, body: facebook_body.to_json)
  end

  let(:stub_instagram_feed) do
    stub_request(:get, "https://takehome.io/instagram").with(
      headers: {
        'Expect'=>'',
        'User-Agent'=>'Faraday v1.3.0'
      }).to_return(status: 404, body: "Page not found")
  end
end
