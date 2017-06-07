# set_trace_func

Sometimes it can be useful to track every system call for debugging, _set_trace_func_ function do exactly this.

But the output can be very large (specially using Rails) so the paramaters can be used to filter.

Usually I use the filename:

```ruby
set_trace_func proc { |event, file, line, id, binding, classname|
  if file =~ /myfile/
    printf "| %8s %s:%-2d %10s %8s\n", event, file.gsub( /.*gems\//, '' ), line, id, classname
  end
}
```

To use _set_trace_func_ with Rails I would put the call in **config/application.rb** file.
