require "vc_shortcut/version"
require "vc_shortcut/chain_context"
require "vc_shortcut/chain_manager"
require "vc_shortcut/register"
require "vc_shortcut/railtie"

module VcShortcut
  # If you've got a custom/non-standard lookup logic for you components, you can define that here.
  mattr_accessor :find_component, default: ->(camelized_name) {
    "#{camelized_name}Component".safe_constantize || "#{camelized_name}::Component".safe_constantize  || (defined?(Phlex::HTML) && "#{camelized_name}View".safe_constantize)
  }

  # Configures the name of the shortcut for rendering a component. You can set it to false if you don't want to define one by default
  mattr_accessor :render_shortcut, default: :vc

  # Configures the name of the shortcut for instantiating a component. You can set it to false if you don't want to define one by default
  mattr_accessor :instantiate_shortcut, default: :vci
end
