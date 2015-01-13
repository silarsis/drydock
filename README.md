# drydocker

[![wercker status](https://app.wercker.com/status/b00d4339862ef12b880f0022b6d20b2a/s "wercker status")](https://app.wercker.com/project/bykey/b00d4339862ef12b880f0022b6d20b2a)

A project to provide a simple continuous testing tool.

## Installation

Drydocker can be installed as a gem - `gem install drydocker` (or, on OS X,
`sudo gem install drydocker`)

## Usage

When installed as a gem, you will have a `drydocker` executable. Running with
`-h` will provide up-to-date usage instructions.

Basic usage is to run `drydocker` in the top level directory of the project
you're working on - by default, it will mount that directory into an image
that has enough for running rspec installed, and will run `rspec spec` every
time it sees a change in the directory.

You can specify particular images to run in and commands to run at command line
if you need to run your tests in a different way or container. Please refer to
the output of `drydocker -h` for more information on the flags to use.

## Contributing to drydocker

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Create a Pull Request.

## Links

* Source code: https://github.com/silarsis/drydocker
* Build/Test: https://app.wercker.com/#applications/54b446f6da3a4af764100e91
* Docker container: https://registry.hub.docker.com/u/silarsis/drydocker/
* RubyGem: https://rubygems.org/gems/drydocker

## Copyright

Copyright (c) 2015 Kevin Littlejohn. See LICENSE.txt for
further details.
