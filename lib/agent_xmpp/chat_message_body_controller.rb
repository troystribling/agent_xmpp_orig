############################################################################################################
class ChatMessageBodyController < AgentXmpp::Controller

  #.........................................................................................................
  def body
    result_for do
      params[:body].reverse
    end
    respond_to do |result|
      result.to_s
    end
    AgentXmpp::info "ACTION: ChatMessageBodyController\#body"
  end
  
############################################################################################################
# ChatMessageBodyController
end
