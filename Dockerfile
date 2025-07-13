FROM ruby:3.2-slim

RUN apt-get update -qq && \
    apt-get install -y build-essential libsqlite3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install --without development test

COPY . .

# Ensure the database file is present
RUN if [ ! -f quran-combined.db ]; then \
      echo "Error: quran-combined.db not found!" && exit 1; \
    fi && \
    chmod 644 quran-combined.db

EXPOSE 4567

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
