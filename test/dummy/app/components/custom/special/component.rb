class Custom::Special::Component < ApplicationViewComponent
  def call
    content_tag(:div, "I am Custom::Special::Component - #{content}") +
    content_tag(:div, ("NOW RENDERING:" + content_tag(:div, vc.example(render_child: true), style: "padding: 4px 16px;")).html_safe)
  end
end