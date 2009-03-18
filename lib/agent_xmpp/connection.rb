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
    attr_reader :resource, :host, :port, :password, :connection_status, :delegates
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(jid, password, host, resource, logger, port=5222)
      @resource, @host, @port, @jid, @password = resource, host, port, jid, password
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

    #.........................................................................................................
    def jid
      if @jid.kind_of?(Jabber::JID)
        @jid
      else
        @jid =~ /@/ ? Jabber::JID.new(@jid) : Jabber::JID.new(@jid, 'localhost')
      end
    end

    #---------------------------------------------------------------------------------------------------------
    # EventMachine::Connection callbacks
    #.........................................................................................................
    def connection_completed
      self.init_connection(self.host)
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
      
      stanza_type = stanza.class.to_s
      unless stanza_type.eql?('REXML::Element')
        method = ('did_receive_' + /.*::(.*)/.match(stanza_type).to_a.last.downcase).to_sym
        self.broadcast_to_delegates(method, self, stanza)
      end

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
        resource.text = self.resource
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
      self.send("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' to='#{self.host}'>" )
    end

    #.........................................................................................................
    def broadcast_to_delegates(method, *args)
      self.delegates.each{|d| d.send(method, *args) if d.respond_to?(method)}
    end

    #.........................................................................................................
    def get_roster
      self.send(Jabber::Iq.new_rosterget) do |r|
        if r.type == :result and r.query.kind_of?(Jabber::Roster::IqQueryRoster)
          r.query.each_element {|i|  self.broadcast_to_delegates(:did_receive_roster_item, self, i)}
          self.broadcast_to_delegates(:did_receive_all_roster_items, self)
        end
      end
    end

  ############################################################################################################
  # Connection
  end

##############################################################################################################
# AgentXmpp
end
