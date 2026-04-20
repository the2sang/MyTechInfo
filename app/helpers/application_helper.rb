module ApplicationHelper
  MARKDOWN_RENDERER = Redcarpet::Render::HTML.new(
    filter_html: false,
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

  def render_markdown(text)
    return "" if text.blank?
    MARKDOWN_PARSER.render(text).html_safe
  end

  def render_tech_content(tech_info)
    return "" if tech_info.content.blank?
    case tech_info.content_format
    when "html"
      sanitize(tech_info.content, tags: %w[p br b i u strong em h1 h2 h3 h4 h5 h6 ul ol li a pre code blockquote table thead tbody tr th td hr span div], attributes: %w[href src alt class target rel])
    else
      render_markdown(tech_info.content)
    end
  end
end
