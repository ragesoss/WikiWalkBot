require 'wikipedia_twitterbot'

Article.connect_to_database 'wikiwalkbot'

class WikiWalkBot
  def initialize(dry_run: false)
    @dry_run = dry_run
  end

  def start_walking
    Article.import_at_random min_views: 1000
    article = Article.all.sample
    tweet_and_step(article, nil, 0)
  end

  def tweet_and_step(article, reply_to_id, depth)
    return if depth > 30
    article.wikilinks.shuffle.each do |link|
      sentence = article.sentence_with(link)
      next unless sentence.present?
      next if sentence.length > 280
      next if sentence.length < 40
      pp "tweeting '#{link}' sentence from '#{article.title}'"
      pp sentence
      article.make_screenshot
      opts = {
        in_reply_to_status_id: reply_to_id,
        filename: article.screenshot_path
      }
      tweet = article.tweet(sentence, opts) unless @dry_run
      next_article = FindArticles.by_title link
      sleep 5
      return tweet_and_step(next_article, tweet.id, depth + 1)
    rescue StandardError => e
      pp e
      next
    end
  end
end
