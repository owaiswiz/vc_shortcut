module VcShortcut
  class ChainManager
    TREE = {}

    def initialize(shortcut, process, find, view_context)
      @tree = TREE[shortcut] ||= {}
      @process = process
      @find = find
      @context = ChainContext.new(view_context)
    end

    def method_missing(method, *args, **kwargs, &block)
      @context.chain << method

      # If we haven't seen this path before, let's attempt constantization
      if @tree[method].nil?
        result = @find.call(@context)

        if result == :has_more
          # We matched with a module
          @tree[method] = {}
        elsif result
          # We matched with a leaf
          @tree[method] = component_klass
        else
          raise NameError, "Cannot find a component or module matching. Chain: #{@context.chain.join('.')}"
        end
      end

      leaf_or_subtree = @tree[method]
      # We are at a module. Continue chaining
      if leaf_or_subtree.is_a?(Hash)
        @tree = leaf_or_subtree
        return self
      end

      # Otherwise, we are at the leaf node (i.e a component)
      @context.component = leaf_or_subtree
      @context.call_args = arsg
      @context.call_kwargs = kwargs
      @context.block = block
      @process.call(@context)
    end
  end
end