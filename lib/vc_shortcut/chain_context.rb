module VcShortcut
  class ChainContext
    # The view_context (e.g an ActionView::Base or a ViewComponent instance)
    attr_reader :view_context

    # Chain until now. E.g if you call vc.admin.button
    # When processing :admin, chain will be [:admin]
    # Then, when processing :button, chain will be [:admin, :button]
    attr_reader :chain

    # The leaf component found by the `find` proc when registering a shortcut
    attr_accessor :component

    # Arguments for the leaf component
    attr_accessor :call_args, :call_kwargs, :call_block

    def initialize(view_context)
      @view_context = view_context
      @chain = []
      @component = nil
      @call_args = []
      @call_kwargs = {}
      @call_block = nil
    end

    def chain_camelized(rindex = -1)
      @chain[0..rindex].join('/').camelize
    end
  end
end