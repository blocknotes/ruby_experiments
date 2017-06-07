set_trace_func proc { |event, file, line, id, binding, classname|
  printf "| %10s  %s:%-2d %20s %20s\n", event, file, line, id, classname
}

puts 'Hello world'

### Output
# |   c-return  trace.rb:1        set_trace_func               Kernel
# |       line  trace.rb:5
# |     c-call  trace.rb:5                  puts               Kernel
# |     c-call  trace.rb:5                  puts                   IO
# |     c-call  trace.rb:5                 write                   IO
# Hello world|   c-return  trace.rb:5                 write                   IO
# |     c-call  trace.rb:5                 write                   IO

# |   c-return  trace.rb:5                 write                   IO
# |   c-return  trace.rb:5                  puts                   IO
# |   c-return  trace.rb:5                  puts               Kernel
