service :twitter do |data, payload|
  repository = payload['repository']['name']
  url = URI.parse("http://twitter.com/statuses/update.xml")

  payload['commits'].each do |commit|
    commit = commit.last
    begin
      Timeout::timeout(2) do
        github_url = Net::HTTP.get "tinyurl.com", "/api-create.php?url=#{commit['url']}"
      end
    rescue
    end
    github_url ||= commit['url']
    status = "[#{repository}] #{github_url} #{commit['author']['name']} - #{commit['message']}"

    req = Net::HTTP::Post.new(url.path)
    req.basic_auth(data['username'], data['password'])
    req.set_form_data('status' => status, 'source' => 'github')

    Net::HTTP.new(url.host, url.port).start { |http| http.request(req) }
  end
end
