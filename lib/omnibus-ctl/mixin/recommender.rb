
module Omnibus
  module Mixin
    module Recommender
      MAX_EDIT_DISTANCE = 4

      def find_recommendation(arg, candidates)
        require 'levenshtein'
        possible = {}
        candidates.each do |s|
          possible[s] = Levenshtein.distance(arg, s)
        end
        best = nil
        min = nil
        possible.each do |k, v|
          if v < MAX_EDIT_DISTANCE && (!min || v < min)
            best = k
            min = v
          end
        end
        best
      end
    end
  end
end
