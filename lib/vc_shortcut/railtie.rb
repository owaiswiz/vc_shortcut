module VcShortcut
  class Railtie < ::Rails::Railtie
    initializer :vc_shortcut do
      config.after_initialize do
        VcShortcut.define_render_shortcut
        VcShortcut.define_instantiate_shortcut
      end
    end

  end

  def self.define_render_shortcut
    return unless VcShortcut.render_shortcut

    VcShortcut.register(VcShortcut.render_shortcut,
      process: ->(context) { context.view_context.render(context.component.new(*context.call_args, **context.call_kwargs), &context.call_block) }
    )
  end


  def self.define_instantiate_shortcut
    return unless VcShortcut.instantiate_shortcut

    VcShortcut.register(VcShortcut.instantiate_shortcut,
      process: ->(context) { context.component.new(*context.call_args, **context.call_kwargs) }
    )
  end
end
