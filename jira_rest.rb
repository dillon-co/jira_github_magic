#!/usr/bin/env ruby
require "HTTParty"
require 'net/http'
require 'uri'
require 'pry'
require 'pry-byebug'

class JiraBoardItems
  attr_accessor :url, :username, :api_token, :uri, :issue_user
  def initialize
    @url = "https://randallreilly.atlassian.net/rest/agile/1.0/board/109/issue?maxResults=100&fields=summary,status,assignee,resolution"
    @username = 'dilloncortez@randallreilly.com'
    # @url = "https://randallreilly.atlassian.net/rest/agile/1.0/board/109/issue?maxResults=100"
    @issue_user = @username
    @api_token = ENV['JIRA_TOKEN']
    @uri = URI.parse(url)
  end

  def jira_board
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(username, api_token)
    request["Accept"] = "application/json"
    # request["maxResults"] = 100
    # request.body = JSON.dump()
    req_options = {
      use_ssl: uri.scheme == "https"
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    JSON.parse(response.body)
  end

  def issues
    jb = jira_board
    jb['issues'].map do |issue|
      is_in_backlog = issue['fields']['status']['name'] == 'Backlog'
      assignee = issue['fields']['assignee'] ? issue['fields']['assignee']['emailAddress'] : nil
      status = issue['fields']['status']['statusCategory']['name']
      summary = issue['fields']['summary']
      {key: issue['key'], summary: summary,assignee: assignee, status: status, backlog?: is_in_backlog}
    end
  end

  def see_issues_for(user=issue_user)
    puts "\n\nhttps://randallreilly.atlassian.net/secure/RapidBoard.jspa?rapidView=109&projectKey=ATS"
    puts "\n\n#{"~"*50}"
    issues.select{ |issue| issue[:assignee] == user && !issue[:backlog?] }.each_with_index do |issue|
      puts "\n\n#{issue[:key]} - #{issue[:summary]}\nview: https://randallreilly.atlassian.net/browse/#{issue[:key]}\n"
    end
    puts "\n\n#{"~"*50}"
  end
end



#
# board = JiraBoardItems.new()
# board.see_my_issues
# pp board.see_issue("ATS-124")

# pp body.keys
# puts binding.eval
# binding.pry
# a = 1
