require 'minitest/autorun'
require 'geometry'

class ContainsPointTest < MiniTest::Unit::TestCase
  include Geometry

  def test_convex
    rectangle = Polygon.new [
                             Point(0, 0),
                             Point(1, 0),
                             Point(1, 1),
                             Point(0, 1)
                            ]
    

    inner = Point(0.5, 0.5)
    assert rectangle.contains?(inner)

    outer = Point(1.5, 1.5)
    assert ! rectangle.contains?(outer)

    on_edge = Point(0.5, 1)
    assert rectangle.contains?(on_edge)

    at_vertex = Point(1, 1)
    assert rectangle.contains?(at_vertex)
  end
  

  # +--------+
  # |        |
  # |    +---+
  # |    |
  # |    +---+
  # |        |
  # +--------+ 

  def test_nonconvex
    nonconvex_polygon = Polygon.new [
                                     Point(0, 0),
                                     Point(0, 6),
                                     Point(4, 6),
                                     Point(4, 4),
                                     Point(2, 4),
                                     Point(2, 2),
                                     Point(4, 2),
                                     Point(4, 0)
                                    ]

    inner_points = [
                    Point(1, 5),
                    Point(3, 5),
                    Point(1, 3),
                    Point(1, 1),
                    Point(3, 1)
                   ]

    outer_points = [
                    Point(7, 5),
                    Point(5, 3),
                    Point(7, 3),
                    Point(7, 1)
                   ]

    inner_points.each do |inner_point|
      assert nonconvex_polygon.contains?(inner_point)
    end

    outer_points.each do |outer_point|
      assert ! nonconvex_polygon.contains?(outer_point)
    end
  end

  def test_closed_polygon
    coordinates_raw = "114.146011,22.284090 114.145050,22.282860 114.146240,22.279619 114.151176,22.277014 114.151833,22.276251 114.151443,22.275000 114.151550,22.273470 114.153198,22.272249 114.156143,22.272970 114.161690,22.271900 114.162521,22.274820 114.162697,22.276211 114.160957,22.275850 114.159927,22.276190 114.158340,22.276270 114.157082,22.276661 114.155312,22.276310 114.153732,22.278000 114.154312,22.278870 114.153992,22.279900 114.152321,22.280890 114.150261,22.282721 114.146011,22.284090"
    coordinates = coordinates_raw.split(/\s+/).map do |raw_coor|
      # latitude and longitude are reversed since they are from KML
      # most important point : the last point is the same as the first one
      raw_coor.split(',').map(&:to_f).reverse
    end

    vertices = coordinates.map do |coordinate_array|
      Point.new_by_array(coordinate_array)
    end
    rectangle = Polygon.new(vertices)

    inner = Point(22.2817, 114.14932)
    assert rectangle.contains?(inner)
  end
end
