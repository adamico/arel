module Arel
  module Predicates
    class Predicate
      def or(other_predicate)
        Or.new(self, other_predicate)
      end

      def and(other_predicate)
        And.new(self, other_predicate)
      end
    end

    class Binary < Predicate
      attributes :operand1, :operand2, :compounds, :compound_with
      def initialize(operand1, operand2, *args)
        @operand1 = operand1
        @operand2 = operand2
        @compound_with = (args.last.is_a?(Hash) ? args.pop[:compound_with] : :or) || :or
        @compounds = args
      end

      def ==(other)
        self.class === other               and
        @operand1      ==  other.operand1  and
        @operand2      ==  other.operand2  and
        @compounds     ==  other.compounds and
        @compound_with == other.compound_with
      end

      def bind(relation)
        self.class.new(operand1.find_correlate_in(relation), operand2.find_correlate_in(relation))
      end
    end

    class Equality < Binary
      def ==(other)
        Equality === other and
          ((operand1 == other.operand1 and operand2 == other.operand2) or
           (operand1 == other.operand2 and operand2 == other.operand1)) and
          compounds == other.compounds and
          compound_with == other.compound_with
      end
    end

    class Not                   < Equality; end
    class GreaterThanOrEqualTo  < Binary; end
    class GreaterThan           < Binary; end
    class LessThanOrEqualTo     < Binary; end
    class LessThan              < Binary; end
    class Match                 < Binary; end
    class NotMatch              < Binary; end
    class In                    < Binary; end
    class NotIn                 < Binary; end
  end
end
