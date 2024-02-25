class Ui::Admin::NavbarPrimitive < ApplicationViewComponent
  def call
    content_tag(:div, "NavbarPrimitive: #{content}".html_safe)
  end
end