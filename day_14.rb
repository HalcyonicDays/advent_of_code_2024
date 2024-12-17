ROOM_WIDTH  = 101
ROOM_LENGTH = 103
HALF_WIDTH  = (ROOM_WIDTH  - 1) / 2
HALF_LENGTH = (ROOM_LENGTH - 1) / 2

SECONDS = 100
regex = /p=(?<x_start>\d+),(?<y_start>\d+) v=(?<delta_x>-?\d+),(?<delta_y>-?\d+)/

class Robot
  attr_reader :delta_x, :delta_y
  attr_accessor :x_pos, :y_pos, :quadrant

  def initialize(params)
    @x_pos = params['x_start'].to_i
    @y_pos = params['y_start'].to_i
    
    @delta_x = params['delta_x'].to_i
    @delta_y = params['delta_y'].to_i
  end

  def move(seconds=1)
    self.x_pos = (delta_x * seconds + x_pos) % ROOM_WIDTH
    self.y_pos = (delta_y * seconds + y_pos) % ROOM_LENGTH
    # p [new_x, new_y]
  end

  def quadrant
    left_right = case x_pos
                 when 0...HALF_WIDTH               then 'left'
                 when (HALF_WIDTH + 1)..ROOM_WIDTH then 'right'
                 when HALF_WIDTH                   then 'middle'
                 else p 'x_problem'
                 end

    top_bottom = case y_pos
                 when 0...HALF_LENGTH                then 'top'
                 when (HALF_LENGTH + 1)..ROOM_LENGTH then 'bottom'
                 when HALF_LENGTH                    then 'middle'
                 else p 'y_problem'
                 end
    "#{top_bottom}-#{left_right}"
  end
end

def draw_floor(positions)
  floor = Array.new(ROOM_LENGTH) {" " * ROOM_WIDTH}
  floor.each_with_index do |column, y_pos|
    column.chars.each_with_index do |_space, x_pos|
      floor[y_pos][x_pos] = GLYPH if positions.include?([x_pos, y_pos])
    end
  end
  puts floor
end

GLYPH = 'Ǽ'
INPUT  = './day_14_input.txt'
ROBOTS = File.read(INPUT)

positions = []
ROBOTS.each_line do |line| 
  positions << Robot.new(line.match(regex).named_captures)
end

new_positions = []

# Part 1
positions.each do |robot| 
  robot.move(100)
  new_positions << robot.quadrant
end

p new_positions.reject { |quadrant| quadrant =~ /middle/ }.tally.values.reduce(:*)

# Part 2
counter = 0
loop do 
  new_positions = []
  
  positions.each do |robot| 
    robot.move
    new_positions << [robot.x_pos, robot.y_pos]
  end
  counter += 1
  
  safety = new_positions.reject { |quadrant| quadrant =~ /middle/ }.tally.values.reduce(:*)
  if safety < 10
    # p [counter, safety]
    puts "#{counter} seconds have passed"
    draw_floor(new_positions)
  end

  break if counter > 10_000
end
