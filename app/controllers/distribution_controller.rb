require_relative '../../lib/ProbabilityMassFunction'
require_relative '../../lib/GeneratorCore'
require_relative '../../lib/NeumannMethod'
require_relative '../../lib/MetropolisMethod'
require_relative '../../lib/IntervalsMethod'
require_relative '../../lib/MethodCalculationUtils'

class DistributionController < ApplicationController
  def index
    generation_count = params['generation-count']
    max_n = params['right-boundary']
    mu = params['mu']
    step = 1

    if generation_count && max_n && mu
      generation_count = generation_count.to_i
      max_n = max_n.to_i
      mu = mu.to_f
    else
      return
    end

    if generation_count < 1 || max_n <= 0 || mu < 0.01
      return
    end

    generator = GeneratorCore.new(max_n, step, generation_count)
    total_generations_count = generator.get_total_generations_count

    pdf_calculation_lambda = -> (n) { ProbabilityMassFunction.solve(mu, n) }
    pdf_mode_value = 1
    pdf_mean_value = ProbabilityMassFunction.mean(mu)
    pdf_variance_value = ProbabilityMassFunction.variance(mu)
    pdf_deviation_value = ProbabilityMassFunction.deviation(mu, total_generations_count)
    pdf_maximum_value = ProbabilityMassFunction.maximum_value(mu)

    neumann_method_lambda = -> () { NeumannMethod.calculate(pdf_calculation_lambda, pdf_maximum_value, max_n) }

    previous_x_result = pdf_mode_value
    metropolis_method_lambda = -> () {
      calculation_result = MetropolisMethod.calculate(pdf_calculation_lambda, max_n, previous_x_result)
      previous_x_result = calculation_result
      calculation_result
    }

    probabilities = IntervalsMethod.get_probabilities(max_n)
    values_by_probs = IntervalsMethod.get_values_by_probs(pdf_calculation_lambda, probabilities)

    intervals_method_lambda = -> () { IntervalsMethod.calculate(values_by_probs, probabilities) }

    neumann_method_data = generator.generate(neumann_method_lambda)
    metropolis_method_data = generator.generate(metropolis_method_lambda)
    intervals_method_data = generator.generate(intervals_method_lambda)

    methods_calculation = MethodCalculationUtils.new

    neumann_method_expected = methods_calculation.get_mean(
      total_generations_count,
      neumann_method_data['sum'],
    )
    metropolis_method_expected = methods_calculation.get_mean(
      total_generations_count,
      metropolis_method_data['sum'],
    )
    intervals_method_expected = methods_calculation.get_mean(
      total_generations_count,
      intervals_method_data['sum'],
    )

    neumann_method_variance = methods_calculation.get_variance(
      total_generations_count,
      neumann_method_data['sum'],
      neumann_method_data['sum_squares'],
    )
    metropolis_method_variance = methods_calculation.get_variance(
      total_generations_count,
      metropolis_method_data['sum'],
      metropolis_method_data['sum_squares'],
    )
    intervals_method_variance = methods_calculation.get_variance(
      total_generations_count,
      intervals_method_data['sum'],
      intervals_method_data['sum_squares'],
    )

    neumann_method_deviation = methods_calculation.get_deviation(
      total_generations_count,
      neumann_method_data['sum'],
      neumann_method_data['sum_squares'],
    )
    metropolis_method_deviation = methods_calculation.get_deviation(
      total_generations_count,
      metropolis_method_data['sum'],
      metropolis_method_data['sum_squares'],
    )
    intervals_method_deviation = methods_calculation.get_deviation(
      total_generations_count,
      intervals_method_data['sum'],
      intervals_method_data['sum_squares'],
    )

    @calculation_result = {
      'options' => {
        'generationCount' => generation_count,
        'max_x' => max_n,
        'step' => step,
        'mu' => mu
      },
      'pdfMaxValue' => pdf_maximum_value,
      'pdfMeanValue' => pdf_mean_value,
      'pdfVarianceValue' => pdf_variance_value,
      'pdfDeviationValue' => pdf_deviation_value,
      'neumannMethod' => neumann_method_data['frequencies'],
      'metropolisMethod' => metropolis_method_data['frequencies'],
      'intervalsMethod' => intervals_method_data['frequencies'],
      'neumannMethodExpectedValue' => neumann_method_expected,
      'metropolisMethodExpectedValue' => metropolis_method_expected,
      'intervalsMethodExpectedValue' => intervals_method_expected,
      'neumannMethodVariance' => neumann_method_variance,
      'metropolisMethodVariance' => metropolis_method_variance,
      'intervalsMethodVariance' => intervals_method_variance,
      'neumannMethodDeviation' => neumann_method_deviation,
      'metropolisMethodDeviation' => metropolis_method_deviation,
      'intervalsMethodDeviation' => intervals_method_deviation,
    }
  end
end
