ARG RUBY_VERSION=3.3.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libsqlite3-dev curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --without development test

# Copy application files
COPY . .

# Create directory for views if it doesn't exist
RUN mkdir -p views

# Ensure the database file is present and set permissions
RUN if [ ! -f quran-combined.db ]; then \
      echo "Error: quran-combined.db not found!" && exit 1; \
    fi && \
    chmod 644 quran-combined.db

# Expose port
EXPOSE 4567

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:4567/health || exit 1

# Run the application
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "4567"]
