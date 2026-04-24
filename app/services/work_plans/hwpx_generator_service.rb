require "open3"
require "json"
require "nokogiri"

module WorkPlans
  class HwpxGeneratorService
    TEMPLATE_PATH = Rails.root.join("doc", "작업계획서_양식.hwpx")
    SCRIPT_PATH   = Rails.root.join("lib", "hwpx_fill.py")
    PYTHON_CMD    = %w[python3.11 python3.12 python3.14 python3].find { |cmd| system("which #{cmd} > /dev/null 2>&1") }

    def self.call(work_plan)
      new(work_plan).call
    end

    def initialize(work_plan)
      @work_plan = work_plan
    end

    def call
      raise "Python not found. Install python3 with lxml: sudo apt-get install -y python3-lxml" if PYTHON_CMD.nil?

      payload = build_payload.to_json
      stdout, stderr, status = Open3.capture3(PYTHON_CMD, SCRIPT_PATH.to_s,
                                              stdin_data: payload,
                                              binmode:    true)
      if !status.success? && stderr.include?("No module named 'lxml'")
        raise "lxml 모듈이 없습니다. 설치: sudo apt-get install -y python3-lxml"
      end
      raise "hwpx_fill.py failed: #{stderr}" unless status.success?

      stdout
    end

    private

    def build_payload
      {
        template_path: TEMPLATE_PATH.to_s,
        dept:          @work_plan.department_name,
        written_date:  @work_plan.doc_date.strftime("%Y-%m-%d"),
        work_name:     @work_plan.work_name,
        datetime_str:  formatted_datetime,
        content_html:  @work_plan.work_content.to_s,
        extra_info:    @work_plan.extra_info.to_s
      }
    end

    def formatted_datetime
      start_str = @work_plan.work_at.strftime("%Y년 %-m월 %-d일 %H:%M")
      if @work_plan.work_end_at.present?
        "#{start_str} ~ #{@work_plan.work_end_at.strftime('%H:%M')}"
      else
        start_str
      end
    end
  end
end
