INPUT = './day_7_input.txt'
input = File.readlines(INPUT, chomp: true)

def process_input(row)
  row_split = row.split(":")
  test_value = row_split[0].to_i
  operands = row_split[1].split.map(&:to_i)
  [test_value, operands]
end

def recursive_review(value, operands)
  return value.zero? if operands.empty?
    
  current_operand = operands.last
  new_operands = operands.slice(0...-1)
  
  new_value = value - current_operand
  result = recursive_review(new_value, new_operands)
  return result if result

  if (value % current_operand).zero?
    new_value = value / current_operand
    result = recursive_review(new_value, new_operands)
    return result if result
  end

  # Added for Part 2
  lookback = current_operand.to_s.size * -1
  if value.to_s[lookback..-1] == current_operand.to_s
    new_value = value.to_s[0...lookback].to_i
    result = recursive_review(new_value, new_operands)
    return result if result
  end
  
  return false
end

valid_rows = []

input.each do |row|
  value, operands = process_input(row)
  test_case = recursive_review(value, operands)
  valid_rows << value if test_case
end

p valid_rows.size
p valid_rows.reduce(:+)
