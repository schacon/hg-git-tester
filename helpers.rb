def append_data(file, data)
  add_file = !File.exist?(file)

  f = File.open(file, 'a+')
  f.puts(data)
  f.close

  hg("add #{file}") if add_file
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
  out = `hg #{command}`
  puts out if $debug
  out
end

def test_this(name, debug = false)
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

  if cs_before == cs_after
    puts "YAY BEER - #{name}"
  else
    puts "BOO LOIS - #{name}"
  end
end
