module GhNotifier
  module Github
    class PullRequestReview
      JSON.mapping(
        state: String
      )

      def approved?
        state == "APPROVED"
      end
    end
  end
end
