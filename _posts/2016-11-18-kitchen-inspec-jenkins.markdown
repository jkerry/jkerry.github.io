---
layout: post
title:  "Test Kitchen, Inspec, and Jenkins Reporting"
date:   2016-11-18 00:00:00 -0500
categories: chef
---
We've standardized our kitchen verifier on
[Inspec](https://github.com/chef/inspec) at my corner of NCR and we're in need
of a solution for reporting test-kitchen runs from pull request verifiers in
jenkins. The default test reporting format for most jenkins jobs is the
[JUnit xml format](https://github.com/windyroad/JUnit-Schema). We're lucky
because unlike chefspec Inspec operates on the host rather than the kitchen vm.
This means that we can use Inspec's `--format JUnit` option in the kitchen
config file like so:

```ruby
verifier:
  name: inspec
  format: junit
  output: ./inspec_output.xml
```

right? Well.. the only supported formats at the time of writing are
`cli, progress, documentation, json, json-min`. I've opened an inspec issue
[here](https://github.com/chef/inspec/issues/1301) and will see if I can take a
crack at it assuming I'm not beaten to the punch.
