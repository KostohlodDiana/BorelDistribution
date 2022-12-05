class ProbabilityMassFunction
  def self.solve(mu, n)
    factorial = (1..n).inject(:*) || 1
    (Math.exp(-mu * n) * (mu * n)**(n-1)) / factorial
  end

  def self.mode
    1
  end

  def self.maximum_value(mu)
    ProbabilityMassFunction.solve(mu, ProbabilityMassFunction.mode)
  end

  def self.mean(mu)
    1.0 / (1 - mu)
  end

  def self.variance(mu)
    mu / ((1 - mu)**3)
  end

  def self.deviation(mu, generation_count)
    variance = ProbabilityMassFunction.variance(mu)
    Math.sqrt(variance / generation_count)
  end
end
