require 'csv'

INPUT_FILE = './day_1_input.csv'

full_dataset = CSV.parse(File.read(INPUT_FILE), headers: true)

set_1, set_2 = [], []

full_dataset.each do |values|
  set_1 << values['left_list'].to_i
  set_2 << values['right_list'].to_i
end

def calculate_differences(set_1, set_2)
  merged_list = set_1.sort.zip(set_2.sort)
  merged_list.map { |val_1, val_2| (val_1 - val_2).abs }.reduce(:+)
end

p calculate_differences(set_1, set_2)

def calculate_similarity(set_1, set_2)
  similarity = set_1.map { |value| set_2.count(value) * value }
  similarity.sum
end

p calculate_similarity(set_1, set_2)
