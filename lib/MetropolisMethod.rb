class MetropolisMethod
  def self.calculate(function_callback, right_boundary, previous_n)
    gamma1 = rand(0.0..1.0)
    gamma2 = rand(0.0..1.0)
    delta = (1.0/3.0) * right_boundary
    n = (previous_n + delta * (-1.0 + 2.0 * gamma1)).round

    if n < 1 || n > right_boundary
      return previous_n
    end

    previous_x_calculation = function_callback.call(previous_n)
    alpha = function_callback.call(n) / previous_x_calculation

    if alpha >= 1.0 || alpha > gamma2
      return n
    end

    previous_n
  end
end