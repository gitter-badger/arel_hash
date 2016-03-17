# temporary fix for arel issue: see https://github.com/rails/arel/pull/414
module Arel
  module Nodes
    class Casted
      unless self.instance_methods(false).include? :hash
        def hash
          [self.class, self.val, self.attribute].hash
        end
      end
    end
  end
end
