module TechInfos
  class ExportService
    FIELDS = %w[title content content_format reference_url related_tech extra_info usefulness].freeze

    def self.call(user:)
      records = user.tech_infos.order(:created_at).map { |t| t.slice(*FIELDS) }
      { version: 1, exported_at: Time.current.iso8601, records: records }.to_json
    end
  end
end
