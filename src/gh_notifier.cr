require "crest"
require "json"
require "./gh-notifier/github/*"

include GhNotifier::Github

BASE_URL = "https://api.github.com"

credentials = { user: ENV["USER"], password: ENV["pwd"] }
default_repo = "Soluciones/emergia"
repo = ENV.fetch("REPO", default_repo)

if ARGV.any? && ARGV.first == "approved"
  pull_requests_request = Crest::Request.new(:get, "#{BASE_URL}/repos/#{repo}/pulls", **credentials)
  pull_requests = Array(PullRequest).from_json(pull_requests_request.execute.body)

  pull_requests.each do |pull_request|
    url = "#{BASE_URL}/repos/#{repo}/pulls/#{pull_request.number}/reviews"
    pull_request_reviews_request = Crest::Request.new(:get, url, **credentials)
    pull_request_reviews = Array(PullRequestReview).from_json(pull_request_reviews_request.execute.body)
    number_of_approved_reviews = pull_request_reviews.count { |pr| pr.approved? }
    next if number_of_approved_reviews < 2
    puts "#{pull_request.html_url} #{pull_request.user.login}"
  end
else
  notifications_request = Crest::Request.new(:get, "#{BASE_URL}/repos/#{repo}/notifications", **credentials)
  notifications = Array(Notification).from_json(notifications_request.execute.body)
  notifications.each do |notification|
    if comment_url = notification.subject.latest_comment_url
      comment_request = Crest::Request.new(:get, comment_url, **credentials)
      comment = Comment.from_json(comment_request.execute.body)
      puts comment.html_url
    else
      pull_request_url = notification.subject.url
      pull_request_request = Crest::Request.new(:get, pull_request_url, **credentials)
      pull_request = PullRequest.from_json(pull_request_request.execute.body)
      puts pull_request.html_url
    end
  end
end
