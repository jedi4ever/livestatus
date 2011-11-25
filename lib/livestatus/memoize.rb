module Memoize

  def memoize(*names)
    names.each do |name|
      original = "#{name}!"
      alias_method original, name
      define_method(name) do |*args|
        key = self.to_s.unpack("a*") << name.to_s.unpack("a*") << args
        @__memoize_cache__ ||= {}
        @__memoize_cache__[key] ||= send(original, *args)
      end
    end
  end

end

Module.send(:include, ::Memoize)
