module ApplicationHelper
  # filter_html: true escapes raw HTML embedded in markdown source so user-authored
  # content cannot inject <script>, <iframe>, on*-handlers, etc. Markdown-generated
  # tags (h1-6, p, ul/ol, em/strong, table, code, ...) still pass through.
  MARKDOWN_RENDERER = Redcarpet::Render::HTML.new(
    filter_html: true,
    hard_wrap: true,
    link_attributes: { target: "_blank", rel: "noopener noreferrer" }
  )

  MARKDOWN_PARSER = Redcarpet::Markdown.new(
    MARKDOWN_RENDERER,
    autolink: true,
    tables: true,
    fenced_code_blocks: true,
    strikethrough: true,
    superscript: true
  )

  def highlight_search(text, query)
    return h(text) if query.blank? || text.blank?
    safe_text = h(text)
    safe_text.gsub(Regexp.new(Regexp.escape(query), Regexp::IGNORECASE)) do |match|
      "<mark class=\"search-hl\">#{match}</mark>"
    end.html_safe
  end

  def render_markdown(text)
    return "" if text.blank?
    MARKDOWN_PARSER.render(text).html_safe
  end

  def render_tech_content(tech_info)
    return nil if tech_info.content.blank?

    case tech_info.content_format
    when "html"
      result = sanitize(tech_info.content,
        tags: %w[p br b i u s strong em h1 h2 h3 h4 h5 h6 ul ol li a pre code blockquote table thead tbody tr th td hr span div figure figcaption mark sub sup],
        attributes: %w[href src alt class target rel data-language])
      strip_tags(result).strip.blank? ? nil : result
    else
      result = render_markdown(tech_info.content)
      strip_tags(result).strip.blank? ? nil : result
    end
  end
end
