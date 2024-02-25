# VcShortcut
<a href="https://badge.fury.io/rb/vc_shortcut"><img src="https://badge.fury.io/rb/vc_shortcut.svg" alt="Gem Version" height="18"></a> <img alt="Gem Total Downloads" src="https://img.shields.io/gem/dt/vc_shortcut">

VcShortcut simplifies the API for rendering [ViewComponent](https://viewcomponent.org/)s and [Phlex](https://www.phlex.fun/) components in Ruby on Rails applications, reducing verbosity.

It also features caching for lookups, ensuring that it operates with minimal overhead and maximal speed.

```erb
<%# Instead of: %>
<%= render Admin::Dashboard::TabsComponent.new(style: :compact) do |tabs| %>
  ...
<% end %>

<%# You can now also do: %>
<%= vc.admin.dashboard.tabs(style: :compact) do |tabs| %>
  ...
<% end %>
```

It works out of the box with just a `bundle add vc_shortcut`, and is also highly customizable.

By default, two shortcuts are set up: `vc` for rendering and `vci` for instantiating components. You can change the shortcut prefix.

For more advanced use-cases, it also allows you to change the lookup logic as well as setup custom shortcuts.

## Installation

Add `vc_shortcut` to your Gemfile:

```shell
bundle add vc_shortcut
```

## Usage

If you're using ViewComponent or Phlex in your Rails app and your component class names end with `Component` or `::Component` (which should be the standard), there's nothing else you need to do.

By default, two shortcuts are set up: `vc` for rendering and `vci` for instantiating components.

You can start using these helpers from any views or from your components.

#### Example:

```ruby
### Instead of:
render Wysiwyg::UploadFieldComponent.new(limit: 50.megabytes) do |upload_field|
  upload_field.with_footer do
      render IconComponent.new('file')
  end
end
### You can now also do:
vc.wysiwyg.upload_field(limit: 50.megabytes) do |upload_field|
  upload_field.with_footer do
    vc.icon('file')
  end
end

### Instead of:
instance = ProgressBarComponent.new(progress: 75)
### You can now also do:
instance = vci.progress_bar(progress: 75)
```

<br/>
<br/>

## Interested in a powerful Rails UI library?

I am working on a super-powerful Rails UI library - components as well as templates & patterns.

[Please check this out if you're interested](https://owaiskhan.me/rails-ui-library).
<br/>
<br/>
<br/>

## Advanced

You can customize things by creating an initializer file at `config/initializers/vc_shortcut.rb`.

#### Customize name of default shortcuts

You can rename the default shortcuts or disable them entirely:

```ruby
# In config/initializers/vc_shortcut.rb:
VcShortcut.render_shortcut      = :vc  # Or whatever you prefer
VcShortcut.instantiate_shortcut = :vci # Or whatever you prefer
```

You can disable a shortcut by setting its value to `false`.

#### Custom Component Lookup

By default, we assume your component class names end with `Component` or `::Component`, which is the standard and should cover the majority of cases.

However, if you're doing something non-standard, you can customize the logic that finds a component:

```ruby
# In config/initializers/vc_shortcut.rb:
VcShortcut.find_component = ->(camelized_name) {
  "#{camelized_name}Component".safe_constantize || "#{camelized_name}::Component".safe_constantize
}
```

For example, if all your components are namespaced under `Polaris` and are suffixed with `Primitive` instead of `Component`, you can set:
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

## Super Advanced

You can take customization one level further if needed:

#### Registering Additional Custom Shortcuts

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

#### Taking Full Control

You can customize the find process even more by specifying `find` instead of `find_component`:

```ruby
# In config/initializers/vc_shortcut.rb:
VcShortcut.register :admin,
  find: ->(context) {
    # If you return :has_more, we'll assume there's another component coming up in the chain.
    # If you return a non-nil value, we'll assume this is the leaf component and move on to call `process`.
    # If you return nil, we'll assume nothing was found for the given chain and raise an error.
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

The return value of the `register` call is a module that you can include in places where you wish to make the helper available. It's, however, automatically included for all your views, view components, and phlex components.

#### What is `context` in the above examples?

`context` is provided to the `find` and `process` proc. It's an object that responds to the following methods:

##### 1. `context.chain`:
Chain until now. E.g., if you call `vc.admin.button`:
* When processing :admin, chain will be [:admin].
* Then, when processing :button, chain will be [:admin, :button].

##### 2. `context.chain_camelized`:
Just does `context.chain.join('/').camelize`. So, if chain was [:admin, :buttton], it'd return `Admin::Button`.

##### 3. `context.component`:
Only set when called in the `process` proc. It is the component returned by the `find` or `find_component` proc.

##### 4. `context.call_args` `context.call_kwargs`, `context.call_block`:
Only set when called in the `process` proc. These are the arguments used when calling the shortcut. E.g.:
```ruby
vc.admin.navbar('Treact', size: :sm, style: :compact) do |navbar|
  navbar.with_menu_item(...)
end
```
Here, `context.call_args` will be `['Treact']`, `context.call_kwargs` will be `{ size: :sm, style: :compact }` and `context.call_block` will be the block above.

##### 5. `context.view_context`:

The view context when the shortcut was called. You can use it to render the component. E.g.:

```ruby
instance = context.component.new(*context.call_args, **context.call_kwargs)
html = context.view_context.render(instance, &context.call_block)
```


## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
