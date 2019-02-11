[![Build Status](https://vivien.visualstudio.com/vivienfabing%20blog/_apis/build/status/vfabing.vfabing.github.io?branchName=master)](https://vivien.visualstudio.com/vivienfabing%20blog/_build/latest?definitionId=40?branchName=master)

# Starter Kit (Windows)
## Prerequisites
- Download the `RubyInstaller` for Windows, choose a `Ruby+Devkit` version and install it (_default options are fine_)  
https://rubyinstaller.org/
- Open a new command prompt and check that the `gem` package manager was correctly installed by running `gem --version` (a version number such as `2.7.6` should be displayed)
- Install `jekyll` (the engine which will transform your markdown into html/css) and `bundler` (a dependencies manager) by running: 
  - `gem install jekyll bundler`

## How to
- Clone this repository in a local directory  
`git clone https://github.com/vfabing/vfabing.github.io.git`
- Open a command prompt in the created directory and run:
  - `bundle install` to restore dependencies
  - `bundle exec jekyll serve` to run your website locally
- Access to the website on http://127.0.0.1:4000/ by default

## Troubleshooting
- Run `bundle exec jekyll serve --trace` to get more detailed information on the error