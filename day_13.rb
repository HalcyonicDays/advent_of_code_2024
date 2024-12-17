INPUT    = './day_13_input.txt'
MACHINES = File.read(INPUT)

regex    = /\D*A: X\D*(?<a_x>\d+), Y\D*(?<a_y>\d+)\D*B: X\D*(?<b_x>\d+), Y\D*(?<b_y>\d+)\D*X=(?<prize_x>\d+), Y=(?<prize_y>\d+)/
winnable = []

input    = MACHINES
OFFSET   = 10_000_000_000_000

def generate_matrix(params)
  [
    [params['a_x'].to_i, params['b_x'].to_i], 
    [params['a_y'].to_i, params['b_y'].to_i]
  ]
end

def get_prize_location(params)
  [
    params['prize_x'].to_i + OFFSET, 
    params['prize_y'].to_i + OFFSET
  ]
end

class TwoByTwoMatrix
  attr_reader :a, :b, :c, :d, :inverse

  def initialize(matrix, invert=true)
    @a = matrix[0][0]
    @b = matrix[0][1]
    @c = matrix[1][0]
    @d = matrix[1][1]

    @inverse = TwoByTwoMatrix.new(invert_matrix, false) if invert    
  end

  def invert_matrix
    factor = 1.0 / (a * d - b * c)

    [[d, -b], [-c, a]].map do |row|
      row.map { |value| value * factor }  
    end
  end

  def matrix_multiplication(prizes)
    first_term  = inverse.a * prizes[0] + inverse.b * prizes[1]
    second_term = inverse.c * prizes[0] + inverse.d * prizes[1]
    [first_term, second_term]
  end
end

def valid_solution?(result)
  result.each do |value|
    return false unless [0.0, 1.0].include? (value.to_i - value.round(2)).abs
  end
end

input.split("\n\n").each do |claw_machine|
  params = claw_machine.match(regex).named_captures
  matrix = generate_matrix(params)
  prizes = get_prize_location(params)
  
  results = TwoByTwoMatrix.new(matrix).matrix_multiplication(prizes)
  winnable << results.map { |value| value.round(0) } if valid_solution?(results)
end

p winnable.map { |a_press, b_press| a_press * 3 + b_press }.reduce(:+)
