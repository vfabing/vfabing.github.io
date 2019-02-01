workflow "New workflow" {
  on = "push"
  resolves = ["ruby"]
}

action "ruby" {
  uses = "docker://ruby:2.3.4"
  runs = "gem install jekyll bundler ; bundle install --retry=3 --jobs=4 ; bundle exec jekyll algolia ;"
  secrets = ["GITHUB_TOKEN", "ALGOLIA_API_KEY"]
}
