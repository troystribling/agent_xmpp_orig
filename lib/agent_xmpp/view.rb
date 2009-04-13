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
      container_type = 'add_'+ /jabber:x:(.*)/.match(self.format.xmlns).to_a.last + '_to_container'
      container_type = case self.format.xmlns
        when 'jabber:x:data' : :add_x_data_to_container
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
      
  #### View
  end

#### AgentXmpp
end
