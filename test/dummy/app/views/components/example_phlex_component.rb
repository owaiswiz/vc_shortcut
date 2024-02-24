# frozen_string_literal: true

class ExamplePhlexComponent < ApplicationComponent
  def initialize(name: nil)
    @name = name
  end

  def template
    h4 { "ExamplePhlex" }
    p { @name } if @name
    p { yield }
  end
end
