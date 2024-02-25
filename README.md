# VcShortcut Gem

VcShortcut simplifies the API for rendering [ViewComponent](https://viewcomponent.org/)s and [Phlex](https://www.phlex.fun/) components in Ruby on Rails applications, reducing verbosity and streamlining component usage.

It also caches lookups to be extremely fast and have absolutely minimal overhead.

```erb
<%# Instead of: %>
<%= render Admin::Dashboard::TabsComponent.new(style: :compact) do |tabs| %>
  <% tabs.with_tab('Sales') { ... } %>
  <% tabs.with_divider %>
  <% tabs.with_tab('Settings') { ... } %>
<% end %>
<%= render ButtonComponent.new('Sign up', '/sign_up') %>
<%= render Wysiwyg::Toolbar::FontSelectComponent.new %>

<%# You can do: %>
<%= vc.button('Sign up', '/sign_up') %>
<%= vc.wysiwyg.toolbar.font_select %>
<%= vc.admin.dashboard.tabs(style: :compact) do |tabs| %>
  <% tabs.with_tab('Sales') { ... } %>
  <% tabs.with_divider %>
  <% tabs.with_tab('Settings') { ... } %>
<% end >
```

It's also highly customizable. You can change the shortcut prefix. It comes with 2 shortcuts setup by default.

And for more advanced use-cases, it also allows you change the lookup logic as well as setup custom shortcuts.

## Installation

Just add `vc_shortcut` to your Gemfile:

```shell
bundle add vc_shortcut
```

## Usage

If you're using ViewComponent or Phlex in your Rails app and your component class names end with `Component` or `::Component` (which should be the standard), there's nothing else you need to do.

By default, it sets up two shortcuts: `vc` for rendering and `vci` for instantiating components.

You can start using these helpers from any views or from your components.

#### Example:

```ruby
### Instead of:
render Wysiwyg::UploadFieldComponent.new(limit: 50.mb) do |upload_field|
  upload_field.with_footer do
      render IconComponent.new('file')
  end
end
### You can now also do:
vc.wysiwyg.upload_field(limit: 50.mb) do |upload_field|
  upload_field.with_footer do
    vc.icon('file')
  end
end

### Instead of:
instance = ProgressBarComponent.new(progress: 75)
### You can now also do:
instance = vci.progress_bar(progress: 75)
```

## Advanced

You can customize things by creating a initializer file in `config/initializers/vc_shortcut.rb`.

#### Customize name of default shortcuts

By default, we set up 2 shortcuts. One for rendering. One for instantiating. You can change what the default shortcuts are called:

```ruby
# In config/initializers/vc_shortcut.rb:
VcShortcut.render_shortcut      = :vc  # Or whatever you want
VcShortcut.instantiate_shortcut = :vci # Or whatever you want
```

You can disable a shortcut by setting its value to `false`.

#### Custom Component Lookup

By default,we assume your component class names end with `Component` or `::Component` which is the standard and should be true for a vast majority.

If you're however doing something non-standard, you can customize the logic that finds a component:

```ruby
# In config/initializers/vc_shortcut.rb:
VcShortcut.find_component = ->(camelized_name) {
  "#{camelized_name}Component".safe_constantize || "#{camelized_name}::Component".safe_constantize
}
```

As an example, if all your components are namespaced under `Polaris` and are suffixed with `Primitive` instead of `Component`, you can set:
```ruby
# In config/initializers/vc_shortcut.rb:
VcShortcut.find_component = ->(camelized_name) {
  "Polaris::#{camelized_name}Primitive".safe_constantize
}
## So instead of:
#   `render Polaris::Admin::NavbarPrimitive.new`
#  You can now also do:
#   `vc.admin.navbar`
```

### Super advanced

You can take it one level further if you need:

#### Registering additional custom shortcuts

You can also register additional different shortcuts:

```ruby
# In config/initializers/vc_shortcut.rb:
VcShortcut.register :admin,
  find_component: ->(camelized_name) {
    "Ui::Admin::#{camelized_name}::Component".safe_constantize
  },
  process: ->(context) {
    context.view_context.render(
      context.component.new(*context.call_args, **context.call_kwargs),
      &context.call_block
    )
  }
## So instead of:
#   `render Ui::Admin::Navbar::Component.new`
#  You can now also do:
#   `admin.navbar`
```

#### Taking full control

You can customize the find process even more by specifiying `find` instead of `find_component`:

```ruby
# In config/initializers/vc_shortcut.rb:
VcShortcut.register :admin,
  find: ->(context) {
    # If you return :has_more, we'll assume there's another component coming up in the chain
    # If you return a non-nil value, we'll assume this is the leaf component and move on to call `process`.
    # If you return nil, we'll assume nothing was found for the given chain and raise an error
    chain_camelized = context.chain_camelized
    component = "Ui::#{chain_camelized}::Component".safe_constantize
    next component if component
    :has_more if chain_camelized.safe_constantize
  },
  process: ->(context) {
    context.view_context.render(
      context.component.new(*context.call_args, **context.call_kwargs),
      &context.call_block
    )
  }
## So instead of:
#   `render Ui::Admin::Navbar::Component.new`
#  You can now also do:
#   `admin.navbar`
```

The return value of the `register` call is a module that you can include in other places you wish to make the helper available. It's however automatically included for all your views, view components, phlex components.

#### What is `context` in the above examples?

`context` is provided to the `find` and `process` proc. It's a simple object that responds to the following method:

##### 1. `context.chain`:
Chain until now. E.g if you call vc.admin.button:
* When processing :admin, chain will be [:admin]
* Then, when processing :button, chain will be [:admin, :button]

##### 2. `context.chain_camelized`:
Just does `context.join('/').camelize`. So if chain was [:admin, :buttton], it'd return `Admin::Button`

##### 3. `context.component`:
Only set when called on the `process` proc. It is the component returned by the `find` or `find_component` proc.

##### 4. `context.call_args` `context.call_kwargs`, `context.call_block`:
Only set when called on the `process` proc. These are the args used when calling the shortcut. E.g:
```ruby
vc.admin.navbar('Treact', size: :sm, style: :compact) do |navbar|
  navbar.with_menu_item(...)
end
```
Here, `context.call_args` will be `['Treact']`, `context.call_kwargs` will be `{ style: :compact, size: :sm }` and `context.call_block` will be the block above.

##### 5. `context.view_context`

The view context when the shortcut was called. You can use it to render the component. E.g:

```ruby
instance = context.component.new(*context.call_args, **context.call_kwargs)
html = context.view_context.render(instance, &context.call_block)
```


## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
