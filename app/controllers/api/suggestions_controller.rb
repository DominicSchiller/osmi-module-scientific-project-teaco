require_relative 'api_response_handler'

##
# API module  grouping all REST API related classes.
module Api
  ##
  # Concrete API response handler which handles all
  # Suggestion related API calls.
  class SuggestionsController < APIResponseHandler
    ##
    # Fetches all meetings associated with a specific user recorded in TeaCo.
    def index
      meeting = load_meeting(params)
      suggestions = meeting.suggestions
      self.send_json(
              suggestions.to_json(:include => [:votes])
      )
    end

    ##
    # Fetches one specific suggestion defined by it's unique ID
    def show
      suggestion = load_suggestion(params)
      self.send_json(
          suggestion.to_json(:include => [:votes])
      )
    end

    ##
    # Create a new suggestion and associate it with
    # given user and meeting.
    def create
      user = self.load_user(params)
      meeting = self.load_meeting(params)

      if user != nil and meeting != nil
        new_suggestion = Suggestion.create
        new_suggestion.meeting_id = params["meeting_id"]
        new_suggestion.start = params["startTime"]
        new_suggestion.end = params["endTime"]
        new_suggestion.date = params["date"]
        new_suggestion.creator_id = user.id
        new_suggestion.save!

        # create empty votes
        meeting.participants.each do |participant|
          new_vote = Vote.create
          new_vote.suggestion_id = new_suggestion.id
          new_vote.voter_id = participant.id
          new_vote.decision = participant.id == new_suggestion.creator_id ? "yes": "?"
          new_vote.save!
          new_suggestion.votes << new_vote
        end
        new_suggestion.save!

        self.send_json(
            new_suggestion.to_json(:include => [:votes])
          )
      else
        self.send_error
      end
    end
  end
end