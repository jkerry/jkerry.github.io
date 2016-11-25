---
layout: post
title:  "Test Kitchen, Inspec, and Jenkins Reporting"
date:   2016-11-18 00:00:00 -0500
categories: chef
---
> The [pull request](https://github.com/chef/inspec/pull/1304) that adds the
> junit functionality is currently under review.  When it's live I'll remove
> this preamble and note the required inspec version

We've standardized our kitchen verifier on
[Inspec](https://github.com/chef/inspec) at my corner of NCR and we're in need
of a solution for reporting test-kitchen runs from pull request verifiers in
jenkins. The default test reporting format for most jenkins jobs is the
[JUnit xml format](https://github.com/windyroad/JUnit-Schema). We're lucky
because unlike chefspec Inspec operates on the host rather than the kitchen vm.
This means that we can use Inspec's `--format JUnit` option and consume it with
jenkins reporting.

# Cookbook Testing with Inspec

If you'd like to switch your cookbook's default verifier to inspec change your
.kitchen.yml verifier to match something like the following:

```ruby
verifier:
  name: inspec
  format: junit
  output: ./inspec_output.xml
```

The `format:` option corresponds with the --format cli option. you'll likely
need the kitchen-inspec gem. Note the output file location for Jenkins. It might
be worth noting that the test location in your cookbook will change with the
verifier name.

![Kitchen inspec tests location]({{ site.url }}/assets/images/kitchen-inspec-placement.png)

See [my resumé](https://github.com/jkerry/CookbookResume) for an example.

# Jenkins Configuration

Now that you've got a a target you can use inspec's cli `--format junit` argument
or kitchen-inspec's junit xml output all you need to do is consume the junit xml
as a post-build event in Jenkins.  This comes with the stock installation and is
is the defacto way to aggregate test results in jenkins:

![JUnit Post Build Reporting]({{ site.url }}/assets/images/junit-post-build.png)

and Bam! you've got web ui test results and aggregation.

![Test Results]({{ site.url }}/assets/images/test-results.png)

![Test aggregation]({{ site.url }}/assets/images/test-aggregation.png)

Now the only thing left to do is for me to fix the errors in my cover letter so
we don't have any embarrassing failures to report..
