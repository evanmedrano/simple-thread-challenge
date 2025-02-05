require 'spec_helper'
require_relative '../../services/reimbursement_calculation_service'
require_relative '../../models/project'

RSpec.describe 'ReimbursementCalculationService' do
  context 'when one project is in the set' do
    context 'with the project starting and ending on the same day' do
      it 'calculates both days as travel days for a low cost city' do
        project_set = [Project.assign(cost: 'low', start_date: '9/1/15', end_date: '9/1/15')]

        expect(ReimbursementCalculationService.call(project_set)).to eq(45)
      end

      it 'calculates both days as travel days for a high cost city' do
        project_set = [Project.assign(cost: 'high', start_date: '9/1/15', end_date: '9/1/15')]

        expect(ReimbursementCalculationService.call(project_set)).to eq(55)
      end
    end

    context 'with the project lasting multiple days' do
      it 'calculates all days accordingly for a low cost city' do
        # Set 1
        project_set = [Project.assign(cost: 'low', start_date: '9/1/15', end_date: '9/3/15')]

        # 2 travel days x 45 = 90
        # 1 full day = 75
        # total = 165

        puts "Set 1"

        expect(ReimbursementCalculationService.call(project_set, output_result: true)).to eq(165)
      end
    end
  end

  context 'when multiple projects are in the set' do
    it 'calculates all days accordingly' do
      # Set 2
      project_set = [
        Project.assign(cost: 'low', start_date: '9/1/15', end_date: '9/1/15'),
        Project.assign(cost: 'high', start_date: '9/2/15', end_date: '9/6/15'),
        Project.assign(cost: 'low', start_date: '9/6/15', end_date: '9/8/15')
      ]

      # project 1 (low)
        # 1 travel day = 45
      # project 2 (high)
        # 5 full days x 85 = 510
      # project 3 (low)
        # 1 travel day = 45
        # 1 full day = 75
      # total = 675

      puts "Set 2"

      expect(ReimbursementCalculationService.call(project_set, output_result: true)).to eq(590)
    end

    it 'calculates all days accordingly' do
      # Set 3
      project_set = [
        Project.assign(cost: 'low', start_date: '9/1/15', end_date: '9/3/15'),
        Project.assign(cost: 'high', start_date: '9/5/15', end_date: '9/7/15'),
        Project.assign(cost: 'high', start_date: '9/8/15', end_date: '9/8/15')
      ]

      # project 1 (low)
        # 2 travel days x 45 = 90
        # 1 full day = 75
      # project 2 (high)
        # 1 travel day = 55
        # 2 full days x 85 = 170
      # project 3 (high)
        # 1 travel day = 55
      # total = 445

      puts "Set 3"

      expect(ReimbursementCalculationService.call(project_set, output_result: true)).to eq(445)
    end

    it 'calculates all days accordingly' do
      # Set 4
      project_set = [
        Project.assign(cost: 'low', start_date: '9/1/15', end_date: '9/1/15'),
        Project.assign(cost: 'low', start_date: '9/1/15', end_date: '9/1/15'),
        Project.assign(cost: 'high', start_date: '9/2/15', end_date: '9/2/15'),
        Project.assign(cost: 'high', start_date: '9/2/15', end_date: '9/3/15')
      ]

      # project 1 (low)
        # 1 travel day = 45
      # project 2 (low)
        # no additional days
      # project 3 (high)
        # 1 full day = 85
      # project 4 (high)
        # 1 travel day = 55
      # total = 185

      puts "Set 4"

      expect(ReimbursementCalculationService.call(project_set, output_result: true)).to eq(185)
    end
  end
end
