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

  # Check all possible strategies for solving a cell &
  #   return the first one found
  def possible_cell_solution(x, y)
    negation_solution(x, y) ||
    possibilities_minus_exclusions_solution(x, y) ||
    distant_neighbor_negations_solution(x, y)
  end

###############################################################

# NEGATION LOGIC

  # Most basic strategy for solving a cell:
  #   If set of all possibilities in one set of neighbors (row, column, or square)
  #   is missing a single value which is a possibility for this cell, that is the
  #   value of this cell

  # Ex. no neighbors include possibility: 5
  # Cell's possibilities are: [1, 2, 5]
  # Cell is 5

  def negation_solution(x, y)
    negation_value(coords_of_square_neighbors(x, y), x, y) ||
    negation_value(coords_of_row_neighbors(x, y), x, y) ||
    negation_value(coords_of_column_neighbors(x, y), x, y)
  end

  def negation_value(neighbor_coords, x, y)
    possibilities = filled_in_board.cell_possibilities(x, y) -
      neighbor_possibilities(
        neighbor_coords
      ).flatten.uniq

    possibilities.first if possibilities.length == 1
  end

###############################################################

# POSSIBILITIES MINUS EXCLUSIONS LOGIC

  # Second most basic strategy for solving a cell:
  #   Eliminating values in all neighbors in same row, column, and square,
  #   if a single value remains, this is the cell value. Otherwise, anaylze
  #   neighbors for possible 'exclusions'. If exclusions whittle possibilities
  #   down to a single value, this is the cell value.

  def possibilities_minus_exclusions_solution(x, y)
    possibilities = filled_in_board.cell_possibilities(x, y) - exclusions(x, y)
    return possibilities.first if possibilities.length == 1

    possibilities -= exclusions(x, y)
    return possibilities.first if possibilities.length == 1
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

  # Returns array of integers
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

###############################################################

# DISTANT NEIGHBOR NEGATION LOGIC

  # Most complicated strategy for solving a cell:
  #   If only two cells within a square share a possible value
  #   the other cell's neighbors row and column neighbors are analyzed for
  #   negation/exclusion to possibly eliminate the value from the second cell
  #   and leave only the single cell as a candidate within the square for the value

  def distant_neighbor_negations_solution(x, y)
    possibilities = distant_neighbor_negations(x, y)
    possibilities.first if possibilities.length == 1
  end

  def distant_neighbor_negations(x, y)
    coords_of_possibilities = square_neighbors_with_shared_possibilities(x, y)

    coords_of_possibilities.delete_if {|_num, coords| coords.empty? || coords.length > 1 }

    expected_neighbors = []
    coords_of_possibilities.each do |num, coords|
      potential_expected_neighbors = gather_expected_neighbors(*coords.flatten, filled_in_board.determine_square(x, y))

      expected_neighbors << num if potential_expected_neighbors.include? num
    end

    expected_neighbors
  end


  # Return looks like this:
  # {
  #   1 => [[4, 5]],
  #   3 => [[4, 5], [4, 6]]
  #   ...
  # }
  def square_neighbors_with_shared_possibilities(x, y, possibilities = nil)
    possibilities ||= filled_in_board.cell_possibilities(x, y)
    coords_of_possibilities = {}

    possibilities.each do |possibility|
      coords_of_possibilities[possibility] = []

      # Aggregate all square neighbors with matching possibilities
      coords_of_square_neighbors(x, y).each do |sq_neighbor|
        neighbor_possibilities = filled_in_board.cell_possibilities(*sq_neighbor)
        next unless neighbor_possibilities && neighbor_possibilities.include?(possibility)

        coords_of_possibilities[possibility] << sq_neighbor
      end
    end

    coords_of_possibilities
  end

  def gather_expected_neighbors(x, y, sq)
    [].tap do |expected_neighbors|
      expected_neighbors << expected_neighbors(coords_of_row_neighbors(x, y), sq, x, y)
      expected_neighbors << expected_neighbors(coords_of_column_neighbors(x, y), sq, x, y)
    end.flatten.uniq
  end

  def expected_neighbors(coords_of_neighbors, sq, x, y)
    expected_neighbors = []

    coords_of_neighbors.each do |coords|
      current_square = filled_in_board.determine_square(*coords)
      next if current_square == sq # ignore neighbors within square

      possibilities = filled_in_board.cell_possibilities(*coords)
      next unless possibilities

      coords_of_possibilities = square_neighbors_with_shared_possibilities(*coords, possibilities)

      # Value is an expected neighbor if ALL cells in a neighboring square with that
      #   value as a possibility share the same row or column as current cell
      coords_of_possibilities.each do |num, coords|
        expected_neighbors << num if row_or_column_neighbors(coords, x, y)
      end
    end

    expected_neighbors
  end

  def row_or_column_neighbors(coords, x, y)
    coords.all? { |coords| coords[0] == x } ||
      coords.all? { |coords| coords[1] == y }
  end

###############################################################

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
end

###############################################################
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
b = Board.new(cells:
  [
    8, 6, 0, 2, 0, 0, 0, 0, 0,
    0, 0, 5, 3, 4, 0, 0, 0, 0,
    4, 1, 0, 0, 0, 9, 0, 0, 0,
    7, 0, 0, 0, 0, 0, 8, 0, 0,
    0, 0, 0, 7, 9, 6, 0, 0, 0,
    0, 0, 2, 0, 0, 0, 0, 0, 5,
    0, 0, 0, 4, 0, 0, 0, 1, 3,
    0, 0, 0, 0, 6, 7, 5, 0, 0,
    0, 0, 0, 0, 0, 5, 0, 6, 2
  ])

# b = Board.new(cells:
#   [
#     0, 0, 3, 0, 0, 0, 0, 0, 4,
#     1, 0, 4, 3, 0, 0, 0, 2, 0,
#     0, 9, 0, 0, 0, 0, 3, 0, 0,
#     9, 7, 8, 0, 0, 5, 0, 0, 0,
#     0, 0, 0, 4, 0, 8, 0, 0, 0,
#     0, 0, 0, 2, 0, 0, 8, 9, 6,
#     0, 0, 9, 0, 0, 0, 0, 1, 0,
#     0, 2, 0, 0, 0, 7, 5, 0, 8,
#     3, 0, 0, 0, 0, 0, 6, 0, 0
#   ])

##########################
s = Solver.new(board: b)
s.fill_in_board
s.filled_in_board.print_rows
