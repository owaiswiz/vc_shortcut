# frozen_string_literal: true

class NamespacedPhlex::SomeComponent < ApplicationComponent
  def template
    h4 { "NamespacedPhlex::Some" }
    div(style: "margin-left: 16px;") {
      render ExamplePhlexComponent.new(name: 'normal') {
        'yielded content'
      }
      vc.example_phlex(name: 'through helper') {
        'through helepr content'
      }
    }
  end
end
