VcShortcut.register :custom, find: ->(context) {
  chain_camelized = context.chain_camelized
  component = "Custom::#{chain_camelized}::Component".safe_constantize
  next component if component
  :has_more if chain_camelized.safe_constantize
}, process: ->(context) { context.view_context.render(context.component.new(*context.call_args, **context.call_kwargs), &context.call_block) }


VcShortcut.register :admin, find_component: ->(camelized_name) {
  "Ui::Admin::#{camelized_name}Primitive".safe_constantize
}, process: ->(context) {
  context.view_context.render(context.component.new(*context.call_args, **context.call_kwargs), &context.call_block)
}