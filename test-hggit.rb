#! /usr/bin/env ruby
require 'helpers'
require 'pp'

URL = 'git+ssh://localhost/opt/test.git'

#exit

test_this('named branch') do
  append_data('README', 'testing')
  hg("commit -m 'test'") # 0
  hg("mv README readme.txt")
  hg("commit -m 'branch with readme'") # 1

  hg("checkout 0")
  hg("branch newfeature")
  append_data('README', 'testing')
  hg("commit -m 'branch2'") # 2
  hg("update -C 1")
  hg("merge 2") 
  hg("commit -m 'merge'") # 3
end

test_this('rename in first branch') do
  append_data('README', 'testing')
  hg("commit -m 'test'") # 0
  hg("mv README readme.txt")
  hg("commit -m 'branch with readme'") # 1

  hg("checkout 0")
  append_data('README', 'testing')
  hg("commit -m 'branch2'") # 2
  hg("update -C 1")
  hg("merge 2") 
  hg("commit -m 'merge'") # 3
end

test_this('simple') do
  append_data('README', 'testing')
  hg("commit -m 'test'")
end

test_this('branches') do
  append_data('README', 'testing')
  hg("commit -m 'test'")
  append_data('README', 'testing')
  hg("commit -m 'branch1'")

  hg("checkout 0")
  append_data('README', 'testing')
  hg("commit -m 'branch2'")
  hg("update -C 1")
  hg("merge 2")
  hg("commit -m 'merge'")
end

test_this('rename') do
  append_data('README', 'testing')
  hg("commit -m 'test'")
  hg("mv README readme.txt")
  hg("commit -m 'rename'")
end

test_this('rename in second branch') do
  append_data('README', 'testing')
  hg("commit -m 'test'") # 0
  append_data('README', 'testing')
  hg("commit -m 'branch with readme'") # 1

  hg("checkout 0")
  append_data('README', 'testing')
  hg("commit -m 'branch2'") # 2
  hg("mv README readme.txt")
  hg("commit -m 'branch2 rename'") # 3
  hg("update -C 1")
  hg("merge 3")
  hg("commit -m 'merge'") # 4
end

