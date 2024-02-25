helper = ApplicationController.helpers

Benchmark.ips do |x|
  x.config(:time => 5, :warmup => 2)

  x.report("Render - default") {
    helper.render(Namespaced::SomeOtherComponent.new('test', some_a: 1, some_b: :b)) { 'aaaaaaaaaaa' }
  }

  x.report("Render - with shortcut") {
    helper.vc.namespaced.some_other('test', some_a: 1, some_b: :b) { 'aaaaaaaaaaa' }
  }

  x.compare!
end