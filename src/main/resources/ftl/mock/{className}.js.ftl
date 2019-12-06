<#include "/abstracted/common.ftl">
<#include "/abstracted/table.ftl">
import Mock from 'mockjs'
import { <#if this.pageSign>paging, </#if>copy } from './mock-util'

/**
 * mock列表数据
 */
const data = Mock.mock({
  'list|20': [{
<@removeLastComma>
    <#list this.listFields as id,field>
        <#if field.primaryKey>
    '${field.jfieldName}|+1': 1,
        <#elseIf field.dicType??>
            <#assign const = findConst(field.dicType)>
    '${field.jfieldName}|1': [
            <@removeLastComma>
                <#list const.detailList as detail>
                    <#if const.constType==MetaConstType.INTEGER>
      ${detail.detailValue},
                    <#elseIf const.constType==MetaConstType.STRING>
      '${detail.detailValue}',
                    </#if>
                </#list>
            </@removeLastComma>
    ],
        <#elseIf field.jfieldType == JFieldType.BOOLEAN.javaType>
    '${field.jfieldName}|1': true,
        <#elseIf field.jfieldType == JFieldType.INTEGER.javaType
              || field.jfieldType == JFieldType.SHORT.javaType
              || field.jfieldType == JFieldType.LONG.javaType>
    '${field.jfieldName}|0-100': 1,
        <#elseIf field.jfieldType == JFieldType.DOUBLE.javaType
              || field.jfieldType == JFieldType.FLOAT.javaType
              || field.jfieldType == JFieldType.BIGDECIMAL.javaType>
    '${field.jfieldName}|0-100.1-2': 1,
        <#elseIf field.jfieldType == JFieldType.DATE.javaType>
    '${field.jfieldName}': '@date(yyyy-MM-dd) 00:00:00',
        <#else>
    '${field.jfieldName}': '@cword(1, ${field.fieldLength})',
        </#if>
    </#list>
</@removeLastComma>
  }]
})

<#if this.entityFeature.save>
/**
 * 新的id生成规则
 */
const mockNewIdRule = {
  '${this.id}|+1': 20
}
</#if>

const urlWithIdPattern = /\/api\/${this.className}\/(\d+)/

function removeById(list, ${this.id}) {
  const index = list.findIndex(item => item.${this.id} === ${this.id})
  list.splice(index, 1)
}

export default [
<@removeLastComma>
    <#if this.entityFeature.show>
  {
    url: urlWithIdPattern,
    type: 'get',
    response: ({ url }) => {
      const ${this.id} = url.match(urlWithIdPattern)[1]
      const obj = data.list.find(item => item.${this.id} === parseInt(${this.id}))
      return copy(obj)
    }
  },
    </#if>
    <#if this.entityFeature.list>
  {
    url: `/api/${this.className}`,
    type: 'get',
    response: ({ query }) => {
        <#if this.pageSign>
      // 列表分页
      const page = paging(data.list, query.page, query.limit)
      return {
        total: data.list.length,
        list: copy(page)
      }
        <#else>
      return copy(data.list)
        </#if>
    }
  },
    </#if>
    <#if this.entityFeature.save>
  {
    url: `/api/${this.className}`,
    type: 'post',
    response: ({ body }) => {
      body.${this.id} = Mock.mock(mockNewIdRule).${this.id}
      data.list.push(body)
      return copy(body)
    }
  },
    </#if>
    <#if this.entityFeature.update>
  {
    url: `/api/${this.className}`,
    type: 'put',
    response: ({ body }) => {
      const obj = data.list.find(item => item.${this.id} === body.${this.id})
      Object.assign(obj, body)
      return copy(obj)
    }
  },
    </#if>
    <#if this.entityFeature.delete>
  {
    url: urlWithIdPattern,
    type: 'delete',
    response: ({ url }) => {
      const ${this.id} = url.match(urlWithIdPattern)[1]
      removeById(data.list, parseInt(${this.id}))
      return 1
    }
  },
    </#if>
    <#if this.entityFeature.deleteBatch>
  {
    url: `/api/${this.className}`,
    type: 'delete',
    response: ({ body }) => {
      for (var ${this.id} of body) {
        removeById(data.list, ${this.id})
      }
      return body.length
    }
  },
    </#if>
</@removeLastComma>
]
