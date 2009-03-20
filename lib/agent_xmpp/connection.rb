##############################################################################################################
module AgentXmpp
  
  ############################################################################################################
  class NotConnected < Exception; end

  ############################################################################################################
  class Connection < EventMachine::Connection

    #---------------------------------------------------------------------------------------------------------
    include Parser
    #---------------------------------------------------------------------------------------------------------

    #---------------------------------------------------------------------------------------------------------
    attr_reader :jid, :port, :password, :connection_status, :delegates
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(jid, password, port=5222)
      @jid, @password, @port = jid, password, port
      @connection_status = :offline;
      @id_callbacks = {}
      @delegates = []
    end
    
    #.........................................................................................................
    def add_delegate(delegate)
      @delegates << delegate
    end

    #.........................................................................................................
    def remove_delegate(delegate)
      @delegates.delete(delegate)
    end
    
    #.........................................................................................................
    def send(data, &blk)
      AgentXmpp::logger.info "SEND: #{data.to_s}"
      raise NotConnected if self.error?
      if block_given? and data.is_a? Jabber::XMPPStanza
        if data.id.nil?
          data.id = Jabber::IdGenerator.instance.generate_id
        end
        @id_callbacks[data.id] = blk
      end
      self.send_data(data.to_s)
    end

    #---------------------------------------------------------------------------------------------------------
    # roster management
    #.........................................................................................................
    def get_roster
      self.send(Jabber::Iq.new_rosterget) do |r|
        if r.type == :result and r.query.kind_of?(Jabber::Roster::IqQueryRoster)
          r.query.each_element {|i|  self.broadcast_to_delegates(:did_receive_roster_item, self, i)}
          self.broadcast_to_delegates(:did_receive_all_roster_items, self)
        end
      end
    end

    #.........................................................................................................
    def remove_contact
      self.send(Jabber::Iq.new_rosterget) do |r|
        if r.type == :result and r.query.kind_of?(Jabber::Roster::IqQueryRoster)
          r.query.each_element {|i|  self.broadcast_to_delegates(:did_receive_roster_item, self, i)}
          self.broadcast_to_delegates(:did_receive_all_roster_items, self)
        end
      end
    end

    #.........................................................................................................
    def add_contact(contact_jid)
      request = Jabber::Iq.new_rosterset
      request.query.add(Jabber::Roster::RosterItem.new(contact_jid))
      self.send(request) do |r|
        self.send(Jabber::Presence.new.set_type(:subscribe).set_to(contact_jid))
        self.broadcast_to_delegates(:did_acknowledge_add_contact, self, r, contact_jid)
      end
    end

    #.........................................................................................................
    def remove_contact(contact_jid)
      request = Jabber::Iq.new_rosterset
      request.query.add(Jabber::Roster::RosterItem.new(contact_jid, nil, :remove))
      self.send(request) do |r|
        self.broadcast_to_delegates(:did_remove_contact, self, r, contact_jid)
      end
    end

    #.........................................................................................................
    def accept_contact_request(contact_jid)
      presence = Jabber::Presence.new.set_type(:subscribe)
      presence.to = contact_jid      
      self.send(presence)
    end

    #---------------------------------------------------------------------------------------------------------
    # EventMachine::Connection callbacks
    #.........................................................................................................
    def connection_completed
      self.init_connection
      self.broadcast_to_delegates(:did_connect, self)
    end

    #.........................................................................................................
    def receive_data(data)
      AgentXmpp::logger.info "RECV: #{data.to_s}"
      super(data)
    end

    #.........................................................................................................
    def unbind
      @connection_status = :off_line
    end

    #---------------------------------------------------------------------------------------------------------
    # AgentXmpp::Parser callbacks
    #.........................................................................................................
    def receive(stanza)
      
      if stanza.kind_of?(Jabber::XMPPStanza) and stanza.id and blk = @id_callbacks[stanza.id]
        @id_callbacks.delete(stanza.id)
        blk.call(stanza)
        return
      end

      case stanza.xpath
      when 'stream:features'
        @stream_features, @stream_mechanisms = {}, []
        @current.each do |e|
          if e.name == 'mechanisms' and e.namespace == 'urn:ietf:params:xml:ns:xmpp-sasl'
            e.each_element('mechanism') {|mech| @stream_mechanisms.push(mech.text)}
          else
            @stream_features[e.name] = e.namespace
          end
        end
        if @connection_status.eql?(:offline)
          self.authenticate
        elsif @connection_status.eql?(:authenticated)
          self.bind(stanza)
        end
      when 'success'
        case self.connection_status
        when :offline
          self.reset_parser
          self.init_connection(false)
          @connection_status = :authenticated
        end
        return
      when 'failure'
        case self.connection_status
        when :offline
          self.reset_parser
          self.broadcast_to_delegates(:did_not_authenticate, self, stanza)
        end
      end
      
      
    self.do_broadcast(stanza)  unless stanza.class.to_s.eql?('REXML::Element')

    end

    #---------------------------------------------------------------------------------------------------------
    protected
    #---------------------------------------------------------------------------------------------------------
  
    #.........................................................................................................
    def authenticate
      begin
          Jabber::SASL::new(self, 'PLAIN').auth(self.password)
      rescue
        raise ClientAuthenticationFailure.new, $!.to_s
      end
    end
  
    #.........................................................................................................
    def bind(stanza)
      if self.stream_features.has_key?('bind')
        iq = Jabber::Iq.new(:set)
        bind = iq.add(REXML::Element.new('bind'))
        bind.add_namespace(self.stream_features['bind'])                
        resource = bind.add REXML::Element.new('resource')
        resource.text = self.jid.resource
        self.send(iq) do |reply|
          if reply.type == :result and jid = reply.first_element('//jid') and jid.text
            @jid = Jabber::JID.new(jid.text)
            @connection_status = :bind
            self.session(stanza)
          end
        end
      end                
    end
    
    #.........................................................................................................
    def session(stanza)
      if self.stream_features.has_key?('session')
        iq = Jabber::Iq.new(:set)
        session = iq.add REXML::Element.new('session')
        session.add_namespace self.stream_features['session']                
        self.send(iq) do |reply|
          if reply.type == :result                
            @connection_status = :active
            self.broadcast_to_delegates(:did_authenticate, self, stanza)
            self.send(Jabber::Presence.new(nil, nil, 1))
            self.get_roster
          end
        end
      end
    end

    #.........................................................................................................
    def init_connection(starting=true)
      self.send("<?xml version='1.0' ?>") if starting
      self.send("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' to='#{self.jid.domain}'>" )
    end

    #.........................................................................................................
    def do_broadcast(stanza)
      stanza_class = stanza.class.to_s
      # roster update
      if stanza.type == :set and stanza.query.kind_of?(Jabber::Roster::IqQueryRoster)
        stanza.query.each_element do |i|  
          method =  case i.subscription
                    when :remove : :did_remove_roster_item
                    when :none   : :did_receive_roster_item
                    when :to     : :did_add_contact
                    end         
          self.broadcast_to_delegates(method, self, i) unless method.nil?
        end
      elsif stanza.type == :subscribe and stanza_class.eql?('Jabber::Presence')
        self.broadcast_to_delegates(:did_receive_contact_request, self, stanza)
      else
        method = ('did_receive_' + /.*::(.*)/.match(stanza_class).to_a.last.downcase).to_sym
        self.broadcast_to_delegates(method, self, stanza)
      end
    end
  
    #.........................................................................................................
    def broadcast_to_delegates(method, *args)
      self.delegates.each{|d| d.send(method, *args) if d.respond_to?(method)}
    end

  ############################################################################################################
  # Connection
  end

##############################################################################################################
# AgentXmpp
end
