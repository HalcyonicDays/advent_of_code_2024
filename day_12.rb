INPUT  = './day_12_input.txt'
GARDEN = File.read(INPUT).split("\n")

CLUSTERS = {}
VISITED_PLOTS = []

def find_neighbors(x_pos, y_pos, value=nil, key=nil)
  
  local_value = GARDEN[y_pos][x_pos]
  if value.nil? && key.nil?
    key = [x_pos, y_pos]
    CLUSTERS[key] = [key]
    value = local_value
  end

  return nil unless local_value == value

  neighbor_positions(x_pos, y_pos).each do |neighbor_x, neighbor_y|
    next if VISITED_PLOTS.include?([neighbor_x, neighbor_y])
    if GARDEN[neighbor_y][neighbor_x] == value
      CLUSTERS[key] << [neighbor_x, neighbor_y] unless VISITED_PLOTS.include?([neighbor_x, neighbor_y])
      VISITED_PLOTS << [neighbor_x, neighbor_y]
      find_neighbors(neighbor_x, neighbor_y, value, key)
    end
  end
end

def neighbor_positions(x_pos, y_pos)
  neighbors = []
  neighbors << [x_pos + 1, y_pos] unless x_pos + 1> GARDEN.size - 1
  neighbors << [x_pos - 1, y_pos] unless x_pos - 1 < 0
  neighbors << [x_pos, y_pos + 1] unless y_pos + 1 > GARDEN.size - 1
  neighbors << [x_pos, y_pos - 1] unless y_pos - 1 < 0
  neighbors
end

def calulate_area(region)
  region.size
end

def calulate_perimeter(region)
  perimeter = 0
  
  region.each do |x_pos, y_pos|
    fences = 4
    neighbor_positions(x_pos, y_pos).each do |location|
      fences -= 1 if region.include?(location)
    end
    perimeter += fences
  end

  perimeter
end

def count_corners(region)
  corners = 0
  
  GARDEN << ('*' * GARDEN.size)
  GARDEN.each_with_index do |row, y_pos|
    row += "*"
    row.chars.each_with_index do |column, x_pos|
      case (mini_grid(x_pos, y_pos) & region).size
      when 1, 3 then corners += 1
      when 2    then corners += 2 if kitty_corner?(region, x_pos, y_pos)
      end
    end
  end
  
  corners
end

def mini_grid(x_pos, y_pos)
  two_by_two_grid =  [[x_pos, y_pos]]
  two_by_two_grid << [x_pos - 1, y_pos] unless x_pos - 1 < 0
  two_by_two_grid << [x_pos, y_pos - 1] unless y_pos - 1 < 0
  two_by_two_grid << [x_pos - 1, y_pos - 1] unless (y_pos - 1 < 0 || x_pos - 1 < 0)
  (4 - two_by_two_grid.size).times { two_by_two_grid << nil }
  two_by_two_grid
end

def kitty_corner?(region, x_pos, y_pos)
  (region.include?([x_pos, y_pos]) && region.include?([x_pos - 1, y_pos - 1])) ||
  (region.include?([x_pos - 1, y_pos]) && region.include?([x_pos, y_pos - 1]))
end

GARDEN.each_with_index do |row, x_pos|
  row.chars.each_with_index do |plot, y_pos|
    next if VISITED_PLOTS.include?([x_pos, y_pos])
    find_neighbors(x_pos, y_pos)
  end
end

CLUSTERS.each { |_, region| region.uniq!}

p1_fencing = CLUSTERS.map { |id, region| [id, calulate_area(region) * calulate_perimeter(region)] }.to_h
p p1_fencing.values.reduce(:+)

p2_fencing = CLUSTERS.map { |id, region| [id, calulate_area(region) * count_corners(region)] }.to_h
p p2_fencing.values.reduce(:+)
