############################################################################################################
class SystemCommands

  #---------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def uptime
      result = `uptime`.strip.gsub(/,/,'').gsub(/:\s/,' ').split(/\s+/)
      {:uptime => result[2], :active_users => result[3], :load_average => "#{result[7]}, #{result[8]}, #{result[9]}"}
    end

    #.........................................................................................................
    def file_system_usage
      fs_type_result = `df -T`
      ['hfs', 'ext3', 'ext', 'ext2'].select{|fst| /\s#{fst}\s/.match(fs_type_result)}.inject([]) do |result, fst|
        `df --type=#{fst} -H`.split("\n")[1..-1].each do |row|
          vals = row.split(/\s+/)
          result.push({:mount => vals[5..-1].join(" "), :size => vals[1], :used => vals[4]})
        end
        # TODO: not sure what is going on single element arrays are packed into another array while multielement arrays
        #       are not. it was screwing up construction of xmpp message
        result.count.eql?(1) ? result.first : result
      end
    end
  
  private
    
  #---------------------------------------------------------------------------------------------------------
  end
   
############################################################################################################
# SystemCommands
end
