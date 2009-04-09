##############################################################################################################
module AgentXmpp
  
  ############################################################################################################
  class Controller

    #---------------------------------------------------------------------------------------------------------
    attr_acccessor :params
    #---------------------------------------------------------------------------------------------------------
 
    #.........................................................................................................
    def execute
      AgentXmpp::logger.info "AgentXmpp::Controller\#execute"
    end

    #.........................................................................................................
    def prev
      AgentXmpp::logger.info "AgentXmpp::Controller\#prev"
    end

    #.........................................................................................................
    def next
      AgentXmpp::logger.info "AgentXmpp::Controller\#next"
    end
    
    #.........................................................................................................
    def complete
      AgentXmpp::logger.info "AgentXmpp::Controller\#complete"
    end

    #.........................................................................................................
    def cancel
      AgentXmpp::logger.info "AgentXmpp::Controller\#cancel"
    end
    
  ############################################################################################################
  # Controller
  end

##############################################################################################################
# AgentXmpp
end

