##############################################################################################################
module AgentXmpp
  
  ############################################################################################################
  class Client

    #---------------------------------------------------------------------------------------------------------
    attr_reader :resource, :host, :port, :jid, :password, :roster
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(config)
      @jid = config['jid']
      @password = config['password']
      @resource = config['resource'] || Socket.gethostname
      @port = config['port'] || 5222
      @host = config['host'] || /.*@(.*)/.match(@jid).to_a.last
      @roster = Roster.new(config['contacts'])
    end

    #.........................................................................................................
    def connect
      EventMachine.run do
        @connection = EventMachine.connect(self.host, self.port, Connection, self.jid, 
          self.password, self.host, self.resource, self.port)
        @connection.add_delegate(self)
      end
    end

    #.........................................................................................................
    def reconnect
      @connection.reconnect
    end

    #.........................................................................................................
    def connected?
      @connection and !@connection.error?
    end

    #.........................................................................................................
    def add_delegate(delegate)
      @connection.add_delegate(delegate)
    end

    #.........................................................................................................
    def remove_delegate(delegate)
      @connection.remove_delegate(delegate)
    end
    
    #---------------------------------------------------------------------------------------------------------
    # AgentXmpp::Connection delegate
    #.........................................................................................................
    def did_connect(connection)
      AgentXmpp::logger.info "CONNECTED"
    end

    #.........................................................................................................
    def did_not_connect(connection)
      AgentXmpp::logger.info "CONNECTION FAILED"
    end

    #.........................................................................................................
    def did_authenticate(connection, stanza)
      AgentXmpp::logger.info "AUTHENTICATED"
    end
 
    #.........................................................................................................
    def did_not_authenticate(connection, stanza)
      AgentXmpp::logger.info "AUTHENTICATION FAILED"
    end

   #.........................................................................................................
   def did_receive_presence(connection, presence)
     AgentXmpp::logger.info "RECEIVED PRESENCE"
     p presence
     p presence.methods
     # if self.roster.has_key?(roster_item_jid) 
     # end
   end

   #.........................................................................................................
   def did_receive_roster_item(connection, roster_item)
     AgentXmpp::logger.info "RECEIVED ROSTER ITEM"   
     roster_item_jid = roster_item.jid.to_s
     if self.roster.has_key?(roster_item_jid) 
       self.roster[roster_item_jid][:activated] = true 
       self.roster[roster_item_jid][:roster_item] = roster_item 
       AgentXmpp::logger.info "ACTIVATING CONTACT: #{roster_item_jid}"   
     else
       AgentXmpp::logger.info "REMOVING CONTACT: #{roster_item_jid}"   
     end
   end

   #.........................................................................................................
   def did_receive_all_roster_items(connection)
     AgentXmpp::logger.info "RECEIVED ALL ROSTER ITEMS"   
#     self.roster.select{|k,v| not v[k][:activated]}.each do |k,v|
     self.roster.each do |k,v|
#       puts "jid:#{k}, item: #{v[k][:activated]}"
       AgentXmpp::logger.info "ADDING CONTACT: #{k}"   
     end
   end

  ############################################################################################################
  # Client
  end

##############################################################################################################
# AgentXmpp
end
