module GhNotifier
  module Github
    class Comment
      JSON.mapping(
        html_url: String
      )
    end
  end
end
