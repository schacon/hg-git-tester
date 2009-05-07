#! /usr/bin/env ruby
require 'helpers'
require 'pp'

URL = 'git+ssh://localhost/opt/test.git'

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

