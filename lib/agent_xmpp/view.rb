##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class View

    #---------------------------------------------------------------------------------------------------------
    attr_reader :connection, :format, :params
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(connection, format, params)
      @connection = connection
      @format = format
      @params = params
    end
           
    #.........................................................................................................
    def add_payload_to_container(payload)
      container_type = case self.format.xmlns
        when 'jabber:x:data' : :add_x_data_to_container
        when 'message:chat'  : :add_chat_message_body_container
      end
      container_type.nil? ? nil : self.send(container_type, payload)
    end

  private
 
    #.........................................................................................................
    def add_x_data_to_container(payload)
      iq = Jabber::Iq.new(:result, self.params[:from])
      iq.id = self.params[:id] unless self.params[:id].nil?
      iq.command = Jabber::Command::IqCommand.new(self.params[:node], 'completed')
      iq.command << payload
      iq      
    end

    #.........................................................................................................
    def add_chat_message_body_container(payload)
      message = Jabber::Message.new(self.params[:from], payload)
      message.type = :chat
      message      
    end
      
  #### View
  end

#### AgentXmpp
end
