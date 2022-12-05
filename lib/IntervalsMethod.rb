class IntervalsMethod
  def self.calculate(values_by_probs, probabilities)
    random = rand(0.0..1.0)

    sum_of_values = 0
    values_by_probs.each_with_index do |value_by_props, index|
      if random <= (sum_of_values + value_by_props)
        return probabilities[index]
      end

      sum_of_values += value_by_props
    end

    -1
  end

  def self.get_values_by_probs(function_callback, probabilities)
    probabilities.map { |prob_value| function_callback.call(prob_value) }
  end

  def self.get_probabilities(right_boundary)
    [*1..right_boundary]
  end
end