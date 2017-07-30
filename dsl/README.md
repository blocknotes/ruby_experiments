# DSL

Some pieces of code useful when making DSL / metaprogramming.

- Set values in *new* block:

```rb
class MyClass
  attr_accessor :name, :val
  def initialize
    yield self if block_given?
  end
end

MyClass.new do |obj|
  obj.name = 'Test'
  obj.val = 123
end
```

- Set values in *new* block using *self*:

```rb
class MyClass
  attr_accessor :name, :val
  def initialize( &block )
    instance_eval( &block ) if block_given?
  end
end

MyClass.new do
  self.name = 'Test'
  self.val = 123
end
```

- Define properties methods at runtime:

```rb
class MyClass
  # attr_accessor :params

  def initialize
    @params = {}
  end

  def method_missing( name, *args )
    match = name.to_s.match( /(prop_([A-Za-z0-9]+))([=]{0,1})/ )
    if match
      self.class.class_eval do
        define_method( match[1].to_sym ) do
          @params[match[2]]
        end
        define_method( :"#{match[1]}=" ) do |val|
          @params[match[2]] = val
        end
      end
      send( :"#{match[1]}=", args[0] )
    else
      super
    end
  end

  def respond_to?( name, *args )
    name.to_s.match( /(prop_([A-Za-z0-9]+))([=]{0,1})/ ) ? true : super
  end
end

cl = MyClass.new
cl.prop_a
cl.prop_b = 123
```
