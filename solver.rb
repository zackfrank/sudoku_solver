# frozen_string_literal: true

require_relative 'board.rb'

class Solver
  attr_accessor :board, :filled_in_board, :change_count

  def initialize(board:)
    @board = board
    @change_count = 0
  end

  def fill_in_board
    @filled_in_board ||= board.dup # rename to solution?

    while filled_in_board.cells.include?(0)
      [*0..8].each do |x|
        [*0..8].each do |y|
          solve_cell(x, y)
        end
      end
    end
  end

  def solve_cell(x, y)
    return unless filled_in_board.empty_cell(x, y)
    return unless (solution = possible_cell_solution(x, y))

    filled_in_board.set_value(x, y, solution)
  end

  def possible_cell_solution(x, y)
    basic_possibilities_solution(x, y) ||
    negation_solution(x, y) ||
    distant_neighbor_negations_solution(x, y)
  end

  def basic_possibilities_solution(x, y)
    possibilities = filled_in_board.cell_possibilities(x, y) - exclusions(x, y)
    possibilities.first if possibilities.length == 1
  end

  def negation_solution(x, y)
    [
      square_negation_possibilities(x, y),
      row_negation_possibilities(x, y),
      column_negation_possibilities(x, y)
    ]
    .find {|possibilities| possibilities.length == 1 }
    &.first
  end

  def distant_neighbor_negations_solution(x, y)
    possibilities = distant_neighbor_negations(x, y)
    possibilities.first if possibilities.length == 1
  end

  def column_negation_possibilities(x, y)
    filled_in_board.cell_possibilities(x, y) -
      neighbor_possibilities(
        coords_of_column_neighbors(x, y)
      ).flatten.uniq
  end

  def row_negation_possibilities(x, y)
    filled_in_board.cell_possibilities(x, y) -
      neighbor_possibilities(
        coords_of_row_neighbors(x, y)
      ).flatten.uniq
  end

  def square_negation_possibilities(x, y)
    filled_in_board.cell_possibilities(x, y) -
      neighbor_possibilities(
        coords_of_square_neighbors(x, y)
      ).flatten.uniq
  end

  def distant_neighbor_negations(x, y)
    coords_of_possibilities = { }

    filled_in_board.cell_possibilities(x, y).each do |possibility|
      coords_of_possibilities[possibility] = []

      coords_of_square_neighbors(x, y).each do |sq_neighbor|
        # collect coords of neighbors with possibilities that match cell
        neighbor_possibilities = filled_in_board.cell_possibilities(*sq_neighbor)
        next unless neighbor_possibilities && neighbor_possibilities.include?(possibility)

        coords_of_possibilities[possibility] << sq_neighbor
      end
    end

    # coords_of_possibilities looks like this:
    # {
    #   1 => [[4, 5]],
    #   3 => [[4, 5], [4, 6]]
    # }

    coords_of_possibilities.delete_if {|_num, coords| coords.empty? || coords.length > 1 }

    expected_neighbors = []
    coords_of_possibilities.each do |num, coords|
      potential_expected_neighbors = gather_expected_neighbors(*coords.first, filled_in_board.determine_square(x, y))

      expected_neighbors << num if potential_expected_neighbors.include? num
    end

    expected_neighbors
  end

  def gather_expected_neighbors(x, y, sq)
    expected_neighbors = []

    coords_of_row_neighbors(x, y).each do |coords|
      current_square = filled_in_board.determine_square(*coords)
      next if current_square == sq # ignore neighbors within square

      possibilities = filled_in_board.cell_possibilities(*coords)
      next unless possibilities

      coords_of_possibilities = { }

      possibilities.each do |pos|
        coords_of_possibilities[pos] = []

        coords_of_square_neighbors(*coords).each do |sq_neighbor|
          # collect coords of neighbors with possibilities that match cell
          neighbor_possibilities = filled_in_board.cell_possibilities(*sq_neighbor)
          next unless neighbor_possibilities && neighbor_possibilities.include?(pos)

          coords_of_possibilities[pos] << sq_neighbor
        end
      end

      coords_of_possibilities.each do |num, coords|
        expected_neighbors << num if coords.all? {|coords| coords[0] == y}
      end
    end

    coords_of_column_neighbors(x, y).each do |coords|
      current_square = filled_in_board.determine_square(*coords)
      next if current_square == sq # ignore neighbors within square

      possibilities = filled_in_board.cell_possibilities(*coords)
      next unless possibilities

      coords_of_possibilities = { }

      possibilities.each do |pos|
        coords_of_possibilities[pos] = []
        coords_of_square_neighbors(*coords).each do |sq_neighbor|
          # collect coords of neighbors with possibilities that match cell
          neighbor_possibilities = filled_in_board.cell_possibilities(*sq_neighbor)
          next unless neighbor_possibilities && neighbor_possibilities.include?(pos)

          coords_of_possibilities[pos] << sq_neighbor
        end
      end

      coords_of_possibilities.each do |num, coords|
        expected_neighbors << num if coords.all? {|coords| coords[0] == x}
      end
    end

    expected_neighbors.uniq
  end

  # These are values that the current cell could NOT be
  def exclusions(x, y)
    column_possibilities = neighbor_possibilities(coords_of_column_neighbors(x, y))
    row_possibilities = neighbor_possibilities(coords_of_row_neighbors(x, y))
    square_possibilities = neighbor_possibilities(coords_of_square_neighbors(x, y))

    [].tap do |exclusions|
      exclusions << neighbor_exclusions(column_possibilities)
      exclusions << neighbor_exclusions(row_possibilities)
      exclusions << neighbor_exclusions(square_possibilities)
    end.flatten(2).uniq
  end

  def coords_of_column_neighbors(x, y)
    [*0..8].reject { |n| n == y }.map { |y| [x, y] }
  end

  def coords_of_row_neighbors(x, y)
    [*0..8].reject { |n| n == x }.map { |x| [x, y] }
  end

  def coords_of_square_neighbors(x, y)
    square = filled_in_board.determine_square(x, y)
    neighbors = []
    case square
    when 0
      [*0..2].each {|x| [*0..2].each {|y| neighbors << [x, y] } }
    when 1
      [*3..5].each {|x| [*0..2].each {|y| neighbors << [x, y] } }
    when 2
      [*6..8].each {|x| [*0..2].each {|y| neighbors << [x, y] } }
    when 3
      [*0..2].each {|x| [*3..5].each {|y| neighbors << [x, y] } }
    when 4
      [*3..5].each {|x| [*3..5].each {|y| neighbors << [x, y] } }
    when 5
      [*6..8].each {|x| [*3..5].each {|y| neighbors << [x, y] } }
    when 6
      [*0..2].each {|x| [*6..8].each {|y| neighbors << [x, y] } }
    when 7
      [*3..5].each {|x| [*6..8].each {|y| neighbors << [x, y] } }
    when 8
      [*6..8].each {|x| [*6..8].each {|y| neighbors << [x, y] } }
    end
    neighbors.tap {|neighbors| neighbors.delete([x, y])}
  end

  # returns array of integers
  def neighbor_possibilities(coords_of_neighborhood)
    coords_of_neighborhood.map do |coords|
      filled_in_board.cell_possibilities(*coords)
    end.compact
  end

  # When the number of neighbors that have a certain combination of possibilities
  #   equals the number of possibilities, only those neighbors can possibly 
  #   contain those possibilities
  #     Ex: two neighbors have possibilities [1, 9]
  #     if one is 1, the other is 9 and vice versa!
  def neighbor_exclusions(neighbor_possibilities)
    neighbor_possibilities.select do |possibilities|
      neighbor_possibilities.count(possibilities) == possibilities.length
    end
  end
end

# EASY
# b = Board.new(cells:
#   [
#     0, 0, 2, 1, 0, 8, 5, 0, 3,
#     0, 0, 0, 0, 2, 0, 9, 0, 7,
#     8, 0, 0, 3, 9, 0, 0, 0, 0,
#     3, 1, 7, 6, 0, 0, 0, 0, 0,
#     4, 6, 0, 0, 5, 0, 0, 7, 2,
#     0, 0, 0, 0, 0, 4, 8, 1, 6,
#     0, 0, 0, 0, 7, 3, 0, 0, 5,
#     5, 0, 6, 0, 1, 0, 0, 0, 0,
#     1, 0, 3, 5, 0, 6, 7, 0, 0
#   ])

# MEDIUM
# b = Board.new(cells:
#   [
#     0, 9, 0, 4, 0, 6, 0, 3, 0,
#     8, 0, 0, 0, 0, 7, 0, 0, 9,
#     2, 0, 3, 0, 8, 0, 0, 0, 4,
#     0, 2, 9, 1, 0, 0, 0, 0, 0,
#     0, 0, 0, 0, 0, 0, 0, 0, 0,
#     0, 0, 0, 0, 0, 5, 8, 2, 0,
#     5, 0, 0, 0, 7, 0, 6, 0, 1,
#     3, 0, 0, 9, 0, 0, 0, 0, 7,
#     0, 8, 0, 6, 0, 1, 0, 4, 0
#   ])

# HARD
# b = Board.new(cells:
#   [
#     0, 0, 0, 3, 0, 6, 0, 5, 0,
#     0, 0, 3, 1, 0, 0, 9, 4, 0,
#     5, 0, 0, 0, 2, 0, 0, 0, 0,
#     2, 8, 0, 0, 0, 0, 7, 0, 0,
#     0, 3, 0, 0, 8, 0, 0, 6, 0,
#     0, 0, 6, 0, 0, 0, 0, 9, 4,
#     0, 0, 0, 0, 9, 0, 0, 0, 7,
#     0, 7, 9, 0, 0, 1, 5, 0, 0,
#     0, 2, 0, 8, 0, 7, 0, 0, 0
#   ])

# EVIL
# b = Board.new(cells:
#   [
#     8, 6, 0, 2, 0, 0, 0, 0, 0,
#     0, 0, 5, 3, 4, 0, 0, 0, 0,
#     4, 1, 0, 0, 0, 9, 0, 0, 0,
#     7, 0, 0, 0, 0, 0, 8, 0, 0,
#     0, 0, 0, 7, 9, 6, 0, 0, 0,
#     0, 0, 2, 0, 0, 0, 0, 0, 5,
#     0, 0, 0, 4, 0, 0, 0, 1, 3,
#     0, 0, 0, 0, 6, 7, 5, 0, 0,
#     0, 0, 0, 0, 0, 5, 0, 6, 2
#   ])

b = Board.new(cells:
  [
    0, 0, 3, 0, 0, 0, 0, 0, 4,
    1, 0, 4, 3, 0, 0, 0, 2, 0,
    0, 9, 0, 0, 0, 0, 3, 0, 0,
    9, 7, 8, 0, 0, 5, 0, 0, 0,
    0, 0, 0, 4, 0, 8, 0, 0, 0,
    0, 0, 0, 2, 0, 0, 8, 9, 6,
    0, 0, 9, 0, 0, 0, 0, 1, 0,
    0, 2, 0, 0, 0, 7, 5, 0, 8,
    3, 0, 0, 0, 0, 0, 6, 0, 0
  ])

##########################
s = Solver.new(board: b)
s.fill_in_board
s.filled_in_board.print_rows
