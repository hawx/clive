require_relative '../lib/clive'

TODO_FILE = File.expand_path('~/Desktop/todos.txt')

class Todo < Clive

  class << self
    def write(mode, text)
      File.open(TODO_FILE, mode) {|f| f.write(text) }
    end

    def read
      r = IO.read(TODO_FILE) rescue 'No tasks'
      r = 'No tasks' if r.empty?
      r
    end
  end

  config :name => 'todo', :help_command => false

  desc 'List all todo items'
  opt :l, :list do
    puts Todo.read
  end

  desc 'Delete the item with index given'
  opt :d, :delete, :arg => '<index>...', :as => Integer do
    lines = Todo.read.split("\n")

    if index.any? {|i| i >= lines.size }
      abort "You can't delete task #{index} as there are only #{lines.size} tasks in your list".red
    end
    
    lines -= index.map {|i| lines[i] }  

    Todo.write 'w', lines.join("\n")
  end

  desc 'Add item to list'
  opt :a, :add, :arg => '<task>' do
    Todo.write 'a+', "- #{task}\n"
  end

end

Todo.run
