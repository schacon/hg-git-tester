#! /usr/bin/env ruby
require 'helpers'

URL = 'git+ssh://localhost/opt/test.git'

test_git_hg_git('simple git merge') do
  append_data('README', 'testing', 'git')
  git("commit -am 'test'") 
  git("checkout -b test")
  append_data('README', 'testing', 'git')
  git("commit -am 'test'") 

  git("checkout master")
  append_data('README', 'testing2', 'git')
  git("commit -am 'test'") 
  git("merge test")
  git("add .") # resolve conflicts
  git("commit -am 'merge'") 
end

test_git_hg_git('simple git commit') do
  append_data('README', 'testing', 'git')
  git("commit -m 'test'")
end

test_hg_hg('rename early in second branch') do
  append_data('README', 'testing')
  hg("commit -m 'test'") # 0
  append_data('README', 'testing')
  hg("commit -m 'branch with readme'") # 1

  hg("checkout 0")
  append_data('README', 'testing')
  hg("commit -m 'branch2'") # 2
  hg("mv README readme.txt")
  hg("commit -m 'branch2 rename'") # 3
  append_data('readme.txt', 'testing')
  hg("commit -m 'more work'") # 4
  hg("update -C 1")
  hg("merge 4")
  hg("commit -m 'merge'") # 5
end


test_hg_hg('rename early in first branch') do
  append_data('README', 'testing')
  hg("commit -m 'test'") # 0
  hg("mv README readme.txt")
  hg("commit -m 'branch with readme'") # 1
  append_data('readme.txt', 'more work')
  hg("commit -m 'more work'") # 2

  hg("checkout 0")
  append_data('README', 'testing')
  hg("commit -m 'branch2'") # 3
  hg("update -C 2")
  hg("merge 3") 
  hg("resolve -m readme.txt") 
  hg("commit -m 'merge'") # 4
end


test_hg_hg('rename in second branch') do
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

test_hg_hg('named branch') do
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

test_hg_hg('rename in first branch') do
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

test_hg_hg('simple') do
  append_data('README', 'testing')
  hg("commit -m 'test'")
end

test_hg_hg('branches') do
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

test_hg_hg('rename') do
  append_data('README', 'testing')
  hg("commit -m 'test'")
  hg("mv README readme.txt")
  hg("commit -m 'rename'")
end

