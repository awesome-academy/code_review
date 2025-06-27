FROM ruby:2.5.9

# Cài dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential libpq-dev nodejs yarn \
  && rm -rf /var/lib/apt/lists/*

# Cài đúng version bundler
RUN gem install bundler -v 2.1.4

# Tạo thư mục app
WORKDIR /app

# Copy Gemfile để cài gems trước
COPY Gemfile Gemfile.lock /app/

# Cài gems
RUN bundle install

# Copy toàn bộ mã nguồn
COPY . /app

# Tạo entrypoint script để tránh lỗi server.pid
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Expose cổng Rails
EXPOSE 3000

# Lệnh mặc định
CMD ["rails", "server", "-b", "0.0.0.0"]
