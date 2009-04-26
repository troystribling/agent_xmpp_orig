##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module HashPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #.......................................................................................................
        def to_x_data(type = 'result')
          self.inject(Jabber::Dataforms::XData.new(type)) {|data, field| data.add_field_with_value(field[0].to_s, field[1].to_s); data}
        end

        
      #### InstanceMethods
      end  
        
    #### HashPatches
    end
  ##### StandardLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Hash.send(:include, AgentXmpp::StandardLibrary::HashPatches::InstanceMethods)
