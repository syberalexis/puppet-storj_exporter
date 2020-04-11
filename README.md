# maeq-storj_exporter

[![Build Status Travis](https://img.shields.io/travis/com/syberalexis/puppet-storj_exporter/master?label=build%20travis)](https://travis-ci.com/syberalexis/puppet-storj_exporter)
[![Puppet Forge](https://img.shields.io/puppetforge/v/maeq/storj_exporter.svg)](https://forge.puppetlabs.com/maeq/storj_exporter)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/maeq/storj_exporter.svg)](https://forge.puppetlabs.com/maeq/storj_exporter)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/maeq/storj_exporter.svg)](https://forge.puppetlabs.com/maeq/storj_exporter)
[![Apache-2 License](https://img.shields.io/github/license/syberalexis/puppet-storj_exporter.svg)](LICENSE)

#### Table of Contents

- [Description](#description)
- [Usage](#usage)
- [Examples](#examples)
- [Development](#development)

## Description

This module automates the install of [Storj Exporter](https://github.com/anclrii/Storj-Exporter).  

## Usage

For more information see [REFERENCE.md](REFERENCE.md).

### Install Storj Exporter

#### Puppet
```puppet
include storj_exporter
```

### Examples

#### Personal python installation

```yaml
storj_exporter::manage_python: false
```

## Development

This project contains tests for [rspec-puppet](http://rspec-puppet.com/).

Quickstart to run all linter and unit tests:
```bash
bundle install --path .vendor/
bundle exec rake test
```
