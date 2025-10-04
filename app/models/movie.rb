class Movie < ActiveRecord::Base
    # Return all possible MPAA ratings
    def self.all_ratings
      # If your seeds ever add new ratings, you can compute dynamically:
      # distinct.order(:rating).pluck(:rating)
      %w[G PG PG-13 R]
    end
  
    # Return movies whose rating is in ratings_list (case-insensitive).
    # If ratings_list is nil or empty, return all movies.
    def self.with_ratings(ratings_list)
      return all unless ratings_list.present?
  
      # Case-insensitive match in case data uses mixed case
      upcased = ratings_list.map(&:upcase)
      where('UPPER(rating) IN (?)', upcased)
    end
end
