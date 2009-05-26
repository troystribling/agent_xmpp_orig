############################################################################################################
class LinuxCommands

  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def file_system_usage
      fs_type_result = `df -T`
      fsystem = ['hfs', 'ext3', 'ext', 'ext2'].select{|fst| /\s#{fst}\s/.match(fs_type_result)}.inject([]) do |result, fst|
        `df --type=#{fst} -H`.split("\n")[1..-1].each do |row|
          vals = row.split(/\s+/)
          result.push({:mount => vals[5..-1].join(" "), :size => vals[1], :used => vals[4]})
        end
        result
      end
      # TODO: not sure what is going on single element arrays are packed into another array while multielement arrays
      #       are not. it was screwing up construction of xmpp message
      fsystem.count.eql?(1) ? fsystem.first : fsystem
    end

    #.........................................................................................................
    def ethernet_interfaces
      ifaces = /(eth\d)/.match(`ifconfig -a`).captures.inject([]) do |result, iface|
        ifconfig = `ifconfig #{iface}`
        ip = /inet\saddr:(\d+\.\d+\.\d+\.\d+)/.match(ifconfig).captures.last
        mac = /HWaddr\s(\w+\:\w+\:\w+\:\w+\:\w+\:\w+)/.match(ifconfig).captures.last
        ip.nil? ? result : result.push({:iface => iface, :ip => ip, :mac => mac})  
      end
      ifaces.count.eql?(1) ? ifaces.first : ifaces
    end

    #.........................................................................................................
    def active_users
      users =`who`.split("\n").collect do |user|
        user_data = user.strip.split(/\s+/)
        ip = /\((.*)\)/.match(user_data.last).captures.last
        active_since = user_data[2] + ' ' + user_data[3]
        {:user => user_data[0], :active_since => active_since, :from_ip => ip}
      end || []
      users.count.eql?(1) ? users.first : users
    end

    #.........................................................................................................
    def processes_using_most_memory
      procs = `ps -eo pid,pcpu,pmem,comm`.split("\n")[1..-1].collect do |p|
        p_data = p.strip.split(/\s+/)
        {:pid => p_data[0], :command => p_data[3], :cpu => p_data[1].to_f, :memory => p_data[2].to_f}
      end
      largest_items_by_attribute(procs, :memory)
    end

    #.........................................................................................................
    def processes_using_most_cpu
      procs = `ps -eo pid,pcpu,pmem,comm`.split("\n")[1..-1].collect do |p|
        p_data = p.strip.split(/\s+/)
        {:pid => p_data[0], :command => p_data[3], :cpu => p_data[1].to_f, :memory => p_data[2].to_f}
      end
      largest_items_by_attribute(procs, :cpu)
    end

    #.........................................................................................................
    def largest_open_files
      files = `lsof  -S 2 +D / | grep -E ' [0-9]+[wru] +REG' `.split("\n").inject([]) do |result, f|
        unless /^lsof/.match(f)
          f_data = f.strip.split(/\s+/)
          result.push({:command => f_data[0], :file => f_data[8], :size => f_data[6].to_f/1024**2})
        end
        result
      end
      largest_items_by_attribute(files, :size)
    end

    #.........................................................................................................
    def largest_files
      files = (Dir.entries("/") - [".", "..", "sys", "srv", "proc", "lost+found"]).inject([]) do |result, r|
        Find.find("/"+r) do |p|
          next unless File.exists?(p)
          next if File.symlink?(p)
          if File.directory?(p)                   
            if File.basename(p)[0] == ?.
              Find.prune
            else
              next
            end
          else
            result.push({:file => p, :size => File.size(p).to_f/1024**2})
          end
        end
        result
      end
      largest_items_by_attribute(files, :size)
    end
    
    #.........................................................................................................
    def listening_tcp_sockets
      servs = services
      soc_procs = socket_processes
      sockets = `netstat -ntl`.split("\n")[2..-1].collect do |sock|
        sock_data = sock.strip.split(/\s+/)
        port = sock_data[3].split(":").last
        service = servs[port].nil? ? "-" : servs[port][:service]
        command = servs[port].nil? ? soc_procs[port] : soc_procs[service]
        {:port => port, :command => command || "-", :service => service}
      end
      sockets.count.eql?(1) ? sockets.first : sockets
    end

    #.........................................................................................................
    def connected_tcp_sockets
      servs = services
      soc_procs = socket_processes
      sockets = `netstat -nt`.split("\n")[2..-1].inject([]) do |result, sock|
        sock_data = sock.strip.split(/\s+/)
        if sock_data.last.eql?('ESTABLISHED')
          local_port = sock_data[3].split(":").last
          remote_ip = sock_data[4].split(":")
          service = if servs[local_port]
                      servs[local_port][:service] 
                    elsif servs[remote_ip.last]
                      servs[remote_ip.last][:service] 
                    else
                      remote_ip[1]
                    end
          result.push({:remote_ip => remote_ip[0], :service => service, :command => soc_procs[local_port] || "-"})
        end
        result
      end
      sockets.count.eql?(1) ? sockets.first : sockets
    end

    #.........................................................................................................
    def udp_sockets
      servs = services
      soc_procs = socket_processes
      sockets = `netstat -nul`.split("\n")[2..-1].collect do |sock|  
        sock_data = sock.strip.split(/\s+/)
        port = sock_data[3].split(":").last
        service = servs[port].nil? ? "-" : servs[port][:service]
        command = servs[port].nil? ? soc_procs[port] : soc_procs[service]
        {:port => port, :command => command || "-", :service => service}
      end
      sockets.count.eql?(1) ? sockets.first : sockets
    end

  ####........................................................................................................
  private

    #.........................................................................................................
    def socket_processes
      `lsof  -i -n`.split("\n")[1..-1].inject({}) do |result, s|
        unless /^lsof/.match(s)
          s_data = s.strip.split(/\s+/)
          m = /(.*)->.*/.match(s_data[7]) || /.*:(.*)/.match(s_data[7])
          local_port = m.captures.first.split(":").last
          result[local_port] = s_data[0]
        end
        result
      end
    end

    #.........................................................................................................
    def largest_items_by_attribute(items, by_attr)
      largest_items = items.sort_by {|i| -i[by_attr]}
      largest_items = largest_items[0..4] if largest_items.count > 5
      largest_items.count.eql?(1) ? largest_items.first : largest_items
    end

    #.........................................................................................................
    def services
      `cat /etc/services`.split("\n").inject({}) do |result, serv|
        unless /^#/.match(serv) or serv.eql?("")
          serv_data = serv.split(/\t+/)
          pp = serv_data[1].split("/")
          result[pp[0]] = {:service => serv_data[0], :port => pp[0], :protocol => pp[1]}
        end
        result
      end
    end
                   
  ###------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxCommands
end
