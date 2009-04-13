##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module Patches
      module Object
    
        ####----------------------------------------------------------------------------------------------------
        module InstanceMethods

          #.......................................................................................................
          def to_x_data(type = 'result')
            data = Jabber::Dataforms::XData.new(type)
            data.add_field_with_value(nil, self.to_s)
            data
          end
    
        #### InstanceMethods
        end  
        
      ##### Object
      end
    #### Patches
    end
  ##### StandardLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Object.send(:include, AgentXmpp::StandardLibrary::Patches::Object::InstanceMethods)
