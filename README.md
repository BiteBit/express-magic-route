# express 4.x 路由魔法配置器

* 多URL配置
* API json schema 验证（Joi@6.10.1）
* 多中间件配置
express-magic-route

---

# 快速使用
```js
var express = require('express')
var magicRoute = require('express-magic-route')

var v1RouteConfig = require('./router/seedConfig')

var app = express()

app.use('/v1', magicRoute(v1RouteConfig))

```

# 配置文件参数
```js
url
    string                      单个url路径
    [string]                    多个url路径使用相同的处理方式

method
    string                      方法，默认get

middleware
    function(req, res, next)    单个中间件处理该url/[url]
    [function(req, res, next)]  多个中间件按照顺序处理url/[url]
   
schemaValidatePos               验证表单的schema req的属性
    string                      [query, body, params] 默认query

schema                          验证表单的schema
    function(req, joi)          joi数据验证，验证错误时返回http 400错误
                                验证失败时返回{error_no, error_desc}

enableCsruf                     是否启用 csruf cookie,需要先引入cookie-parser 
    boolean                     默认为true

disable                         是否停用路由
    boolean                     默认为false

errorCode
    number                      验证数据错误码，默认-10001
```

# 使用事例 seedConfig.js
```js
user = require('../middleware/user')

module.exports = [
  { // 登录时验证用户密码是否为空
    url: '/api/user/login'
    middleware: user.login
    schema: (req, Joi)->
      Joi.object({
        username: Joi.string().required()
        password: Joi.string().required()
      })
  }, {  // 登出时使用多中间件
    url: '/api/user/logout'
    middleware: [user.isValid, user.logout]
  }, {  // 多个url支持获取登录用户信息
    url: ['/api/user/profile', '/api/user/info']
    middleware: [user.isValid, user.get]
  }
]

```

# 错误格式化
```js
var magicRoute = require('express-magic-route')

默认返回格式
{
  error_no: -100001
  error_desc: ''
}

// 可自己定制错误格式
magicRoute.ErrorFormater = function (code, error) {
  return code + error.desc
}

错误信息格式化
code: 默认错误代码
error: Joi错误对象
```

