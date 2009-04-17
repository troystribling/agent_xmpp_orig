##############################################################################################################
module AgentXmpp
  module Routing
  
    #####-------------------------------------------------------------------------------------------------------
    class Routes

      #.........................................................................................................
      cattr_reader :map
      @@map = Map.new
      #.........................................................................................................

      #.........................................................................................................
      class << self
      
        #.......................................................................................................
        def draw
          yield @@map
        end

        #.......................................................................................................
        def invoke_command_response(connection, params)
          route_path = "#{params[:node]}/#{params[:action]}"
          field_path = self.fields(params)
          route_path += "/#{field_path}" unless field_path.nil? 
          route = self.map[route_path]
          unless route.nil?
            begin
              controller_class = eval("#{route[:controller].classify}Controller")
            rescue ArgumentError
              AgentXmpp::logger.error "ROUTING ERROR: #{params[:node].classify}Controller inavlid for node:#{params[:node]} action:#{params[:action]}."
            else          
              controller_class.new.handle_request(connection, route[:action], params)
            end
          end
        end

        #.......................................................................................................
        def invoke_chat_message_body_response(connection, params)
          route = self.map.chat_message_body_route
          begin
            controller_class = eval("#{route[:controller].classify}Controller")
          rescue ArgumentError
            AgentXmpp::logger.error "ROUTING ERROR: #{params[:node].classify}Controller inavlid for node:#{params[:node]} action:#{params[:action]}."
          else          
            controller_class.new.handle_request(connection, route[:action], params)
          end
        end
        
        #.......................................................................................................
        def fields(params)
          nil
        end
        
      end
      #.........................................................................................................

      #### Routes
      end

  #### Routing
  end
#### AgentXmpp
end
