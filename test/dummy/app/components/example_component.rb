class ExampleComponent < ApplicationViewComponent
  def initialize(render_child: false)
    @render_child = render_child
  end

  def render_child
    @render_child
  end

  def call
    result = content_tag(:div, 'I am an example')
    result += content_tag(:div, ("NOW RENDERING:" + content_tag(:div, render_children, style: "padding: 4px 16px;")).html_safe) if render_child
    result
  end

  def render_children
    vc.namespaced.some_other('test', a: 3) do |a|
      a.with_a_slot { 'Zweit' }
      'norm'
    end
  end
end