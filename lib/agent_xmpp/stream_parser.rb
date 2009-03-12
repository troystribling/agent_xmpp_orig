##############################################################################################################
module AgentXmpp

  ############################################################################################################
  class StreamParser

    #---------------------------------------------------------------------------------------------------------
    attr_reader :started
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(stream, listener)
      @stream = stream
      @listener = listener
      @current = nil
    end

    #.........................................................................................................
    def parse
      @started = false
      begin
        parser = REXML::Parsers::SAX2Parser.new @stream

        parser.listen( :start_element ) do |uri, localname, qname, attributes|
          e = REXML::Element.new(qname)
          e.add_attributes attributes
          @current = @current.nil? ? e : @current.add_element(e)

          # Handling <stream:stream> not only when it is being
          # received as a top-level tag but also as a child of the
          # top-level element itself. This way, we handle stream
          # restarts (ie. after SASL authentication).
          if @current.name == 'stream' and @current.parent.nil?
            @started = true
            @listener.receive(@current)
            @current = nil
          end
        end

        parser.listen( :end_element ) do  |uri, localname, qname|
          if qname == 'stream:stream' and @current.nil?
            @started = false
            @listener.parser_end
          else
            @listener.receive(@current) unless @current.parent
            @current = @current.parent
          end
        end

        parser.listen( :characters ) do | text |
          @current.add(REXML::Text.new(text.to_s, @current.whitespace, nil, true)) if @current
        end

        parser.listen( :cdata ) do | text |
          @current.add(REXML::CData.new(text)) if @current
        end

        parser.parse
      rescue REXML::ParseException => e
        @listener.parse_failure(e)
      end
    end
    
  ############################################################################################################
  end
  
##############################################################################################################  
end
