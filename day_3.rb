INPUT_FILE = './day_3_input.txt'
pattern = /(mul\(\d+\,\d+\)|do\(\)|don't\(\))/

def injest_file(file)
  contents = ''
  File.open (file) do |f|
    f.each { |element| contents += element }
  end
  contents
end

def interpret_multiplication(mul)
  nums = mul.delete('mul(').delete(')').split(',')
  nums.map(&:to_i).reduce(:*)
end

def process_instructions(instructions)
  operations = []
  enabled = true
  
  instructions.each do |operation|
    case operation
    when "do()"    then enabled = true
    when "don't()" then enabled = false
    else operations << operation if enabled
    end
  end

  operations
end

full_string = injest_file(INPUT_FILE)
instructions = full_string.scan(pattern).flatten
operations = process_instructions(instructions)
results = operations.map { |mul| interpret_multiplication(mul) }
p results.reduce(:+)
