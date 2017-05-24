# Puppler

puppler is a tool aimed at creating git-bundles of puppet module repositories and ship
them as a Debian package.

## How it works

puppler is currently based on the following assumptions:

* every puppet module is stored in a git repository and referenced in a Puppetfile
* a set of bundles (the Puppetfile and all versions of the bundles) is managed in a git repository alongside
  packaging files
* some directories in this repository are managed by puppler exclusively

When puppler is called with the install action, it will run r10k to process the Puppetfile. 
By default it will install it to the `modules`-directory. Note that r10k will remove everything in
that folder unless managed by r10k itself.

After that, when puppler is called with the `bundle` action, puppler will do the following with each module
in the modules directory:

1. Move the module from the modules directory to a puppler working directory
2. Do a shallow clone of all tags and branches in that repo
3. Create a bare repository as target repository
4. Push all shallow clones to the before mentioned bare repository
5. Create a bundle with `git bundle`

If a bundle already exists, it will update it will overwrite it with the *current* contents of the module.
puppler ensures that the shallow clones have stable commits, so that it's possible to know what changed between
two subsequent runs.

## Usage

By default the tool expects a Puppetfile to exist in the current directory and
uses `modules` as output directory.

Note that puppler expects to fully manage the following directories:

* modules
* bundles

When puppler is invoked with no arguments, the ``bundle`` task is called.
 
```bash
puppler
``` 

See ``puppler --help`` for the available actions.

## Development

To install this gem onto your local machine, run `bundle exec rake install`.  In order to run
puppler from the command line , the following should do:

```bash
bundle install --binstubs
bin/bundle --help
```


### Developer docs

The classes have some basic documentation in yard format. Those docs can be build and opened
with the followig commands:

```bash 
yard
```

After that you can open the resulting docs/index.html in your browser.

### Running tests

puppler includes a small test suite which runs puppler and checks it results. This
can be invoked by running:

```bash
rake spec
```

### Release steps

To update the version of the gem, one can use the ``gem bump`` command, e.g.

```bash
# bump the minor part of the version
gem bump -v minor --no-commit

# bump the patch part of the the version
gem bump -v patch --no-commit
```

The rakefile provides a dch target to launch dch with appropriate commands:

```bash
rake dch
```

## Release process

Gem version can be dumped with

gem bump

See gem bump --help for available options.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

