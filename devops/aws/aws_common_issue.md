Tập hợp những kinh nghiệm gỡ rối khi triển khai trên aws
---

- [1. Api gateway](#1-api-gateway)
  - [1.1. Custome authorizer](#11-custome-authorizer)
    - [1.1.1. AuthorizerConfigurationException](#111-authorizerconfigurationexception)

# 1. Api gateway

## 1.1. Custome authorizer

### 1.1.1. AuthorizerConfigurationException

Các bước kiểm tra:

**Step 1**:

- Vào phần **Authorizer** của api gateway, chọn test

![img1](../../images/devops/aws/aws-common-issue-1.png)

- Nó hiện nên 1 cái khung, điền thông tin authenticate vào, click **Test** button:

![img1](../../images/devops/aws/aws-common-issue-2.png)

- Kiểm tra Response phía bên dưới, mấy dòng cuối cùng sẽ cho chúng ta biết lỗi là tại sao, các lỗi thường gặp:
  - api gateway không có permission call authorizer
  - api gateway không lấy được thông tin authentication để truyền cho authorizer lambda, thường là trong kiểu **TOKEN**, request gửi lên thiếu header authorizor

Ví dụ response:

```shell
Execution log for request 29d2b4df-26da-4cae-aeca-f9ef6c338d88
Thu Sep 05 04:56:39 UTC 2019 : Starting authorizer: 52u008 for request: 29d2b4df-26da-4cae-aeca-f9ef6c338d88
Thu Sep 05 04:56:39 UTC 2019 : Incoming identity: {method.request.header.Hash=********aaaaaa}
Thu Sep 05 04:56:39 UTC 2019 : Endpoint request URI: https://lambda.ap-southeast-2.amazonaws.com/2015-03-31/functions/arn:aws:lambda:ap-southeast-2:654888109795:function:dev-HashMACSHM-Authorizer/invocations
Thu Sep 05 04:56:39 UTC 2019 : Endpoint request headers: {x-amzn-lambda-integration-tag=29d2b4df-26da-4cae-aeca-f9ef6c338d88, Authorization=*****************************************************************************************************************************************************************************************************************************************************************************************************************************90bbd8, X-Amz-Date=20190905T045639Z, x-amzn-apigateway-api-id=ja8pdvfjf6, X-Amz-Source-Arn=arn:aws:execute-api:ap-southeast-2:654888109795:ja8pdvfjf6/authorizers/52u008, Accept=application/json, User-Agent=AmazonAPIGateway_ja8pdvfjf6, X-Amz-Security-Token=AgoJb3JpZ2luX2VjEIT//////////wEaDmFwLXNvdXRoZWFzdC0yIkYwRAIgCkxUvmlK4pek5Kf9JdqmC1WAjCXPJxGxnQs/QqUZMTECIADU7x1dxGhWE8ksTe8cteV6L7oed/i0kgbXOMeagp8gKuQDCD0QARoMNzk4Mzc2MTEzODUzIgz2RnLXV0YHF+BRamEqwQPjDfrp6FsFpfLWnKy1AwzgMALKA3qYi0oJMbSCo7ZDDTA+S1UojEzp7cJ0BxIQJUzyWWj7X9jbrwQlhVWjzHg4jXMld/i23tGLcMFz+BhcchHdRu+uu5d9KDrWnIJsTSV0qnv85uOHCelj5O [TRUNCATED]
Thu Sep 05 04:56:39 UTC 2019 : Endpoint request body after transformations: {"type":"REQUEST","methodArn":"arn:aws:execute-api:ap-southeast-2:654888109795:ja8pdvfjf6/ESTestInvoke-stage/GET/","resource":"/","path":"/","httpMethod":"GET","headers":{"Authorizer":"bbbbbbbbbbbb","Hash":"aaaaaaaaaaaaaa"},"multiValueHeaders":{"Authorizer":["bbbbbbbbbbbb"],"Hash":["aaaaaaaaaaaaaa"]},"queryStringParameters":{},"multiValueQueryStringParameters":{},"pathParameters":{},"stageVariables":{},"requestContext":{"resourceId":"test-invoke-resource-id","resourcePath":"/","httpMethod":"GET","extendedRequestId":"fhxNLG5IywMFrSw=","requestTime":"05/Sep/2019:04:56:39 +0000","path":"/","accountId":"654888109795","protocol":"HTTP/1.1","stage":"test-invoke-stage","domainPrefix":"testPrefix","requestTimeEpoch":1567659399581,"requestId":"29d2b4df-26da-4cae-aeca-f9ef6c338d88","identity":{"cognitoIdentityPoolId":null,"cognitoIdentityId":null,"apiKey":"test-invoke-api-key","principalOrgId":null,"cognitoAuthenticationType":null,"userArn":"arn:aws:iam::654888109795:user/an [TRUNCATED]
Thu Sep 05 04:56:39 UTC 2019 : Sending request to https://lambda.ap-southeast-2.amazonaws.com/2015-03-31/functions/arn:aws:lambda:ap-southeast-2:654888109795:function:dev-HashMACSHM-Authorizer/invocations
Thu Sep 05 04:56:39 UTC 2019 : Unauthorized request: 29d2b4df-26da-4cae-aeca-f9ef6c338d88
Thu Sep 05 04:56:39 UTC 2019 : Unauthorized
```

**Step 2**: 

Nếu đã check ổn thỏa rồi thì, kiểm tra lại authorizer lambda, check log của nó, có thể là logic code bị sai