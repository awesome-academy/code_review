# Code Review
## version Ruby đang cũ, hãy dùng docker để build
1. Sử dụng ruby 2.5.9 thay thế 2.5.1
 - sửa trong Gemfile 
 - Sửa trong .ruby_version
2. set oauth Github
GITHUB_CLIENT_ID và GITHUB_CLIENT_SECRET
bằng cách Truy cập: https://github.com/settings/developers

3. tạo config docker
    .dockerignore
	Dockerfile
	docker-compose.yml
	entrypoint.sh


4. Các lệnh cần quan tâm với docker
docker-compose down --volumes  # dọn sạch các container cũ
docker-compose build           # build lại image
docker-compose run --rm web rails db:create db:migrate
docker-compose up