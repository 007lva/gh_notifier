module GhNotifier
  module Github
    class PullRequest
      class User
        JSON.mapping(
          login: String
        )
      end

      JSON.mapping(
        number: UInt16,
        html_url: String,
        user: User
      )
    end
  end
end
