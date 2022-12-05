class MethodCalculationUtils
  def get_mean(generation_count, generation_sum)
    generation_sum / generation_count
  end

  def get_variance(generation_count, sum, squares_sum)
    mean = get_mean(generation_count, sum)
    (squares_sum - (mean * mean * generation_count)) / (generation_count - 1)
  end

  def get_deviation(generation_count, sum, squares_sum)
    variance = get_variance(generation_count, sum, squares_sum)
    Math.sqrt(variance / generation_count)
  end
end
