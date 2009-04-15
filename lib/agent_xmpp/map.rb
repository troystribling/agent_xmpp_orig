##############################################################################################################
module AgentXmpp
  module Routing
  
    #####-------------------------------------------------------------------------------------------------------
    class RoutingConnection < Exception; end

    #####-------------------------------------------------------------------------------------------------------
    class Map

      #.........................................................................................................
      attr_reader :message_body_route
      #.........................................................................................................

      #.........................................................................................................
      def initialize
        @routes = Hash.new
        @chat_message_body_route = {:controller => 'chat_message_body', :action => 'body'}
      end

      #.........................................................................................................
      def connect(path, options = {})
        path.strip!; path.gsub!(/^\//,'')
        path_elements = path.split('/')
        raise RoutingConnection, "Inavild route connection: #{path}." if path_elements.count < 2 
        self.send("#{type}_command".to_sym, {:controller => route[:controller] || path[0], :action => route[:action] || path[1]})
      end

      #.........................................................................................................
      def [](path)
        @command_routes[key]
      end

      #.........................................................................................................
      def connect_message_body(route)
        @message_body_route = {:controller => route[:controller], :action => route[:action]}
      end
     
    private
    
    #### Map
    end

  #### Routing
  end
#### AgentXmpp
end
