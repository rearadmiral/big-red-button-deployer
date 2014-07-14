Go Deploy with Big Red Button
=============================

I only have this working on OSX for now.  Attempts at running it on Vagrant for use on Windows encountered a Ruby C Library bug :-(

The [Dream Cheeky](http://www.dreamcheeky.com/) Big Red button is a USB device.

This lets you use it to trigger a [Go.CD](http://go.cd) pipeline.

   > bundle

   > cp config.yml{.example,}

Edit your config.yml to match your usage.

   > ruby main.rb
