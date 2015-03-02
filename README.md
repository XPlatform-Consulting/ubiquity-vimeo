# Ubiquity::Vimeo

## Installation

### Pre-requisites

  [git](http://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  [ruby](https://www.ruby-lang.org/en/documentation/installation/)
  rubygems
  [bundler](http://bundler.io/#getting-started)

#### Install Pre-requisites on CentOS

Execute the following:

    $ yum install -y git ruby ruby-devel rubygems
    $ gem install bundler

### Install Using Git

Execute the following:

    $ git clone https://github.com/XPlatform-Consulting/ubiquity-vimeo.git
    $ cd ubiquity-vimeo
    $ bundle update

Or install it yourself using the specific_install gem:

    $ gem install specific_install
    $ gem specific_install https://github.com/XPlatform-Consulting/ubiquity-vimeo.git

## Vimeo API Executable [bin/ubiquity-vimeo](../bin/ubiquity-vimeo)

### Usage

    Usage:
        ubiquity-vimeo -h | --help

    Options:
          --access-token TOKEN         The access token account to authenticate with.
          --method-name METHODNAME     The name of the method to call.
          --method-arguments JSON      The arguments to pass when calling the method.
          --pretty-print               Will format the output to be more human readable.
          --log-to FILENAME            Log file location.
                                          default: STDERR
          --log-level LEVEL            Logging level. Available Options: debug, info, warn, error, fatal
                                          default: debug
          --[no-]options-file [FILENAME]
                                       Path to a file which contains default command line arguments.
                                          default: ~/.options/ubiquity-vimeo
      -h, --help                       Display this message.

### Available API Methods

#### [user_video_create](https://developer.vimeo.com/api/endpoints/users#/{user_id}/videos)

    ubiquity-vimeo --access-token 0123456789 --method-name user_video_create --method-arguments '{"user_id":"0123456789","type":"pull","link":"https://s3.amazonaws.com/s3.damconsortium.com/videos/Ubiquity-4Ch-Mono_ProRes422-576-25p.mov"}' --pretty-print

#### [video_delete](https://developer.vimeo.com/api/endpoints/videos#/{video_id})

    ubiquity-vimeo --access-token 0123456789 --method-name video_delete --method-arguments '{"video_id":"0123456789"}' --pretty-print

#### [video_edit](https://developer.vimeo.com/api/endpoints/videos#/{video_id})

    ubiquity-vimeo --access-token 0123456789 --method-name video_edit --method-arguments '{"video_id":"0123456789","name":"Name","description":"Description"}' --pretty-print

#### [video_get](https://developer.vimeo.com/api/endpoints/videos#/{video_id})

    ubiquity-vimeo --access-token 0123456789 --method-name video_get --method-arguments '{"video_id":"0123456789"}' --pretty-print


## Vimeo Documentation

[Getting Started](https://developer.vimeo.com/api/start)

[API Endpoints](https://developer.vimeo.com/api/endpoints)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ubiquity-vimeo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
