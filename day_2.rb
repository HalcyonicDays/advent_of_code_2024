=begin
Summary:
- Puzzle input contains mutiple reports
- A report is a single line of data
- Each report contains multiple levels (columns)
- Determine which reports are safe:
  - Levels are either all increasing or all decreasing
  - Any two adjacent levels differ by 1-3

Problem: Determine the number of "safe" reports (rows) are based on levels (columns)

Explicit Requirements:
- Levels are either all increasing or all decreasing
- Any two adjacent levels differ by 1-3

Implicit Requirements:
- Adjacent levels that are the same value are not safe
- Levels cannot be negative? (this shouldn't matter either way)
- Not all rows wil have the same number of levels
- A row with exactly one level is safe?
- A row with exactly 2 levels is guaranteed to be ascending or descending

Input : Multiple rows of data
Output: Total count of "safe" reports

Data Structure: Array

Algorithm:
- Determine if row is safe:
  - helper method for inceasing values & decreasing values
    - check if report is in sorted order (ascending) or
      reverse-sorted order (descending)
  - helper method for level-to-level differences
    - starting with 2nd element (index 1), compare difference with
      previous (n - 1) element.
    - include guard clause to avoid reports that are just 1 level
      since report[1] = nil will throw an erorr otherwise
- Assign a true/false for safety
- count & return the number of safe rows


Problem Dampener - Additional information
- A report is also considered safe if a level can be removed,
  and the report then passes
- In other words instead of all n levels being save, only
  n-1 number of levels need to be safe
- Since some number of levels will already be safe, the Problem
  Dampener test only needs to be run on otherwise unsafe reports

Algorithm Update:
- Add an additional "or problem_dampened?" helper method logic check
  - this method will systematically remove one level at a time (with 
    replacement) until the report passes
  - passing criteria will be identical to previous attempts, so those
    methods will be reused
=end

require 'csv'

INPUT_FILE = './day_2_input.csv'
full_dataset = CSV.parse(File.read(INPUT_FILE), headers: false)

def is_safe?(report)
  (all_one_direction?(report) && no_spikes?(report)) || problem_dampened?(report)
end

def all_one_direction?(report)
  sorted = report.sort
  report == sorted || report == sorted.reverse
end

def no_spikes?(report)
  1.upto(report.size - 1) do |n|
    return false unless (report[n] - report[n-1]).abs in (1..3)
  end
  true
end

def problem_dampened?(report)
  0.upto(report.size - 1) do |n|
    sub_report = []
    report.each_with_index do |level, idx|
      sub_report << level unless idx == n 
    end
    return true if all_one_direction?(sub_report) && no_spikes?(sub_report)
  end
  false
end

full_dataset.each { |report| report.map!(&:to_i) }
p full_dataset.select { |report| is_safe?(report) }.size
