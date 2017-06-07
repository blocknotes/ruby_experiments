class Chain
  attr_accessor :ref, :val

  def initialize( ref, val = {} )
    @ref = ref
    @val = val
  end

  def method_missing( m, *args, &block )
    @ref.send( m, self, *args )
  end

  def set( key, val )
    @val[key] = val
  end
end

class Test
  def self.fun1( *args )
    ( chain = ( args[0] && args[0].is_a?( Chain ) ) ? args.shift : Chain.new( self ) ).set( __method__, args ) # chain init

    puts '> fun1: ' + args.map( &:to_s ).join( ', ' )

    chain
  end

  def self.fun2( *args )
    ( chain = ( args[0] && args[0].is_a?( Chain ) ) ? args.shift : Chain.new( self ) ).set( __method__, args ) # chain init

    puts '> fun2: ' + args.map( &:to_s ).join( ', ' )

    chain
  end

  def self.all( *args )
    ret = ( args[0] && args[0].is_a?( Chain ) ) ? args.shift : false

    puts '> all: ' + ret.val.to_s + "\n"

    nil
  end
end

Test.fun1( 2, 4, 6 ).fun2( 3, 1 ).all()
puts ' '
Test.fun2( 3 ).fun1().all()
