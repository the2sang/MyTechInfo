require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "render_markdown returns blank for blank input" do
    assert_equal "", render_markdown(nil)
    assert_equal "", render_markdown("")
  end

  test "render_markdown escapes raw script tags in source" do
    out = render_markdown("Hello\n\n<script>alert(1)</script>\n\nworld")
    assert_no_match(/<script>alert\(1\)<\/script>/, out)
    assert_match(/Hello/, out)
    assert_match(/world/, out)
  end

  test "render_markdown escapes iframe and embed tags" do
    out = render_markdown("<iframe src=\"evil\"></iframe>")
    assert_no_match(/<iframe/, out)
  end

  test "render_markdown escapes inline event handlers on injected tags" do
    out = render_markdown("<img src=x onerror=\"alert(1)\">")
    assert_no_match(/onerror=/, out)
  end

  test "render_markdown preserves headings, bold, and links" do
    out = render_markdown("# Title\n\n**bold** and [link](https://example.com)")
    assert_match(/<h1>Title<\/h1>/, out)
    assert_match(/<strong>bold<\/strong>/, out)
    assert_match(/href="https:\/\/example\.com"/, out)
  end

  test "render_markdown adds noopener attributes to links" do
    out = render_markdown("[link](https://example.com)")
    assert_match(/target="_blank"/, out)
    assert_match(/rel="noopener noreferrer"/, out)
  end

  test "render_markdown preserves fenced code blocks" do
    out = render_markdown("```\n<script>x</script>\n```")
    assert_match(/<code>/, out)
    assert_no_match(/<script>x<\/script>/, out)
  end

  test "render_markdown preserves tables" do
    out = render_markdown("| a | b |\n|---|---|\n| 1 | 2 |")
    assert_match(/<table>/, out)
    assert_match(/<th>a<\/th>/, out)
  end

  test "render_markdown returns html_safe string" do
    assert_predicate render_markdown("hi"), :html_safe?
  end
end
