module GhNotifier
  module Github
    class Notification
      class Subject
        JSON.mapping(
          title: String,
          url: String,
          latest_comment_url: String?,
          type: String
        )
      end

      JSON.mapping(
        subject: Subject
      )
    end
  end
end
