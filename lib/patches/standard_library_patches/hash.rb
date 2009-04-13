##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module Patches
      module Hash
    
        ####----------------------------------------------------------------------------------------------------
        module InstanceMethods

          #.......................................................................................................
          def to_x_data(type = 'result')
            data = Jabber::Dataforms::XData.new(type)
            self.each {|var, value| data.add_field_with_value(var, value)}
            data
          end

          
        #### InstanceMethods
        end  
        
      ##### Hash
      end
    #### Patches
    end
  ##### StandardLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Array.send(:include, AgentXmpp::StandardLibrary::Patches::Hash::InstanceMethods)
