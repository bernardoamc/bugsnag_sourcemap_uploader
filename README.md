[![Gem Version](https://badge.fury.io/rb/bugsnag_sourcemap_uploader.svg)](https://badge.fury.io/rb/bugsnag_sourcemap_uploader) [![](https://github.com/bernardoamc/bugsnag_sourcemap_uploader/workflows/continuous-integration/badge.svg)](https://github.com/bernardoamc/bugsnag_sourcemap_uploader/actions?query=workflow%3Acontinuous-integration)

# BugsnagSourcemapUploader

Upload your sourcemaps to Bugsnag in parallel.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bugsnag_sourcemap_uploader'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install bugsnag_sourcemap_uploader

## Usage

```ruby
BugsnagSourcemapUploader.upload(assets_metadata, bugsnag_api_key)
```

### Asset Metadata

Any object that responds to the following methods:

* #script_path
* #source_map_path
* #cdn_url

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bernardoamc/bugsnag_sourcemap_uploader.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BugsnagSourcemapUploader project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bernardoamc/bugsnag_sourcemap_uploader/blob/master/CODE_OF_CONDUCT.md).
