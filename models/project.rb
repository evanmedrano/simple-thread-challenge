require 'date'
require 'byebug'
require_relative '../services/reimbursement_calculation_service'

class Project
  VALID_COSTS = ['high', 'low'].freeze

  def self.assign(cost:, start_date:, end_date:)
    raise 'cost must be either "high" or "low"' unless VALID_COSTS.include?(cost)

    # I'd use safe_constantize instead if this was a rails project
    if cost == 'high'
      HighCostCityProject.new(start_date:, end_date:)
    elsif cost == 'low'
      LowCostCityProject.new(start_date:, end_date:)
    end
  end

  attr_accessor :start_date, :end_date

  def initialize(start_date:, end_date:)
    @start_date = convert_date(start_date)
    @end_date = convert_date(end_date)

    raise 'end_date cannot be before start_date' unless valid_project_timeline?
  end

  def travel_day_reimbursement_rate
    raise 'Must use this method in a child class'
  end

  def full_day_reimbursement_rate
    raise 'Must use this method in a child class'
  end

  def dates
    (start_date..end_date).to_a
  end

  private

  def valid_project_timeline?
    end_date >= start_date
  end

  def convert_date(date)
    # matches either 1/1/15 or 01/01/2015
    raise 'date format must be in M/D/Y format' unless date.match?(/[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{2,4}/)

    month, date, year = date.split('/').map(&:to_i)

    if year.digits.length == 4
      Date.new(year, month, date)
    elsif year.digits.length == 2
      Date.new("20#{year}".to_i, month, date)
    end
  end
end

class LowCostCityProject < Project
  def travel_day_reimbursement_rate
    45
  end

  def full_day_reimbursement_rate
    75
  end

  def cost
    'low'
  end
end

class HighCostCityProject < Project
  def travel_day_reimbursement_rate
    55
  end

  def full_day_reimbursement_rate
    85
  end

  def cost
    'high'
  end
end
