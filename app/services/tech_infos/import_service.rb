module TechInfos
  class ImportService
    MAX_FILE_SIZE = 10.megabytes
    Result = Data.define(:imported, :skipped, :errors)

    def self.call(file:, user:)
      return Result.new(imported: 0, skipped: 0, errors: [ "파일을 선택하세요." ]) if file.nil?
      return Result.new(imported: 0, skipped: 0, errors: [ "파일 크기가 10MB를 초과합니다." ]) if file.size > MAX_FILE_SIZE

      data = JSON.parse(file.read)
      records = data["records"]
      return Result.new(imported: 0, skipped: 0, errors: [ "records 키가 없는 JSON 형식입니다." ]) unless records.is_a?(Array)

      imported = 0
      skipped = 0
      errors = []

      records.each do |attrs|
        title = attrs["title"].to_s.strip
        if title.blank?
          errors << "제목이 비어있는 레코드를 건너뜀"
          next
        end

        if user.tech_infos.exists?(title: title)
          skipped += 1
          next
        end

        user.tech_infos.create!(
          title: title,
          content: attrs["content"].to_s,
          content_format: attrs["content_format"].presence || "html",
          reference_url: attrs["reference_url"].presence,
          related_tech: attrs["related_tech"].presence,
          extra_info: attrs["extra_info"].presence,
          usefulness: attrs["usefulness"]&.to_i || 3
        )
        imported += 1
      rescue ActiveRecord::RecordInvalid => e
        errors << "\"#{title}\": #{e.record.errors.full_messages.join(', ')}"
      end

      Result.new(imported:, skipped:, errors:)
    rescue JSON::ParserError => e
      Result.new(imported: 0, skipped: 0, errors: [ "JSON 파싱 오류: #{e.message}" ])
    end
  end
end
