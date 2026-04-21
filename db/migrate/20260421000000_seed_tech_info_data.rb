class SeedTechInfoData < ActiveRecord::Migration[8.1]
  def up
    # 시스템 유저 생성 (없으면 생성, 있으면 기존 유저 사용)
    system_user_id = find_or_create_system_user

    tech_infos = [
      {
        title: "Rails 8 Solid Stack",
        reference_url: "https://rubyonrails.org",
        related_tech: "Rails, Ruby, SQLite",
        content: "Rails 8 introduces the Solid Stack for zero-infrastructure deployments.",
        extra_info: "매우 유용한 기술",
        usefulness: 4,
        content_format: "markdown"
      },
      {
        title: "Markdown Test",
        reference_url: nil,
        related_tech: nil,
        content: "# 제목\n\n**굵게** 와 *이탤릭*\n\n```ruby\nputs 'hello'\n```\n\n- 항목 1\n- 항목 2",
        extra_info: nil,
        usefulness: 5,
        content_format: "markdown"
      },
      {
        title: "AI 시대에도 살아남는 엄청난 디자인을 가진 사이트들",
        reference_url: "https://www.youtube.com/watch?v=KACClD5qEYE",
        related_tech: "웹디자인",
        content: <<~CONTENT,
          AI시대에도 디자인과 UX는 여전히 경쟁력으로 통하네요.

          00:00 인트로 — AI 시대, 왜 디자인인가
          00:23 1. Nous Research: 공포 영화 콘셉트의 연구소 사이트
          01:03  └ Nous Psyche: 매트릭스풍 분산 학습 대시보드
          01:47  └ LLM 에이전트 & 블로그: 픽셀 그래픽의 예술성
          04:10 2. every.to: 일러스트 감성의 AI 미디어 랜딩
          05:51 3. Idea Instructions: 알고리즘을 이케아 매뉴얼처럼
          07:07 4. Linux Kernel Map: 커널을 지도로 보는 인터랙티브
          08:57 5. Every GPU that Mattered: 트랜지션으로 그린 GPU 역사
          10:07 6. Neal.fun: 돈 찍는 속도, 심해 생물 등 인터랙티브 모음
          12:57 7. Making Software: 소프트웨어 원리의 정교한 시각화
          15:33 8. KingMath: 바이브 코딩으로 만든 교육 게이미피케이션
          16:09 9. Crontab Guru: 크론 표현식을 문장으로 풀어주는 유틸
          17:07 10. Gumroad: 일러스트와 각진 디자인의 디지털 마켓
          18:27 아웃트로 — 창의성과 디자인 철학이 경쟁력
        CONTENT
        extra_info: "맥북 새로 사셨나요? AI 세팅하세요: https://inf.run/LzHJr\nGLM 5.1 코딩플랜 10% 추가 할인: https://z.ai/subscribe?ic=Q5GKHMRKNU",
        usefulness: 3,
        content_format: "html"
      }
    ]

    tech_infos.each do |attrs|
      next if tech_info_exists?(attrs[:title])

      execute <<~SQL
        INSERT INTO tech_infos (user_id, title, reference_url, related_tech, content, extra_info, usefulness, content_format, created_at, updated_at)
        VALUES (
          #{system_user_id},
          #{quote(attrs[:title])},
          #{attrs[:reference_url] ? quote(attrs[:reference_url]) : 'NULL'},
          #{attrs[:related_tech] ? quote(attrs[:related_tech]) : 'NULL'},
          #{quote(attrs[:content])},
          #{attrs[:extra_info] ? quote(attrs[:extra_info]) : 'NULL'},
          #{attrs[:usefulness]},
          #{quote(attrs[:content_format])},
          datetime('now'),
          datetime('now')
        )
      SQL
    end
  end

  def down
    titles = [
      "Rails 8 Solid Stack",
      "Markdown Test",
      "AI 시대에도 살아남는 엄청난 디자인을 가진 사이트들"
    ]
    titles.each do |title|
      execute "DELETE FROM tech_infos WHERE title = #{quote(title)}"
    end
  end

  private

  def find_or_create_system_user
    result = execute("SELECT id FROM users LIMIT 1")
    return result.first["id"] if result.any?

    execute <<~SQL
      INSERT INTO users (email_address, password_digest, created_at, updated_at)
      VALUES ('system@example.com', 'not-a-real-password', datetime('now'), datetime('now'))
    SQL
    execute("SELECT id FROM users WHERE email_address = 'system@example.com'").first["id"]
  end

  def tech_info_exists?(title)
    execute("SELECT id FROM tech_infos WHERE title = #{quote(title)}").any?
  end

  def quote(value)
    ActiveRecord::Base.connection.quote(value)
  end
end
