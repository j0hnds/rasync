module Rasync
  
  module RreprExtensions

    def rrepr()
      method = (respond_to? :get_cache) ? 'get_cache' : 'find'
      "#{self.class.rrepr}.#{method}(#{id.rrepr})"
    end

  end

end

# Extend ActiveRecord models with the async methods
ActiveRecord::Base.send :include, Rasync::Extensions
ActiveRecord::Base.send :include, Rasync::RreprExtensions

HOOKS = [ :after_create, :after_update, :after_save ]

class << ActiveRecord::Base

  HOOKS.each do |hook|
    code = %Q{def async_#{hook}(*methods, &b) add_async_hook(#{hook.inspect}, *methods, &b) end}
    class_eval(code, __FILE__, __LINE__ - 1)
  end

  def add_async_hook(hook, *args, &block)
    if args && args.first.is_a?(Symbol)
      method = args.shift
      async_hooks[hook] << lambda { |o| o.send(method) }
    else
      async_hooks[hook] << block
    end
  end

  #
  # Responds with the @async_hooks hash if it already exists.
  # If it doesn't, it sets up a new hash that will have a default
  # value of an empty array for each value created in the hash.
  # So, here's what will happen when someone invokes the following
  # line of code:
  #
  #   * async_hooks[:hook] << &block
  #
  # 1) constructs a hook name
  # 2) calls the hook on this class with a block to call async_send
  # 3) constructs a method with the hook name on this class for 
  #    the worker to call.
  # 4) Define the default empty array for the hook.
  #
  def async_hooks
    @async_hooks ||= Hash.new do |hash, hook|
      ahook = :"_async_#{hook}"

      # This is for the producer's benefit
      send(hook){|o| async_send(ahook, o)}

      # This is for the worker's benefit
      code = "def #{ahook}(o) run_async_hooks(#{hook.inspect}, o) end"
      instance_eval(code, __FILE__, __LINE__ - 1)

      hash[hook] = []
    end
  end

  def run_async_hooks(hook, o)
    async_hooks[hook].each { |b| b.call(o) }
  end

  def async_each_opts(selector, opts, *args)
    min = opts.fetch(:min, minimum(:id))
    max = opts.fetch(:max, maximum(:id))

    (min..max).async_each_opts(self, :send_to_instance, opts, selector, *args)
  end

  def async_each(selector, *args)
    async_each_opts(selector, {}, *args)
  end

end
