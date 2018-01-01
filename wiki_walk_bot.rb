require 'wikipedia_twitterbot'

Article.connect_to_database 'wikiwalkbot'

class WikiWalkBot
  def start_walking
    article = Article.all.sample
    tweet_and_step(article, 0)
  end

  def tweet_and_step(article, depth)
    return if depth > 3
    article.wikilinks.shuffle.each do |link|
      sentence = article.sentence_with(link)
      next unless sentence.present?
      next if sentence.length > 280
      next if sentence.length < 40
      pp "tweeting '#{link}' sentence from '#{article.title}'"
      pp sentence
      article.tweet(sentence)
      next_article = FindArticles.by_title link
      sleep 5
      return tweet_and_step(next_article, depth + 1)
    end
  end
end
