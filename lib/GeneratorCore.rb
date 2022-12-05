class GeneratorCore
  def initialize(limit, step, generation_count)
    @generation_count = generation_count
    @limit = limit
    @step = step
  end

  def get_total_generations_count
    (@limit.to_f / @step) * @generation_count
  end

  def generate(method)
    frequencies = []
    sum = 0
    sum_squares = 0

    ((0 + @step)..@limit).step(@step).each do |currentStep|
      current_success_method_results = 0
      previous_step = currentStep - @step

      (0..@generation_count).each do
        method_result = method.call
        sum += method_result
        sum_squares += method_result**2

        if method_result > previous_step and method_result <= currentStep
          current_success_method_results += 1
        end
      end

      frequencies.push(current_success_method_results.to_f / @generation_count)
    end

    {
      'frequencies' => frequencies,
      'sum' => sum,
      'sum_squares' => sum_squares,
    }
  end
end