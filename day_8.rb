INPUT = './day_8_input.txt'
GRID = File.readlines(INPUT, chomp: true)

def find_all_antennae(grid)
  antennae = {}
  
  grid.each_with_index do |row, x_pos|
    row.chars.each_with_index do |space, y_pos|
      next if space == '.'
      antennae[space] ||= []
      antennae[space] << [x_pos, y_pos]
    end
  end
  antennae
end

def find_all_antinodes(antennae_group)
  x1, y1 = antennae_group[0][0], antennae_group[0][1]
  x2, y2 = antennae_group[1][0], antennae_group[1][1]
  delta_x = x1 - x2
  delta_y = y1 - y2
  [[x1 + delta_x, y1 + delta_y], [x2 - delta_x, y2 - delta_y]]
end

def clean_list(antinodes)
  in_map = antinodes.map do |antenna, nodes|
    nodes.select { |node| node_in_bounds?(node) }
  end
  clean_list = []
  in_map.each do |node_set|
    node_set.each { |node| clean_list << node }
  end
  clean_list.uniq
end

def node_in_bounds?(node)
  (0...GRID.size).cover?(node[0]) && 
  (0...GRID.size).cover?(node[1])
end

antennae = find_all_antennae(GRID)
antinodes = {}

antennae.each do |designation, locations|
  antinodes[designation] = []
  locations.combination(2) do |antenna_pairs|
    find_all_antinodes(antenna_pairs).each { |pair| antinodes[designation] << pair }
  end
end

antinode_locations = clean_list(antinodes)
p antinode_locations.size

# Part 2

def get_deltas(antennae_group)
  x1, y1 = antennae_group[0][0], antennae_group[0][1]
  x2, y2 = antennae_group[1][0], antennae_group[1][1]
  delta_x = x1 - x2
  delta_y = y1 - y2
  [delta_x, delta_y]
end

def find_all_antinodes_with_harmonics(pair, deltas)
  antinodes = []
  pair.each do |antenna|
    nodes = get_nodes(antenna, deltas)
    nodes.each { |node| antinodes << node }
  end
  antinodes.uniq
end

def get_nodes(antenna, deltas)
  nodes = []
  delta_x, delta_y = deltas[0], deltas[1]

  (-GRID.size).upto(GRID.size) do |factor|
    node = [antenna[0] + delta_x * factor, antenna[1] + delta_y * factor]
    node if node_in_bounds?(node)
    nodes << node if node_in_bounds?(node)
  end
  nodes
end

harmonics = {}
antennae.each do |designation, locations|
  harmonics[designation] = []
  locations.combination(2) do |antenna_pairs|
    deltas = get_deltas(antenna_pairs)
    harmonics[designation] << find_all_antinodes_with_harmonics(antenna_pairs, deltas)
  end
end

all_hamonic_nodes = []
harmonics.values.flatten.each_slice(2) do |x, y|
  all_hamonic_nodes << [x, y]
end

p all_hamonic_nodes.uniq.size
