#!/usr/bin/env ruby
# Compatibility entry point: metadata and image recovery now live in gc-sync.py.
exec "python3", File.expand_path("gc-sync.py", __dir__), *ARGV
