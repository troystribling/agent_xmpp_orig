############################################################################################################
class LowPassFilter

  #.........................................................................................................
  @max_points = 100
  
  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.......................................................................................................
    attr_accessor :max_points
    
    #.......................................................................................................
    def apply_to(data)
      sample_int = (data.length.to_f / max_points.to_f).floor + 1
      if sample_int > 1
        intervals(data, sample_int).map {|i| average_points(i)}
      else
        data
      end
    end
    
  ###------------------------------------------------------------------------------------------------------
  private
  
    #.......................................................................................................
    def average_points(points)
      {:value => average_vals(extract(points, :value)), :time => average_vals(extract(points, :time))}
    end

    #.......................................................................................................
    def average_vals(vals)
      vals.inject(0.0) {|avg, v| avg + v} / vals.length.to_f
    end

    #.......................................................................................................
    def extract(points, val)
      points.map{|p| p[val]}
    end

    #.......................................................................................................
    def intervals(data, sample_int)
      (0..data.length/sample_int-1).to_a.inject([]) do |data_intervals, i|
        data_intervals.push(data.slice(i*sample_int, sample_int))
      end
    end
  
  ###------------------------------------------------------------------------------------------------------
  end
    
############################################################################################################
# DownSample
end