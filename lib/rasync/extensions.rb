module Rasync

  CLASSES_TO_EXTEND = [ Array,
                        Hash,
                        Module,
                        Numeric,
                        Range,
                        String,
                        Symbol ]


  module Extensions

    def async_send(selector, *args)
      async_send_opts(selector, {}, *args)
    end

    def async_send_opts(selector, opts, *args)
      Rasync::Queue.put_call!(self, selector, opts, args)
    end

  end

end

Rasync::CLASSES_TO_EXTEND.each { |c| c.send :include, Rasync::Extensions }

#class Object
#  def rrepr()
#    raise ArgumentError.new('no consistent external repr for ' + self.inspect)
#  end
#end

class Symbol
  def rrepr() inspect end
end

class Module
  def rrepr() name end
end

class NilClass
  def rrepr() inspect end
end

class FalseClass
  def rrepr() inspect end
end

class TrueClass
  def rrepr() inspect end
end

class Numeric
  def rrepr() inspect end
end

class String
  def rrepr() inspect end
end

class Array
  def rrepr() '[' + map(&:rrepr).join(', ') + ']' end
end

class Hash
  def rrepr() '{' + map{|k,v| k.rrepr + '=>' + v.rrepr}.join(', ') + '}' end
end

class Range
  def rrepr() "(#{first.rrepr}#{exclude_end? ? '...' : '..'}#{last.rrepr})" end
end

class Time
  def rrepr() "Time.parse('#{self.inspect}')" end
end

class Date
  def rrepr() "Date.parse('#{self.strftime("%Y-%m-%d")}')" end
end
