require "crest"
require "json"
require "./gh_notifier/github/*"

include GhNotifier::Github

BASE_URL = "https://api.github.com"

client = Crest::Resource.new(
  BASE_URL,
  user: ENV["USER"],
  password: ENV["PASSWORD"]
)

default_repo = "Soluciones/emergia"
repo = ENV.fetch("REPO", default_repo)

if ARGV.any? && ARGV.first == "approved"
  pull_requests_response = client["/repos/#{repo}/pulls"].get
  pull_requests = Array(PullRequest).from_json(pull_requests_response.body)

  pull_requests.each do |pull_request|
    pull_request_reviews_response = client["/repos/#{repo}/pulls/#{pull_request.number}/reviews"].get
    pull_request_reviews = Array(PullRequestReview).from_json(pull_request_reviews_response.body)
    number_of_approved_reviews = pull_request_reviews.count { |pr| pr.approved? }
    next if number_of_approved_reviews < 2
    puts "#{pull_request.html_url} #{pull_request.user.login}"
  end
else
  notifications_response = client["/repos/#{repo}/notifications"].get
  notifications = Array(Notification).from_json(notifications_response.body)
  notifications.each do |notification|
    if comment_url = notification.subject.latest_comment_url
      comment_request = client[comment_url.gsub(BASE_URL, "")].get
      comment = Comment.from_json(comment_request.body)
      puts comment.html_url
    else
      pull_request_url = notification.subject.url
      pull_request_response = client[pull_request_url.gsub(BASE_URL, "")].get
      pull_request = PullRequest.from_json(pull_request_response.body)
      puts pull_request.html_url
    end
  end
end
