module KoreanHolidays
  # 한국 법정 공휴일 (대한민국 인사혁신처 공고 기준)
  HOLIDAYS = {
    # 2024
    Date.new(2024,  1,  1) => "신정",
    Date.new(2024,  2,  9) => "설날 전날",
    Date.new(2024,  2, 10) => "설날",
    Date.new(2024,  2, 11) => "설날 다음날",
    Date.new(2024,  2, 12) => "대체공휴일",
    Date.new(2024,  3,  1) => "삼일절",
    Date.new(2024,  4, 10) => "국회의원선거",
    Date.new(2024,  5,  5) => "어린이날",
    Date.new(2024,  5,  6) => "대체공휴일",
    Date.new(2024,  5, 15) => "부처님오신날",
    Date.new(2024,  6,  6) => "현충일",
    Date.new(2024,  8, 15) => "광복절",
    Date.new(2024,  9, 16) => "추석 전날",
    Date.new(2024,  9, 17) => "추석",
    Date.new(2024,  9, 18) => "추석 다음날",
    Date.new(2024, 10,  3) => "개천절",
    Date.new(2024, 10,  9) => "한글날",
    Date.new(2024, 12, 25) => "크리스마스",

    # 2025
    Date.new(2025,  1,  1) => "신정",
    Date.new(2025,  1, 28) => "설날 전날",
    Date.new(2025,  1, 29) => "설날",
    Date.new(2025,  1, 30) => "설날 다음날",
    Date.new(2025,  3,  1) => "삼일절",
    Date.new(2025,  3,  3) => "대체공휴일",
    Date.new(2025,  5,  5) => "어린이날·부처님오신날",
    Date.new(2025,  5,  6) => "대체공휴일",
    Date.new(2025,  6,  6) => "현충일",
    Date.new(2025,  8, 15) => "광복절",
    Date.new(2025, 10,  3) => "개천절",
    Date.new(2025, 10,  5) => "추석 전날",
    Date.new(2025, 10,  6) => "추석",
    Date.new(2025, 10,  7) => "추석 다음날",
    Date.new(2025, 10,  8) => "대체공휴일",
    Date.new(2025, 10,  9) => "한글날",
    Date.new(2025, 12, 25) => "크리스마스",

    # 2026
    Date.new(2026,  1,  1) => "신정",
    Date.new(2026,  2, 16) => "설날 전날",
    Date.new(2026,  2, 17) => "설날",
    Date.new(2026,  2, 18) => "설날 다음날",
    Date.new(2026,  3,  1) => "삼일절",
    Date.new(2026,  3,  2) => "대체공휴일",
    Date.new(2026,  5,  5) => "어린이날",
    Date.new(2026,  5, 24) => "부처님오신날",
    Date.new(2026,  5, 25) => "대체공휴일",
    Date.new(2026,  6,  6) => "현충일",
    Date.new(2026,  6,  8) => "대체공휴일",
    Date.new(2026,  8, 15) => "광복절",
    Date.new(2026,  8, 17) => "대체공휴일",
    Date.new(2026,  9, 24) => "추석 전날",
    Date.new(2026,  9, 25) => "추석",
    Date.new(2026,  9, 26) => "추석 다음날",
    Date.new(2026,  9, 28) => "대체공휴일",
    Date.new(2026, 10,  3) => "개천절",
    Date.new(2026, 10,  5) => "대체공휴일",
    Date.new(2026, 10,  9) => "한글날",
    Date.new(2026, 12, 25) => "크리스마스"
  }.freeze

  def self.for_month(year, month)
    start_date = Date.new(year, month, 1)
    end_date   = start_date.end_of_month
    HOLIDAYS.select { |date, _| date >= start_date && date <= end_date }
  end
end
