module Geometry
  class PointInPolygon < Struct.new(:point, :polygon)
    extend Memoist

    MAX_SEED = 1000000.0

    def inside?
      point_location == :inside
    end

    def outside?
      point_location == :outside
    end

    def on_the_boundary?
      point_location == :on_the_boundary
    end

    def point_location
      return :outside unless bounding_box.contains?(point)
      return :on_the_boundary if point_is_vertex? || point_on_edge?

      intersection_count(choose_good_ray).odd? ? :inside : :outside
    end

    delegate :vertices, :edges, :bounding_box, :to => :polygon
    memoize :point_location, :edges, :bounding_box

    private

    def point_is_vertex?
      vertices.any? { |vertex| vertex == point }
    end

    def point_on_edge?
      edges.any? { |edge| edge.contains_point?(point) }
    end

    def choose_good_ray
      ray = random_ray
      seed = 1.0
      while (seed < MAX_SEED) && (! good_ray?(ray)) do
        seed += 1.0
        ray = random_ray(seed)
      end
      ray
    end

    def good_ray?(ray)
      edges.none? { |edge| !edge.length.zero? && edge.parallel_to?(ray) } && vertices.none? { |vertex| ray.contains_point?(vertex) }
    end

    def intersection_count(ray)
      edges.select { |edge| edge.intersects_with?(ray) }.size
    end

    def random_ray(seed = 1.0)
      random_direction = (Math::PI / 2.0 * seed + Math::PI / (seed + 1.0)) % (Math::PI * 2.0)

      ray_endpoint = Point sufficient_ray_radius * Math.cos(random_direction), sufficient_ray_radius * Math.sin(random_direction)
      Segment point, ray_endpoint
    end

    def sufficient_ray_radius
      @sufficient_ray_radius ||= bounding_box.diagonal.length * 2
    end
  end
end
