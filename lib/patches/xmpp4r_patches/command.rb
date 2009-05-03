##############################################################################################################
module AgentXmpp  
  module XMPP4R
    module Patches
      module Command
    
        ####----------------------------------------------------------------------------------------------------
        module InstanceMethods

          #.....................................................................................................
          def <<(child)
            add(child)
          end
    
        #### InstanceMethods
        end  
        
      ##### Command
      end
    #### Patches
    end
  ##### XMPP4R
  end
#### AgentXmpp
end

##############################################################################################################
Jabber::Command::IqCommand.send(:include, Jabber::XParent)
Jabber::Command::IqCommand.send(:include, AgentXmpp::XMPP4R::Patches::Command::InstanceMethods)
