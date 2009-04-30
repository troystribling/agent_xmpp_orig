##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module ObjectPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #.......................................................................................................
        def to_x_data(type = 'result')
          data = Jabber::Dataforms::XData.new(type)
          data.add_field_with_value(nil, self.to_s)
          data
        end
  
        #.......................................................................................................
        def meta_define_method(name, &blk)
          (class << self; self; end).instance_eval {define_method(name, &blk)}
        end
  
      #### InstanceMethods
      end  
        
    #### ObjectPatches
    end
  ##### StandardLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Object.send(:include, AgentXmpp::StandardLibrary::ObjectPatches::InstanceMethods)
