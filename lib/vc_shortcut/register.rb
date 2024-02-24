module VcShortcut
  # @param [Symbol] shortcut          What the shortcut helper is going to be called by
  #
  # @param [Proc]   process           Proc to process what to do with the leaf component. E.g instantiating a new class or rendering a component.
  #                                   It's invoked with a single arguments: An instance of VcHelper::Context. See it's doc for what's available.
  #
  # @param [Proc]   find              Proc to find the component class given the current chain
  #                                   Optional. If you don't pass it, we'll try to camelize the chain, and try finding a component or module.
  #                                   You might want to define this if you have got some custom lookup logic.
  #                                   It's invoked with a single argument: An instance of VcHelper::Context. See it's doc for what's available
  #                                   If you return :has_more, we'll assume there's another component coming up in the chain
  #                                   If you return a non-nil value, we'll assume this is the leaf component.
  #                                   If you return nil, we'll assume we couldn't find any component for the given chain and raise an error
  #
  def self.register(shortcut, process:, find: nil)
    find ||= ->(context)  {
      chain_camelized = context.chain_camelized
      component = VcShortcut.find_component.call(chain_camelized)
      next component if component
      :has_more if chain_camelized.safe_constantize
    }

    helper_module = Module.new do
      define_method(shortcut) do |view_context = nil|
        ChainManager.new(shortcut, process, find, view_context || self)
      end
    end

    ActiveSupport.on_load(:action_view) do
      include helper_module
    end

    ViewComponent::Base.class_eval do
      define_method(shortcut) do
        helpers.send(shortcut, self)
      end
    end if defined?(ViewComponent::Base)

    Phlex::HTML.class_eval do
      define_method(shortcut) do
        helpers.send(shortcut, self)
      end
    end if defined?(Phlex::HTML)

    helper_module
  end
end