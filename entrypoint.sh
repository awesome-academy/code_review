#!/bin/bash
set -e

# Xoá file pid nếu có (tránh lỗi khi restart container)
rm -f /app/tmp/pids/server.pid

# Chạy tiếp lệnh CMD đã định nghĩa
exec "$@"