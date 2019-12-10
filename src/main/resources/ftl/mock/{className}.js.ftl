<#include "/abstracted/common.ftl">
<#include "/abstracted/table.ftl">
<#-- 输出常规字段mock表达式 -->
<#macro mockGeneralField field alias>
    <#local name = alias?hasContent?string(alias,field.jfieldName)/>
    <#-- 枚举的情况 -->
    <#if field.dicType??>
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
      '${name}|1': true,
    <#elseIf field.jfieldType == JFieldType.INTEGER.javaType
              || field.jfieldType == JFieldType.SHORT.javaType
              || field.jfieldType == JFieldType.LONG.javaType>
      '${name}|0-100': 1,
    <#elseIf field.jfieldType == JFieldType.DOUBLE.javaType
              || field.jfieldType == JFieldType.FLOAT.javaType
              || field.jfieldType == JFieldType.BIGDECIMAL.javaType>
      '${name}|0-100.1-2': 1,
    <#elseIf field.jfieldType == JFieldType.DATE.javaType>
      '${name}': '@date(yyyy-MM-dd) 00:00:00',
    <#else>
      '${name}': '@word(1, ${[field.fieldLength, 10]?min})',
    </#if>
</#macro>
import Mock from 'mockjs'
import { <#if this.pageSign>paging, </#if>copy } from './mock-util'
<#-- 引入依赖的其他mock -->
<#list this.holds! as otherEntity,mtm>
    <#assign othercName=otherEntity.className?uncapFirst>
import ${othercName} from './${othercName}'
</#list>

/**
 * mock数据缓存
 */
let data = null

/**
 * 获取mock数据缓存
 */
function getMockData() {
  return data
}

/**
 * 初始化mock数据阶段1
 */
function initMockDataStage1() {
  data = Mock.mock({
    'list|20': [{
<@removeLastComma>
    <#list this.fields as id,field>
        <#-- 跳过既不是列表展示，也不是详情展示的字段 -->
        <#if !field.list && !field.show>
            <#continue>
        </#if>
        <#-- 主键的情况 -->
        <#if field.primaryKey>
      '${field.jfieldName}|+1': 1,
        <#-- 外键的情况 -->
        <#elseIf field.foreignKey>
      '${field.jfieldName}|1-20': 1,
        <#-- 常规情况 -->
        <#else>
            <@mockGeneralField field ""/>
        </#if>
    </#list>
    <#-- mock 外键级联扩展字段 -->
    <#list this.fkFields as id,field>
        <#list field.cascadeExts! as cascadeExt>
            <#if cascadeExt.show || cascadeExt.list>
                <@mockGeneralField cascadeExt.cascadeField cascadeExt.alias/>
            </#if>
        </#list>
    </#list>
</@removeLastComma>
    }]
  })
}

/**
 * 初始化mock数据阶段2
 */
function initMockDataStage2() {
<#-- 初始化多对多关联 -->
<#if this.holds!?hasContent>
  for (const item of data.list) {
    <#list this.holds! as otherEntity,mtm>
        <#assign othercName=otherEntity.className?uncapFirst>
    item.${othercName}List = [Mock.Random.pick(${othercName}.getMockData().list)]
    </#list>
  }
</#if>
}

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

const reqMocks = [
<@removeLastComma>
    <#if this.titleField??>
  {
    url: `/api/${this.className}/options`,
    type: 'get',
    response: () => {
      return data.list.map(item => ({
        key: item.${this.id},
        value: item.${this.titleField.jfieldName}
      }))
    }
  },
    </#if>
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

export default {
  initMockDataStage1,
  initMockDataStage2,
  reqMocks,
  getMockData
}
