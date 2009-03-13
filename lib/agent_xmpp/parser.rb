##############################################################################################################
module AgentXmpp
  
  ############################################################################################################
  module Parser

    #---------------------------------------------------------------------------------------------------------
    include EventMachine::XmlPushParser
    #---------------------------------------------------------------------------------------------------------

    #---------------------------------------------------------------------------------------------------------
    # EventMachine::XmlPushParser callbacks
    #.........................................................................................................
  	def start_document
  	  puts "start_document"
  	end
  
    #.........................................................................................................
    def start_element name, attrs
  	  puts "start_element: #{name}, #{attrs}"
      e = REXML::Element.new(name)
      # e.add_attributes attrs
      # 
      # @current = @current.nil? ? e : @current.add_element(e)
      # 
      # if @current.name == 'stream' and not @started
      #   @started = true
      #   process
      #   @current = nil
      # end
    end
  
    #.........................................................................................................
    def end_element name
  	  puts "end_element: #{name}"
      # if name == 'stream:stream' and @current.nil?
      #   @started = false
      # else
      #   if @current.parent
      #     @current = @current.parent
      #   else
      #     process
      #     @current = nil
      #   end
      # end
    end

    #.........................................................................................................
    def characters text
  	  puts "characters: #{text}"
      # @current.text = @current.text.to_s + text if @current
    end

    #.........................................................................................................
    def error *args
      p ['error', *args]
    end

    #---------------------------------------------------------------------------------------------------------
    protected
    #---------------------------------------------------------------------------------------------------------
  
    #.........................................................................................................
    def init(to)
      self.send("<?xml version='1.0' ?>") unless @started
      @started = false  
      self.send("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' to='#{to}'>" )
    end

    #.........................................................................................................
    def process
      if @current.namespace('').to_s == ''
        @current.add_namespace(@streamns)
      end

      case @current.prefix
      when 'stream'

        case @current.name
          when 'stream'
            @streamid = @current.attributes['id']
            @streamns = @current.namespace('') if @current.namespace('')

            # Hack: component streams are basically client streams.
            # Someday we may want to create special stanza classes
            # for components/s2s deriving from normal stanzas but
            # posessing these namespaces
            @streamns = 'jabber:client' if @streamns == 'jabber:component:accept'

          when 'features'
            @stream_features, @stream_mechanisms = {}, []
            @current.each { |e|
              if e.name == 'mechanisms' and e.namespace == 'urn:ietf:params:xml:ns:xmpp-sasl'
                e.each_element('mechanism') { |mech|
                  @stream_mechanisms.push(mech.text)
                }
              else
                @stream_features[e.name] = e.namespace
              end
            }
        end

        stanza = @current

      else
        # Any stanza, classes are registered by XMPPElement::name_xmlns
        begin
          stanza = Jabber::XMPPStanza::import(@current)
        rescue Jabber::NoNameXmlnsRegistered
          stanza = @current
        end
      end

        @client.receive(stanza)
      end
   
  ############################################################################################################
  # Parser
  end

##############################################################################################################
# AgentXmpp
end

