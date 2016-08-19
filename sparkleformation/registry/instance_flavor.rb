SfnRegistry.register(:instance_types) do
  [
    't2.nano',
    't2.small'
  ]
end

SfnRegistry.register(:instance_type_default) { 't2.nano' }
