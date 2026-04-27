require "test_helper"
require "rake"

class AdminGrantTaskTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("admin:grant")
    Rake::Task["admin:grant"].reenable
    Rake::Task["admin:revoke"].reenable
  end

  test "promotes existing user idempotently" do
    user = users(:one)
    assert_not user.admin?

    ENV["EMAIL"] = user.email_address
    capture_io { Rake::Task["admin:grant"].invoke }

    assert user.reload.admin?

    Rake::Task["admin:grant"].reenable
    out, _err = capture_io { Rake::Task["admin:grant"].invoke }
    assert_match "Already admin", out
  ensure
    ENV.delete("EMAIL")
  end

  test "aborts on missing email" do
    user = users(:one)
    ENV["EMAIL"] = "nobody@nowhere.example"
    assert_raises(SystemExit) { Rake::Task["admin:grant"].invoke }
  ensure
    ENV.delete("EMAIL")
  end

  test "revoke flips back to user" do
    admin = users(:admin)
    ENV["EMAIL"] = admin.email_address
    capture_io { Rake::Task["admin:revoke"].invoke }
    assert admin.reload.user?
  ensure
    ENV.delete("EMAIL")
  end
end
