class Namespaced::SomeOtherComponent < ApplicationViewComponent
  renders_one :a_slot

  def initialize(*args, **kwargs)
    @args = args
    @kwargs = kwargs
  end

  def call
    content_tag(:div) do
      content_tag(:p, "I am a named spaced component called #{self.class.name}") +
      content_tag(:p, "args: #{@args}") +
      content_tag(:p, "kwargs: #{@kwargs}") +
      content_tag(:p, "a_slot: #{a_slot}") +
      content_tag(:p, "content: #{content}")
    end
  end
end