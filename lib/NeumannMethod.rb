class NeumannMethod
  def self.calculate(function_callback, maximum_value, right_boundary)
    while true
      n = rand(1..right_boundary)
      y = rand(0..maximum_value)

      if function_callback.call(n) > y
        return n
      end
    end
  end
end