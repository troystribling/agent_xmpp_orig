##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module HashPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #.......................................................................................................
        def to_x_data(type = 'result')
          data = Jabber::Dataforms::XData.new(type)
          self.each {|var, value| data.add_field_with_value(var.to_s, value.to_s)}
          data
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
