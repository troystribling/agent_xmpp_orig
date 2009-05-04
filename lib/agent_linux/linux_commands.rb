############################################################################################################
class LinuxCommands

  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def uptime
      result = `uptime`.gsub(/days,/, 'days').split(/,/)
      time_stamp = result[0].split('up')
      users = /(\d+)/.match(result[1]).to_a.last
      load_average = /(\d+\.\d+)/.match(result[2]).to_a.last + ", #{result[3]}, #{result[4]}"
      {:current_time => time_stamp[0].strip, :uptime => time_stamp[1].strip, :active_users => users.strip, :load_average => load_average.strip}
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
    
    #.........................................................................................................
    def sar_query(cmd, period)
      query_end = Time.now
      query_start = query_end - 2 * period
      stat_cmd = cmd + 
        " -s #{query_start.strftime("%H:%M:%S")} -e #{query_end.strftime("%H:%M:%S")} -f /var/log/sysstat/sa#{query_end.strftime("%d")}"
      stats = `#{stat_cmd}`.split("\n")[3..-2]
      unless stats.nil? 
        yield stats.first.split(/\s+/)
      end
    end

  ###------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxCommands
end
