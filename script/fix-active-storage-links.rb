#!/usr/bin/env ruby

require_relative "../config/environment"
require "uri"
require "base64"
require "json"

ActionText::RichText.all.where("body LIKE '%/rails/active_storage/%'").find_each do |rich_text|
  next unless rich_text.body

  blobs = rich_text.embeds.map(&:blob)

  rich_text.body.send(:attachment_nodes).each do |node|
    filename = node["filename"]

    blob = blobs.select { |b| b.filename == filename }
    raise "Multiple blobs with filename #{filename}" if blob.size > 1
    blob = blob.first

    node["sgid"] = blob.attachable_sgid
  end

  rich_text.save!
end
