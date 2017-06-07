class Test
  def fun
    puts 'Inside fun()'
  end
end

Test.new.fun
puts ''

Test.class_eval do
  prepend( TestExt = Module.new do
    def fun
      puts 'Inside prepend fun()'
      super
    end
  end )
end

Test.new.fun
