#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative "bundle/bundler/setup"
require "alfred"
require "qiita"
require "time"

access_token = 'YOUR_ACCESS_TOKEN'
team_name = 'YOUR_TEAM_NAME'

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback

  client = Qiita::Client.new(
    access_token: access_token,
    team: team_name
  )

  if ARGV[0] == "PROJECTS"
    projects = client.list_projects(per_page: 15).body
    projects.each do |project|
      fb.add_item(
        uid: "",
        title: project['name'],
        arg: "https://" + team_name + ".qiita.com/projects/" + project['id'].to_s,
        valid: "yes"
      )
    end
  elsif ARGV[0] == "RECENT_POSTS"
    items = client.list_items(per_page: 7).body
    items.each do |item|
      fb.add_item(
        uid: "",
        title: item['title'],
        subtitle: Time.parse(item['created_at']).strftime("%Y-%m-%d %H:%M") + "   " + item['user']['name'],
        arg: item['url'],
        valid: "yes"
      )
    end
  else
    fb.add_item(
      uid: "",
      title: "Search \"" + ARGV[0] + "\" on Qiita:Team",
      arg: "https://" + team_name + ".qiita.com/search?utf8=✓&sort=rel&q=" + ARGV[0],
      valid: "yes"
    )
  end 

  puts fb.to_xml
end
