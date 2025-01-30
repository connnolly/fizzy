require "rouge/plugins/redcarpet"

class MarkdownRenderer < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet

  def self.build
    Redcarpet::Markdown.new MarkdownRenderer.new(filter_html: false),
      autolink: true, highlight: true, no_intra_emphasis: true,
      fenced_code_blocks: true, lax_spacing: true, strikethrough: true, tables: true
  end

  def initialize(...)
    super
    @id_counts = Hash.new 0
  end

  def header(text, header_level)
    unique_id(text).then do |id|
      <<~HTML.chomp
        <h#{header_level} id="#{id}">
          #{text} <a href="##{id}" class="heading__link" aria-hidden="true">#</a>
        </h#{header_level}>
      HTML
    end
  end

  def image(url, title, alt_text)
    <<~HTML.chomp
      <a title="#{title}" href="#{url}" data-action="lightbox#open:prevent" data-lightbox-target="image" data-lightbox-url-value="#{url}?disposition=attachment">
        <img src="#{url}" alt="#{alt_text}">
      </a>
    HTML
  end

  def code_block(code, language)
    block_code(code, language) # call Rouge Redcarpet plugin
  end

  def link(url, title, content)
    return video_tag(url, title) if video_url?(url)

    attributes = { href: url }
    attributes[:title] = title if title
    attributes["data-turbo-frame"] = "_top"

    "<a #{html_attributes(attributes)}>#{content}</a>"
  end

  def autolink(url, link_type)
    attributes = { href: url }
    attributes["data-turbo-frame"] = "_top"

    "<a #{html_attributes(attributes)}>#{url}</a>"
  end

  private
    attr_reader :id_counts

    def html_attributes(attributes)
      attributes.map { |key, value| %Q(#{key}="#{value}") }.join(" ")
    end

    def unique_id(text)
      text.parameterize.then do |base_id|
        id_counts[base_id] += 1
        id_counts[base_id] > 1 ? "#{base_id}-#{id_counts[base_id]}" : base_id
      end
    end

    def video_url?(url)
      File.extname(url).downcase.match?(/\.(mp4|webm|ogg)/)
    end

    def video_tag(url, title)
      <<~HTML.chomp
        <video controls title="#{title}" width="1024">
          <source src="#{url}" type="video/#{File.extname(url).delete('.')}">
        </video>
      HTML
    end
end
