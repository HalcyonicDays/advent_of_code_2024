class Graph
  attr_accessor :vertices, :edges

  def initialize
    @vertices = []
    @edges = {}
  end

  def add_vertex(vertex)
    @vertices << vertex
    @edges[vertex] = {}
  end

  def add_edge(vertex1, vertex2, weight)
    @edges[vertex1][vertex2] = weight
    @edges[vertex2][vertex1] = weight
  end

  def dijkstra(start_vertex)
    distances = {}
    previous_vertices = {}
    vertices = @vertices.clone

    vertices.each do |vertex|
      previous_vertices[vertex] = nil
    end

    distances[start_vertex] = 0

    until vertices.empty?
      closest_vertex = vertices.min_by { |vertex| distances.fetch(vertex) {100_000} }
      vertices.delete(closest_vertex)

      @edges[closest_vertex].each do |neighbor, weight|
        next unless distances.key?(closest_vertex) && distances.key?(neighbor)
        alternative_route = distances[closest_vertex] + weight
        if alternative_route < distances[neighbor]
          distances[neighbor] = alternative_route
          previous_vertices[neighbor] = closest_vertex
        end
      end
    end

    { distances: distances, previous_vertices: previous_vertices }
  end

  def shortest_path(start_vertex, end_vertex)
    result = dijkstra(start_vertex)
    path = []
    current_vertex = end_vertex

    while current_vertex
      path.unshift(current_vertex)
      current_vertex = result[:previous_vertices][current_vertex]
    end

    path
  end
end

# Example usage:
graph = Graph.new
graph.add_vertex('A')
graph.add_vertex('B')
graph.add_vertex('C')
graph.add_vertex('D')
graph.add_vertex('E')

graph.add_edge('A', 'B', 4)
graph.add_edge('A', 'C', 2)
graph.add_edge('B', 'C', 3)
graph.add_edge('B', 'D', 2)
graph.add_edge('B', 'E', 3)
graph.add_edge('C', 'B', 1)
graph.add_edge('C', 'D', 4)
graph.add_edge('C', 'E', 5)
graph.add_edge('E', 'D', 1)

start_vertex = 'A'
end_vertex = 'D'
shortest_path = graph.shortest_path(start_vertex, end_vertex)
puts "Shortest path from #{start_vertex} to #{end_vertex}: #{shortest_path.join(' -> ')}"