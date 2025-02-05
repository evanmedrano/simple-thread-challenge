require_relative '../models/project'

class ReimbursementCalculationService
  def self.call(project_set, output_result: false)
    new(project_set, output_result:).call
  end

  attr_reader :project_set, :output_result

  def initialize(project_set, output_result:)
    @project_set = project_set
    @output_result = output_result
  end

  def call
    calculate_project_set
  end

  private

  def calculate_project_set
    result = 0
    latest_date = nil
    latest_cost = nil

    project_set.each do |project|
      project.dates.each do |date|
        if latest_date == date
          # Handle overlaps with the high cost city not being first
          if project.cost == 'high' && latest_cost == 'low'
            result -= remove_full_reimbursement(project, date)
          else
            next
          end
        end

        if determine_travel_days.include?(date)
          result += add_travel_reimbursement(project, date)
        else
          result += add_full_reimbursement(project, date)
        end

        latest_date = date
        latest_cost = project.cost
      end
    end

    puts "Reimbursement total: #{result}" if output_result

    result
  end

  def add_travel_reimbursement(project, date)
    rate = project.travel_day_reimbursement_rate
    cost = project.cost

    if output_result
      puts "Date #{date} is a travel day. Reimbursement rate is #{rate} for a #{cost} cost city."
    end

    rate
  end

  def add_full_reimbursement(project, date)
    rate = project.full_day_reimbursement_rate
    cost = project.cost

    if output_result
      puts "Date #{date} is a full day. Reimbursement rate is #{rate} for a #{cost} cost city."
    end

    rate
  end

  def remove_full_reimbursement(project, date)
    rate = 75

    if output_result
      puts "Removing reimbursement rate of #{rate} for a low cost city on #{date}."
    end

    rate
  end

  def determine_travel_days
    result = [sequence_start, sequence_end]
    project_start_and_end_dates_within_sequence = project_start_and_end_dates - result


    project_start_and_end_dates_within_sequence.reduce do |current_date, next_date|
      next if overlap_or_adjacent_dates?(current_date, next_date)

      result << current_date if current_date

      current_date = next_date unless next_date.nil?
    end

    result.uniq
  end

  def project_start_and_end_dates
    result = project_set.map { |project| [project.start_date, project.end_date] }.flatten
  end

  def overlap_or_adjacent_dates?(current_date, next_date)
    overlapping_dates?(current_date, next_date) || adjacent_dates?(current_date, next_date)
  end

  def overlapping_dates?(current_date, next_date)
    current_date == next_date
  end

  def adjacent_dates?(current_date, next_date)
    previous_day = current_date -= 1 if current_date
    next_day = current_date += 1 if current_date

    next_day == next_date || previous_day == sequence_start || next_day == sequence_end
  end

  def sequence_start
    project_set.first.start_date
  end

  def sequence_end
    project_set.last.end_date
  end
end
