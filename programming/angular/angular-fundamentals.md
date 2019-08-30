Angular fundamentals
---

- [1. Components and Templates](#1-components-and-templates)
  - [1.1. Tương tác giữa các component với nhau](#11-tương-tác-giữa-các-component-với-nhau)
- [2. Routing and Navigation](#2-routing-and-navigation)

# 1. Components and Templates

## 1.1. Tương tác giữa các component với nhau

https://angular.io/guide/component-interaction#parent-and-children-communicate-via-a-service

Thao khảo link trên thì có các cách sau:

- Truyền data từ parent đến child dùng input binding
- Dùng setter để chặn input property và hành động theo giá trị truyền từ parent
- Dùng `ngOnChanges()` để chặn input property và hành động theo giá trị truyền từ parent
- Parent lắng nghe event từ child dùng `@Input và @Output`
- Parent tương tác với child qua local variable
- Parent gọi child dùng `@ViewChild()`
- Parent và children tương tác với nhau qua một service

# 2. Routing and Navigation

https://angular.io/guide/router
