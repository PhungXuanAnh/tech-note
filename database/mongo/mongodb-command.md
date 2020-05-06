- [1. Install mongo](#1-install-mongo)
  - [1.1. Using Docker](#11-using-docker)
  - [1.2. Install directly](#12-install-directly)
- [2. Install mongo command line](#2-install-mongo-command-line)
  - [2.1. Get URI of sharding server](#21-get-uri-of-sharding-server)
- [3. Command](#3-command)
  - [3.1. Access mongo command](#31-access-mongo-command)
  - [3.2. Help command](#32-help-command)
  - [3.3. Database](#33-database)
    - [3.3.1. Create database](#331-create-database)
    - [3.3.2. List database](#332-list-database)
    - [3.3.3. Delete database](#333-delete-database)
    - [3.3.4. Export and import](#334-export-and-import)
  - [3.4. Collection](#34-collection)
    - [3.4.1. Create collection](#341-create-collection)
    - [3.4.2. List collection](#342-list-collection)
    - [3.4.3. Delete collection](#343-delete-collection)
  - [3.5. Document](#35-document)
    - [3.5.1. Insert document](#351-insert-document)
    - [3.5.2. Insert or Update document](#352-insert-or-update-document)
    - [3.5.3. Query document](#353-query-document)
      - [3.5.3.1. find() method](#3531-find-method)
      - [3.5.3.2. pretty() method](#3532-pretty-method)
      - [3.5.3.3. condition in query](#3533-condition-in-query)
      - [3.5.3.4. AND statement](#3534-and-statement)
      - [3.5.3.5. OR statement](#3535-or-statement)
      - [3.5.3.6. AND OR combined](#3536-and-or-combined)
    - [3.5.4. Update document](#354-update-document)
      - [3.5.4.1. update() method](#3541-update-method)
      - [3.5.4.2. save() method](#3542-save-method)
    - [3.5.5. Delete document](#355-delete-document)
- [4. Reference](#4-reference)

# 1. Install mongo

## 1.1. Using Docker

```shell
docker run -d \
  -p  27017:27017 \
  --name my-mongo \
  -v /home/xuananh/Downloads/mongo-data:/data/db \
  mongo
```
## 1.2. Install directly

# 2. Install mongo command line

If install mongo directly, it will come with mongo commanline else we can install it

Install mongo comamnd line on ubuntu 18.04, reference: https://askubuntu.com/a/1127143

Add source:

```shell
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
```

The source contains few packages. According to the MongoDB Manual it's like this:

- **mongodb-org** - A metapackage that will automatically install the four component packages listed below.
- **mongodb-org-server** - Contains the mongod daemon and associated configuration and init scripts.
- **mongodb-org-mongos** - Contains the mongos daemon.
- **mongodb-org-shell** - Contains the mongo shell.
- **mongodb-org-tools** - Contains the following MongoDB tools: mongoimport bsondump, mongodump, - mongoexport, mongofiles, mongooplog, mongoperf, mongorestore, mongostat, and mongotop.

Setup needed tools:

```shell
sudo apt-get update
sudo apt-get install -y mongodb-org-shell
sudo apt-get install -y mongodb-org-tools
```

Test:

```shell
export MONGO_HOST=
export MONGO_PORT=
export MONGO_USER=
export MONGO_PASS=
mongo --host=$MONGO_HOST --port=$MONGO_PORT \
  --username=$MONGO_USER --password=$MONGO_PASS \
  --verbose
```

or using uri:

```shell
export MONGO_HOST=
export MONGO_PORT=
export MONGO_USER=
export MONGO_PASS=
export MONGO_DB_NAME=
# if using this uri:
"mongodb+srv://$MONGO_USER:$MONGO_PASS@$MONGO_HOST/$MONGO_DB_NAME?authSource=staging&retryWrites=true&w=majority"
# we can connect to mongodb using this command
mongo --host="mongodb+srv://$MONGO_HOST:$MONGO_PORT/staging?username=$MONGO_USER" \
  --username=$MONGO_USER \
  --password=$MONGO_PASS \
  --verbose
```


## 2.1. Get URI of sharding server

```shell
export MONGO_HOST=
export MONGO_PORT=
export MONGO_USER=
export MONGO_PASS=
export MONGO_DB_NAME=
# if using this uri:
"mongodb+srv://$MONGO_USER:$MONGO_PASS@$MONGO_HOST/$MONGO_DB_NAME?authSource=staging&retryWrites=true&w=majority"
```

Get sharding uri using *mongo* command:

https://docs.mongodb.com/manual/reference/connection-string/

https://docs.mongodb.com/manual/reference/program/mongodump/#mongodump-examples

https://docs.mongodb.com/manual/reference/program/mongorestore/#bin.mongorestore

```shell
mongo --host="mongodb+srv://$MONGO_HOST:$MONGO_PORT/staging?username=$MONGO_USER" \
  --username=$MONGO_USER \
  --password=$MONGO_PASS \
  --verbose
```

And get log message:

```shell
MongoDB shell version v4.0.17
connecting to: mongodb://mongodb-domain-00-00-d1oi2.mongodb.net.:27017,mongodb-domain-00-01-d1oi2.mongodb.net.:27017,mongodb-domain-00-02-d1oi2.mongodb.net.:27017/?authSource=admin&gssapiServiceName=mongodb&replicaSet=mongodb-domain-0&ssl=true
...
```

replace *.:27017* by *:27017* remove *&gssapiServiceName=mongodb*, add database_name, we get needed uri:

**NOTE**: don't using `mongdb+srv` with any UI software or commmand `mongodump` and `mongostore`. Just using it with `mongo` command

```shell
mongodb://mongodb-domain-00-00-d1oi2.mongodb.net:27017,mongodb-domain-00-01-d1oi2.mongodb.net:27017,mongodb-domain-00-02-d1oi2.mongodb.net:27017/$MONGO_DB_NAME?authSource=admin&gssapiServiceName=mongodb&replicaSet=mongodb-domain-0&ssl=true
```


# 3. Command

## 3.1. Access mongo command

```shell
mongo
```

## 3.2. Help command

```shell
>help
```

## 3.3. Database

### 3.3.1. Create database

Tạo mới database nếu không tồn tại:

```shell
use DATABASE_NAME
```

Để kiểm tra cơ sở dữ liệu đã chọn hiện tại, bạn sử dụng lệnh db.
```shell
db
show dbs
```

Cơ sở dữ liệu mydb đã được tạo của bạn không có trong danh sách này. Để hiển thị nó, bạn cần chèn ít nhất một Collection vào trong đó.

```shell
db.movie.insert({"name":"tutorials point"})
show dbs
```

### 3.3.2. List database

```shell
show dbs
```

### 3.3.3. Delete database

```shell
show dbs
use mydb

db.dropDatabase()
```

Lệnh này sẽ xóa cơ sở dữ liệu đã chọn. Nếu bạn không chọn bất kỳ cơ sở dữ liệu nào, thì nó sẽ xóa cơ sở dữ liệu mặc định test.

### 3.3.4. Export and import

**Backup single database**

```shell
mongodump --host localhost --port 27017 --username=admin --password=123 --db=db_name --out=/home/user/ --verbose=4
mongodump -d <database_name> -o <directory_backup>
# or
mongodump --uri=$MONGO_URI --verbose
```

It will export to folder named `dump`

**Restore single database**

```shell
mongorestore -d <database_name> <directory_backup>
mongorestore --host localhost --port 27017 --db **** dump/db_name
# (In this case, **** represents any name for the database)
```

**Backup all databases**

```shell
mongodump --host localhost --port 27017
```

**Restore all databases**

```shell
mongorestore --host localhost --port 27017  dump
```

## 3.4. Collection

### 3.4.1. Create collection

```shell
db.createCollection(name, options)
```

| Tham số | Kiểu      | Miêu tả                                                     |
| :------ | :-------- | :---------------------------------------------------------- |
| name    | chuỗi     | tên collection                                              |
| options | doccument | xác định các tùy chọn về kích cỡ bộ nhớ và việc lập chỉ mục |

Tham số options là tùy ý, vì thế bạn chỉ cần xác định tên của Collection. Dưới đây là danh sách các tùy chọn bạn có thể sử dụng:

| Trường      | Kiểu    | Miêu tả                                                                                                                                                                                                                      |
| :---------- | :------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| capped      | Boolean | Nếu true, kích hoạt một Capped Collection. Đây là một Collection có kích cỡ cố định mà tự động ghi đè các entry cũ nhất khi nó tiếp cận kích cỡ tối đa. **Nếu bạn xác định là true, thì bạn cũng cần xác định tham số size** |
| autoIndexID | Boolean | Nếu true, tự động tạo chỉ mục trên các trường _id. Giá trị mặc định là false                                                                                                                                                 |
| size        | số      | Xác định kích cỡ tối đa (giá trị byte) cho một Capped Collection. **Nếu tham số capped là true, thì bạn cũng cần xác định trường này**                                                                                       |
| max         | số      | Xác định số Document tối đa được cho phép trong một Capped Colleciton                                                                                                                                                        |

### 3.4.2. List collection

```shell
show collections
```

### 3.4.3. Delete collection

```shell
db.collection.drop()
# or
db.post.save(document)
```

## 3.5. Document

### 3.5.1. Insert document

```python
db.COLLECTION_NAME.insert(document)
# ex:
db.mycol.insert({
   _id: ObjectId(7df78ad8902c),
   title: 'MongoDB Overview', 
   description: 'MongoDB is no sql database',
   by: 'tutorials point',
   url: 'http://www.tutorialspoint.com',
   tags: ['mongodb', 'database', 'NoSQL'],
   likes: 100
})

# chèn nhiều document trong 1 truy vấn
db.post.insert([
{
   title: 'MongoDB Overview', 
   description: 'MongoDB is no sql database',
   by: 'tutorials point',
   url: 'http://www.tutorialspoint.com',
   tags: ['mongodb', 'database', 'NoSQL'],
   likes: 100
},
{
   title: 'NoSQL Database', 
   description: 'NoSQL database doesn't have tables',
   by: 'tutorials point',
   url: 'http://www.tutorialspoint.com',
   tags: ['mongodb', 'database', 'NoSQL'],
   likes: 20, 
   comments: [	
      {
         user:'user1',
         message: 'My first comment',
         dateCreated: new Date(2013,11,10,2,35),
         like: 0 
      }
   ]
}
])
```
* Ở đây, **mycol** là tên của Collection, đã được tạo trong chương trước. Nếu Collection này chưa tồn tại trong cơ sở dữ liệu, thì MongoDB sẽ tạo Collection này và sau đó chèn Document vào trong nó.
* Trong Document được chèn, nếu chúng ta không xác định tham số _id, thì MongoDB gán một ObjectId duy nhất cho Document này.
* _id là một số thập lục phân duy nhất, dài 12 byte cho mỗi Document trong một Collection. 12 byte được phân chia như sau (đã được mô tả trong các chương trước):
* Để chèn nhiều Document trong một truy vấn đơn, bạn có thể truyền một mảng các Document trong lệnh insert().
* Để chèn dữ liệu vào trong Document, bạn cũng có thể sử dụng **db.post.save(document)**. 
  * Nếu bạn không xác định _id trong Document, thì phương thức **save()** sẽ làm việc giống như phương thức **insert()**.
  * Nếu bạn xác định _id, thì nó sẽ thay thế toàn bộ dữ liệu của Document chứa _id khi được xác định trong phương thức **save()**.


### 3.5.2. Insert or Update document

```python
db.collection.updateOne(
   <filter>,
   <update>,
   {
     upsert: <boolean>,    # upsert: When true, update already exist document or create new one
     writeConcern: <document>,
     collation: <document>,
     arrayFilters: [ <filterdocument1>, ... ]
   }
)
```


### 3.5.3. Query document

#### 3.5.3.1. find() method
Phương thức **find()** sẽ hiển thị tất cả Document ở dạng không có cấu trúc (hiển thị không theo cấu trúc nào).

```shell
db.COLLECTION_NAME.find()
```

#### 3.5.3.2. pretty() method

```shell
db.mycol.find().pretty()
# ex:
db.mycol.find().pretty()
{
   "_id": ObjectId(7df78ad8902c),
   "title": "MongoDB Overview", 
   "description": "MongoDB is no sql database",
   "by": "tutorials point",
   "url": "http://www.tutorialspoint.com",
   "tags": ["mongodb", "database", "NoSQL"],
   "likes": "100"
}
```
* Để hiển thị các kết quả theo một cách đã được định dạng, bạn có thể sử dụng phương thức pretty().
* Ngoài phương thức find(), trong MongoDB còn có phương thức findOne() sẽ chỉ trả về một Document.

#### 3.5.3.3. condition in query

* Truy vấn trong MongoDB mà tương đương mệnh đề WHERE trong RDBMS
* Để truy vấn Document dựa trên một số điều kiện nào đó, bạn có thể sử dụng các phép toán sau:

| Phép toán           | Cú pháp                | Ví dụ                                            | Mệnh đề WHERE tương đương    |
| :------------------ | :--------------------- | :----------------------------------------------- | :--------------------------- |
| Equality            | {<key>:<value>}        | db.mycol.find({"by":"tutorials point"}).pretty() | where by = 'tutorials point' |
| Less Than           | {<key>:{$lt:<value>}}  | db.mycol.find({"likes":{$lt:50}}).pretty()       | where likes < 50             |
| Less Than Equals    | {<key>:{$lte:<value>}} | db.mycol.find({"likes":{$lte:50}}).pretty()      | where likes <= 50            |
| Greater Than        | {<key>:{$gt:<value>}}  | db.mycol.find({"likes":{$gt:50}}).pretty()       | where likes > 50             |
| Greater Than Equals | {<key>:{$gte:<value>}} | db.mycol.find({"likes":{$gte:50}}).pretty()      | where likes >= 50            |
| Not Equals          | {<key>:{$ne:<value>}}  | db.mycol.find({"likes":{$ne:50}}).pretty()       | where likes != 50            |

#### 3.5.3.4. AND statement

```shell
db.mycol.find({key1:value1, key2:value2}).pretty()
```

* Trong phương thức **find()**, nếu bạn truyền nhiều key bằng cách phân biệt chúng bởi dấu phảy (,), thì MongoDB xem nó như là điều kiện **AND**
* Bạn có thể truyền bất kỳ số cặp key-value nào trong mệnh đề find.
* Ví dụ sau hiển thị tất cả loạt bài hướng dẫn (tutorials) được viết bởi 'tutorials point' có title là 'MongoDB Overview'
* Mệnh đề WHERE tương đương với ví dụ trên sẽ là ' where by='tutorials point' AND title='MongoDB Overview' '.

```shell
db.mycol.find({"by":"tutorials point","title": "MongoDB Overview"}).pretty()
{
   "_id": ObjectId(7df78ad8902c),
   "title": "MongoDB Overview", 
   "description": "MongoDB is no sql database",
   "by": "tutorials point",
   "url": "http://www.tutorialspoint.com",
   "tags": ["mongodb", "database", "NoSQL"],
   "likes": "100"
}
```

#### 3.5.3.5. OR statement

```shell
db.mycol.find(
   {
      $or: [
	     {key1: value1}, {key2:value2}
      ]
   }
).pretty()

#ex: ----------------------------

db.mycol.find({$or:[{"by":"tutorials point"},{"title": "MongoDB Overview"}]}).pretty()
{
   "_id": ObjectId(7df78ad8902c),
   "title": "MongoDB Overview", 
   "description": "MongoDB is no sql database",
   "by": "tutorials point",
   "url": "http://www.tutorialspoint.com",
   "tags": ["mongodb", "database", "NoSQL"],
   "likes": "100"
}
```

#### 3.5.3.6. AND OR combined

* Ví dụ sau hiển thị các Document mà có các like lớn hơn 100 và có title là hoặc 'MongoDB Overview' hoặc bởi là 'tutorials point'. 
* Mệnh đề WHERE trong truy vấn SQL tương đương là 'where likes>10 AND (by = 'tutorials point' OR title = 'MongoDB Overview')'

```shell
db.mycol.find({"likes": {$gt:10}, $or: [{"by": "tutorials point"},{"title": "MongoDB Overview"}]}).pretty()
{
   "_id": ObjectId(7df78ad8902c),
   "title": "MongoDB Overview", 
   "description": "MongoDB is no sql database",
   "by": "tutorials point",
   "url": "http://www.tutorialspoint.com",
   "tags": ["mongodb", "database", "NoSQL"],
   "likes": "100"
}
```

### 3.5.4. Update document

* Phương thức **update()** hoặc **save()** trong MongoDB được sử dụng để cập nhật Document vào trong một Collection. 
* Phương thức **update()** cập nhật các giá trị trong Document đang tồn tại 
* Phương thức **save()** thay thế Document đang tồn tại với Document đã truyền trong phương thức **save()** đó.

#### 3.5.4.1. update() method

Phương thức update() cập nhật các giá trị trong Document đang tồn tại.

```shell
db.COLLECTION_NAME.update(SELECTIOIN_CRITERIA, UPDATED_DATA)
```


Ví dụ:

Bạn theo dõi Collection có tên mycol có dữ liệu sau:

```shell
{ "_id" : ObjectId(5983548781331adf45ec5), "title":"MongoDB Overview"}
{ "_id" : ObjectId(5983548781331adf45ec6), "title":"NoSQL Overview"}
{ "_id" : ObjectId(5983548781331adf45ec7), "title":"Tutorials Point Overview"}
```
Ví dụ sau sẽ thiết lập tiêu đề mới 'New MongoDB Tutorial' của Document có tiêu đề là 'MongoDB Overview':
```shell
>db.mycol.update({'title':'MongoDB Overview'},{$set:{'title':'New MongoDB Tutorial'}})
>db.mycol.find()
{ "_id" : ObjectId(5983548781331adf45ec5), "title":"New MongoDB Tutorial"}
{ "_id" : ObjectId(5983548781331adf45ec6), "title":"NoSQL Overview"}
{ "_id" : ObjectId(5983548781331adf45ec7), "title":"Tutorials Point Overview"}
>
```
Theo mặc định, MongoDB sẽ chỉ cập nhật một Document đơn, để cập nhật nhiều Document, bạn thiết lập tham số 'multi' thành true.
```shell
>db.mycol.update({'title':'MongoDB Overview'},{$set:{'title':'New MongoDB Tutorial'}},{multi:true})
```

#### 3.5.4.2. save() method

Phương thức save() thay thế Document đang tồn tại với Document mới đã được truyền trong phương thức save() này.

```shell
db.COLLECTION_NAME.save({_id:ObjectId(),NEW_DATA})
```

Ví dụ sau sẽ thay thế Document với _id là '5983548781331adf45ec7'.

```shell
>db.mycol.save(
   {
      "_id" : ObjectId(5983548781331adf45ec7), "title":"Tutorials Point New Topic", "by":"Tutorials Point"
   }
)
>db.mycol.find()
{ "_id" : ObjectId(5983548781331adf45ec5), "title":"Tutorials Point New Topic", "by":"Tutorials Point"}
{ "_id" : ObjectId(5983548781331adf45ec6), "title":"NoSQL Overview"}
{ "_id" : ObjectId(5983548781331adf45ec7), "title":"Tutorials Point Overview"}
>
```

### 3.5.5. Delete document

```shell
db.COLLECTION_NAME.remove(DELLETION_CRITTERIA)

#ex: ------------------------------
>db.mycol.remove({'title':'MongoDB Overview'})
>db.mycol.find()
{ "_id" : ObjectId(5983548781331adf45ec6), "title":"NoSQL Overview"}
{ "_id" : ObjectId(5983548781331adf45ec7), "title":"Tutorials Point Overview"}
>
```

**Chỉ xóa một Document trong MongoDB**
Nếu có nhiều bản ghi và bạn chỉ muốn xóa bản ghi đầu tiên, thì thiết lập tham số justOne trong phương thức remove().

```shell
db.COLLECTION_NAME.remove(DELETION_CRITERIA,1)
```

**Xóa tất cả Document trong MongoDB**
Nếu bạn không xác định deletion criteria, thì MongoDB sẽ xóa toàn bộ Document từ Collection. Điều này tương đương với lệnh truncate trong SQL.

```shell
db.mycol.remove()
```


# 4. Reference
[https://vietjack.com/mongodb/](https://vietjack.com/mongodb/)