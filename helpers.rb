require 'pp'

def append_data(file, data, type = 'hg')
  add_file = !File.exist?(file)

  f = File.open(file, 'a+')
  f.puts(data)
  f.close

  if add_file
    hg("add #{file}") if type == 'hg'
    git("add #{file}") if type == 'git'
  end
end

def in_temp_dir
  Dir.chdir('/tmp') do 
    `rm -Rf hg-git-test`
    Dir.mkdir('hg-git-test')
    Dir.chdir('hg-git-test') do
      yield
    end
  end
end

def extract_changesets
  extract = []
  log = hg('log').split("\n\n")
  log.each do |cs|
    this_cs = {}
    cs.split("\n").each do |line|
      field, value = line.split(": ")
      if field == 'changeset'
        value = value.strip.split(':')
      else
        value = value.strip
      end

      this_cs[field] ||= []
      this_cs[field] << value
    end
    extract << this_cs
  end
  extract
end

def cs_sha_array(cs_array)
  cs_array.map { |a| a['changeset'].map { |b| b[1] } }.flatten.sort
end

$debug = false

def hg(command)
  if $debug
    puts command
    out = `hg #{command}`
    puts out 
    puts
  else
    out = `hg #{command} 2>/dev/null`
  end
  out
end

def git(command)
  out = `git #{command} 2>/dev/null`
  puts out if $debug
  out
end

def kill_repo
  Dir.chdir("/opt") do
    pwd = `pwd`.strip
    if pwd == '/opt'
      `rm -Rf test.git`
      `mkdir test.git`
      Dir.chdir('test.git') do
        git('init --bare')
      end
    end
  end
end

def test_hg_hg(name, debug = false)
  $debug = debug
  cs_before = []
  cs_after = []

  # setup hg test repository
  in_temp_dir do
    hg('init')

    yield

    cs_before = extract_changesets
    hg("gremote add origin #{URL}")
    hg("gpush")
  end

  # clone it back from git and verify that the output matches
  in_temp_dir do
    hg("gclone #{URL}")
    Dir.chdir('test-hg') do
      cs_after = extract_changesets
    end
  end

  cs_sb = cs_sha_array(cs_before)
  cs_sa = cs_sha_array(cs_after)

  compare_sha_lists(cs_sb, cs_sa, name)
end

def test_hg_hg_tags(name, debug = false)
  $debug = debug
  tags_before = []
  tags_after = []

  # setup hg test repository
  in_temp_dir do
    hg('init')

    yield

    tags_before = hg("tags")
    hg("gremote add origin #{URL}")
    hg("gpush")
  end

  # clone it back from git and verify that the output matches
  in_temp_dir do
    hg("gclone #{URL}")
    Dir.chdir('test-hg') do
      tags_after = hg("tags")
    end
  end

  if $debug
    pp tags_before
    pp tags_after
  end

  if tags_before == tags_after
    puts "YAY BEER - #{name}"
  else
    puts "BOO LOIS - #{name}"
  end
  kill_repo
end

def test_git_hg_tags(name, debug = false)
  $debug = debug
  tags_before = []
  tags_after = []

  # setup git test repository
  in_temp_dir do
    git('init')
    yield
    git('log --pretty=fuller --name-only -p')

    tags_before = git('tag')
    
    git("remote add origin #{URL}")
    git("push origin --tags")
  end

  # clone it back from git and verify that the output matches
  in_temp_dir do
    hg("gclone #{URL}")
    Dir.chdir('test-hg') do
      tags_after = hg("tags")
    end
  end

  tags_before = tags_before.split("\n")
  tags_after = tags_after.split("\n").map { |a| a.split(" ").first }
  
  if $debug
    pp tags_before
    pp tags_after 
  end

  if (tags_before - tags_before).size == 0
    puts "YAY BEER - #{name}"
  else
    puts "BOO LOIS - #{name}"
  end
  kill_repo
end

def compare_sha_lists(cs_sb, cs_sa, name)
  if $debug
    pp cs_sb
    pp cs_sa
  end

  if cs_sb == cs_sa
    puts "YAY BEER - #{name}"
  else
    puts "BOO LOIS - #{name}"
  end
end

def extract_commits
  git('rev-list master').split("\n").sort
end

def test_git_hg_git(name, debug = false)
  $debug = debug
  cs_before = []
  cs_after = []

  # setup git test repository
  in_temp_dir do
    git('init')
    yield
    git('log --pretty=fuller --name-only -p')
    cs_before = extract_commits
    git("remote add origin #{URL}")
    git("push -f")
  end

  # clone in hg
  in_temp_dir do
    hg("gclone #{URL}")
    Dir.chdir('test-hg') do
      hg("gclear")
      hg("gpush")
    end
  end

  # clone in git
  in_temp_dir do
    git("clone #{URL}")
    Dir.chdir('test') do
      git('log --pretty=fuller --name-only -p')
      cs_after = extract_commits
    end
  end

  # check that git shas are the same
  compare_sha_lists(cs_before, cs_after, name)
end

