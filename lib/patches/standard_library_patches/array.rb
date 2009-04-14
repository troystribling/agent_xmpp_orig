##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module Patches
      module Array
    
        ####----------------------------------------------------------------------------------------------------
        module InstanceMethods

          #......................................................................................................
          def to_x_data(type = 'result')
            data = Jabber::Dataforms::XData.new(type)
            reported = Jabber::Dataforms::XDataReported.new
            if self.first.instance_of?(Hash)
              self.first.each_key {|var| reported.add_field(var)}
              data << reported
              self.each do |fields|
                item = Jabber::Dataforms::XDataItem.new
                fields.each {|var, value| item.add_field_with_value(var, value)}
                data << item
              end
            else
              field = Jabber::Dataforms::XDataField.new
              field.values = self.map {|v| v.to_s}
              data << field
            end
            data
          end
          
        #### InstanceMethods
        end  
        
      ##### Array
      end
    #### Patches
    end
  ##### StandardLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Array.send(:include, AgentXmpp::StandardLibrary::Patches::Array::InstanceMethods)
