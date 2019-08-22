Rest API best practice
---
- [1. REST là gì?](#1-rest-là-gì)
- [2. REST URLs và Actions](#2-rest-urls-và-actions)
  - [2.1. Nguyên tắc đặt tên url](#21-nguyên-tắc-đặt-tên-url)
  - [2.2. Nếu action không fit với các CRUD operations?](#22-nếu-action-không-fit-với-các-crud-operations)
- [3. Response](#3-response)
- [4. Pagination](#4-pagination)
- [5. Caching](#5-caching)
  - [5.1. Cache trong Rest](#51-cache-trong-rest)
  - [5.2. Lợi ích của cache](#52-lợi-ích-của-cache)
  - [5.3. Có 2 cách cache](#53-có-2-cách-cache)
- [6. Rate-Limit](#6-rate-limit)
- [7. Authentication](#7-authentication)
- [8. API Documention](#8-api-documention)
- [9. PUSH vs POST](#9-push-vs-post)
- [10. Các bước thiết kế rest api](#10-các-bước-thiết-kế-rest-api)
- [11. REST API của các công ty lớn](#11-rest-api-của-các-công-ty-lớn)

# 1. REST là gì?

REST - Representational State Transfer - là một bộ quy tắc để tạo ra một ứng dụng Web Service bao gồm:

1.  Sử dụng các phương thức HTTP một cách rõ ràng
2.  Phi trạng thái
3.  Hiển thị cấu trúc thư mục như các URls
4.  Truyền tải JavaScript Object Notation (JSON), XML hoặc cả hai.

# 2. REST URLs và Actions

## 2.1. Nguyên tắc đặt tên url

**GET v1/users/1/groups**

- Chỉ sử dụng Entity. Dùng Nouns, không dùng Verbs. Trừ trường hợp không xác định được Entity cụ thể.
- Sử dụng số nhiều.
- Sử dụng snake_case cho tên biến. Sử dụng underscore cho URI.
- Có thông tin về version.
- Sử dụng đúng HTTP verb (GET, POST, PUT, DELETE) cho CRUD operations (read, create, update, delete)
- Không sử dụng quá 2 cấp: resource/identifier/resource/identifier

## 2.2. Nếu action không fit với các CRUD operations?

    **PUT /users/:id/active**

- **Hướng 1:** Biến action như là một field của resource.

Ví dụ: action activate có thể được mapped vào field activated của resource, và được cập nhật qua PATCH resource.

- **Hướng 2:** Đối xử như sub-resource, và sử dụng đầy đủ CRUD

  POST /users/:id/active

  DELETE /users/:id/active

- **Hướng 3:** Không có cách nào map một action với một RESTful Structure cụ thể. Ví dụ như **/search**, liên quan đến nhiều resource -> chấp nhận việc sử dụng URI trên, và cần viết tài liệu rõ ràng để tránh nhầm lẫn.

# 3. Response

- Biểu thị lỗi bằng HTTP status codes một cách chính xác
- Chỉ hỗ trợ việc trả về dữ liệu dạng JSON.
- Hỗ trợ gzip.
- Metadata: header hoặc body
- Content-type giữ đồng nhất
- Xây dựng 1 api đặc biệt trả về toàn bộ thông tin của các fields của object ngay cả khi field đó null

**Cấu trúc dữ liệu trả về:**

- Chỉ những dữ liệu dạng list thì mới trả về paging.
- Với dữ liệu dạng 1 resource đơn thì trả về json của resource đó, không dùng wrapper object.

# 4. Pagination

/users?page=2&per_page=10

Tham số url: page và per_page.
Link Headers:
Thông tin về paging nằm ở header (next_page, total, ...)
Phù hợp khi dữ liệu trả về là binary (images, pdf, ...)
Github sử dụng cách này

# 5. Caching

## 5.1. Cache trong Rest

- GET mặc định là có thể cache
- POST mặc định không thể cache, nhưng có thể làm cho nó cacheable bằng **Expires** header hoặc **Cache-control** header thêm vào response:

  Expires: Fri, 20 May 2016 19:20:49 IST
  Cache-Control: max-age=3600

## 5.2. Lợi ích của cache

- Giảm băng thông
- Giảm trễ
- Giảm tải cho server
- Ẩn các lỗi mạng

## 5.3. Có 2 cách cache

- Last-Modified
- Etag (Entity Tags)

  **Last-Modified**

  So sánh thời gian sửa đổi cuối cùng để xác định xem entity đã cập nhật nội dung nào mới chưa

  Nếu chưa gửi Http response 304 Not Modified.

        Last-Modified: Fri, 10 May 2016 09:17:49 IST

**Etag (Entity Tags)**

Khuyết điểm khi dùng Last-Modified: Múi giờ và thời gian của Server phải trùng với của client.

Có một cách khác là dùng Etag, nó là một chuỗi duy nhất được sinh ra bằng hash hoặc footprint được liên kết với tài nguyên, tức là mỗi lần có thay đổi là Etag cũng sẽ bị đổi theo.

        ETag: "abcd1234567n34jv"

# 6. Rate-Limit

- Giới hạn cho mỗi **access token**
- Giới hạn cho mỗi **ip address**
- Trả về **429 - Too Many Requests** khi vượt quá giới hạn, phần này nên cho vào HTTP response header:
  X-RateLimit-Limit - Giới hạn request trong một giờ
  X-RateLimit-Remaining - Số lượng request còn lại.
- Có thể áp dụng giải thuật Leaky bucket, Token bucket

# 7. Authentication

Không sử dụng session hay cookies, vì nó phá vỡ tính stateless của restfull khi server phải lưu trạng thái của client

Hiện tại có 3 cơ chế authenticate chính:

- HTTP Basic.
- JSON Web Token (JWT).
- OAuth2.

# 8. API Documention

- Format, cú pháp cần phải nhất quán, mô tả rõ ràng, chính xác.
- Mô tả đầy đủ về params request: gồm những params nào, datatype, require hay optional.
- Error message rõ ràng, chính xác, giúp kiểm soát tốt hệ thống, debug, maintain
- Có ví dụ về HTTP requests và responses với data chuẩn.
- Cập nhật Docs thường xuyên, để sát nhất với API có bất cứ thay đổi gì.
- Có thể sử dụng API frameworks nổi tiếng như Swagger, Apiary, Postman, Slate...

# 9. PUSH vs POST

https://restfulapi.net/rest-put-vs-post/

# 10. Các bước thiết kế rest api

https://restfulapi.net/rest-api-design-tutorial-with-example/

# 11. REST API của các công ty lớn

- Shopify: https://help.shopify.com/api/reference/blog
- Twitter: https://dev.twitter.com/rest/reference
- Stripe: https://stripe.com/docs/api#versioning
- Github. https://developer.github.com/v3/gists/#list-gists
- Docker. https://docs.docker.com/engine/api/v1.29/
- Facebook: https://developers.facebook.com/
- Uber: https://app.swaggerhub.com/apis/bsprabhuskd/uber-api/1.0.0
- Dropbox: https://www.dropbox.com/developers/documentation/http/documentation
