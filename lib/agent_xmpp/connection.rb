##############################################################################################################
module AgentXmpp
  
  ############################################################################################################
  class NotConnected < Exception; end

  class ClientAuthenticationFailure < Jabber::JabberError; end

  ############################################################################################################
  class Connection < EventMachine::Connection

    #---------------------------------------------------------------------------------------------------------
    include Parser
    #---------------------------------------------------------------------------------------------------------

    #---------------------------------------------------------------------------------------------------------
    attr_reader :host, :port, :password, :connection_status, :delegates
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(jid, password, host, port=5222)
      @host, @port, @jid, @password = host, port, jid, password
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
      puts "SEND: #{data.to_s}"
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
      puts 'connection_completed'
      self.init(self.host)
      self.broadcast_to_delegates(:did_connect, self)
    end

    #.........................................................................................................
    def receive_data(data)
      puts "RECV: #{data.to_s}"
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
      
      if (stanza.kind_of?(Jabber::XMPPStanza) and stanza.id and blk = @id_callbacks[stanza.id])
        @id_callbacks.delete(stanza.id)
        blk.call(stanza)
        return
      end

      case stanza.name
      when 'features'
        if @connection_status.eql?(:offline)
          self.authenticate
        elsif @connection_status.eql?(:authenticated)
          self.bind(stanza)
        end
      when 'success'
        case self.connection_status
        when :offline
          self.reset_parser
          self.init(false)
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
      
      # case stanza
      # when Jabber::Message
      #   on(:message, stanza)
      # 
      # when Jabber::Iq
      #   on(:iq, stanza)
      # 
      # when Jabber::Presence
      #   on(:presence, stanza)
      # end

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
        send(iq) do |reply|
          if reply.type == :result                
            @connection_status = :active
            self.broadcast_to_delegates(:did_authenticate, self, stanza)
          end
        end
      end
    end
  
    #.........................................................................................................
    def init(starting=true)
      self.send("<?xml version='1.0' ?>") if starting
      self.send("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' to='#{self.host}'>" )
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
