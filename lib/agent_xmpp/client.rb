##############################################################################################################
module AgentXmpp
  
  ############################################################################################################
  class Client

    #---------------------------------------------------------------------------------------------------------
    attr_reader :jid, :port, :password, :roster
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(config)
      @password = config['password']
      @port = config['port'] || 5222
      resource = config['resource'] || Socket.gethostname
      @jid = Jabber::JID.new("#{config['jid']}/#{resource}")
      @roster = Roster.new(@jid, config['contacts'])
    end

    #.........................................................................................................
    def connect
      EventMachine.run do
        @connection = EventMachine.connect(self.jid.domain, self.port, Connection, self.jid, 
          self.password, self.port)
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
     from_jid = presence.from.to_s     
     from_bare_jid = presence.from.bare.to_s     
     if self.roster.has_key?(from_bare_jid) 
       self.roster[from_bare_jid][:resources][from_jid] = presence
     end
     AgentXmpp::logger.info "RECEIVED PRESENCE FROM: #{from_jid}"
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
       @connection.remove_contact(Jabber::JID.new(j))  
       AgentXmpp::logger.info "REMOVING CONTACT: #{roster_item_jid}"   
     end
   end

   #.........................................................................................................
   def did_remove_roster_item(connection, roster_item)
     AgentXmpp::logger.info "REMOVE ROSTER ITEM"   
     roster_item_jid = roster_item.jid.to_s
     if self.roster.has_key?(roster_item_jid) 
       self.roster.delete(roster_item_jid) 
       AgentXmpp::logger.info "REMOVED CONTACT: #{roster_item_jid}"   
     end
   end

   #.........................................................................................................
   def did_receive_all_roster_items(connection)
     AgentXmpp::logger.info "RECEIVED ALL ROSTER ITEMS"   
     self.roster.select{|j,r| not r[:activated]}.each do |j,r|
       AgentXmpp::logger.info "ADDING CONTACT: #{j}" 
       @connection.add_contact(Jabber::JID.new(j))  
     end
   end

   #.........................................................................................................
   def did_add_contact(connection, stanza)
     AgentXmpp::logger.info "CONTACT ADDED"
   end


  ############################################################################################################
  # Client
  end

##############################################################################################################
# AgentXmpp
end
