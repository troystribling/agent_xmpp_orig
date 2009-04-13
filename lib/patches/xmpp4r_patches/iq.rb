##############################################################################################################
module AgentXmpp  
  module XMPP4R
    module Patches
      module Iq
    
        ####----------------------------------------------------------------------------------------------------
        module InstanceMethods

          #.....................................................................................................
          def command=(newcommand)
            delete_elements(newcommand.name)
            add(newcommand)
          end
      
        #### InstanceMethods
        end 
         
      ##### Iq
      end
    #### Patches
    end
  ##### XMPP4R
  end
#### AgentXmpp
end

##############################################################################################################
Jabber::Iq.send(:include, AgentXmpp::XMPP4R::Patches::Iq::InstanceMethods)
