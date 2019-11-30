<#include "/abstracted/common.ftl">
import Mock from 'mockjs'
import { paging, copy } from './mock-util'

/**
 * mock列表数据
 */
const data = Mock.mock({
  'list|40': [{
    'id|+1': 1,
    name: '@cword(4, 10)'
  }]
})

/**
 * 新的id生成规则
 */
const mockNewIdRule = {
  'id|+1': 40
}

const urlWithIdPattern = /\/api\/role\/(\d+)/

function removeById(list, id) {
  const index = list.findIndex(item => item.id === id)
  list.splice(index, 1)
}

export default [
  {
    url: urlWithIdPattern,
    type: 'get',
    response: ({ url }) => {
      const id = url.match(urlWithIdPattern)[1]
      const obj = data.list.find(item => item.id === parseInt(id))
      return copy(obj)
    }
  },
  {
    url: `/api/role`,
    type: 'get',
    response: ({ query }) => {
      // 列表过滤
      let list = data.list.filter(item => {
        if (query.name && item.name.indexOf(query.name) < 0) {
          return false
        }
        return true
      })
      // 列表排序
      if (query.idSortNo) {
        list = copy(list).sort((item1, item2) => {
          if (query.idSortNo) {
            const dif = item1.id - item2.id
            return query.idSortNo > 0 ? dif : -dif
          }
          return 0
        })
      }
      // 列表分页
      const page = paging(list, query)
      return {
        total: list.length,
        list: copy(page)
      }
    }
  },
  {
    url: `/api/role`,
    type: 'post',
    response: ({ body }) => {
      body.id = Mock.mock(mockNewIdRule).id
      data.list.push(body)
      return copy(body)
    }
  },
  {
    url: `/api/role`,
    type: 'put',
    response: ({ body }) => {
      const obj = data.list.find(item => item.id === body.id)
      Object.assign(obj, body)
      return copy(obj)
    }
  },
  {
    url: urlWithIdPattern,
    type: 'delete',
    response: ({ url }) => {
      const id = url.match(urlWithIdPattern)[1]
      removeById(data.list, parseInt(id))
      return 1
    }
  },
  {
    url: `/api/role`,
    type: 'delete',
    response: ({ body }) => {
      for (var id of body) {
        removeById(data.list, id)
      }
      return body.length
    }
  }
]
