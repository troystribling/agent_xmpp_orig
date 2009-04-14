##############################################################################################################
module AgentXmpp
  module Routing
  
    #####-------------------------------------------------------------------------------------------------------
    class RoutingConnection < Exception; end

    #####-------------------------------------------------------------------------------------------------------
    class Map

      #.........................................................................................................
      def initialize
        @items = Hash.new
      end

      #.........................................................................................................
      def connect(path, options = {})
        path.strip!; path.gsub!(/^\//,'')
        path_elements = path.split('/')
        raise RoutingConnection, "Inavild route connection: #{path}." if path_elements.count < 2 
        @items[path] = {:controller => options[:controller] || path_elements[0], :action => options[:action] || path_elements[1]}
      end

      #.........................................................................................................
      def [](key)
        @items[key]
      end

    #### Map
    end

  #### Routing
  end
#### AgentXmpp
end
