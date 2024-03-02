module SimpleTenant
  class Engine < ::Rails::Engine
    engine_name :SIMPLE_TENANT
    isolate_namespace SimpleTenant
  end
end
