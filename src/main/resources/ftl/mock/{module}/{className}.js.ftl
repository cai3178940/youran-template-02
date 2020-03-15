<#include "/abstracted/common.ftl">
<#include "/abstracted/table.ftl">
<#include "/abstracted/mtmCascadeExtsForShow.ftl">
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
    <#elseIf field.jfieldType == JFieldType.DATE.javaType
        || field.jfieldType == JFieldType.LOCALDATE.javaType
        || field.jfieldType == JFieldType.LOCALDATETIME.javaType>
        <#if field.editType == EditType.DATE.getValue()>
      '${name}': '@date(yyyy-MM-dd)',
        <#else>
      '${name}': '@date(yyyy-MM-dd) 00:00:00',
        </#if>
    <#else>
      '${name}': '@word(1, ${[field.fieldLength, 10]?min})',
    </#if>
</#macro>
import Mock from 'mockjs'
import { <#if this.pageSign>paging, </#if>copy, getUrlPattern } from '${getParentPathForModule(this.metaEntity)}/mock-util'
<#-- 引入依赖的其他mock -->
<#list this.holds! as otherEntity,mtm>
${importMock(getParentPathForModule(this.metaEntity), otherEntity)}
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
        <#assign othercName=lowerFirstWord(otherEntity.className)>
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
  '${this.id}|+1': 21
}

</#if>
<#if this.entityFeature.delete || this.entityFeature.deleteBatch>
function removeById(list, ${this.id}) {
  const index = list.findIndex(item => item.${this.id} === ${this.id})
  list.splice(index, 1)
}

</#if>
<#if this.module?hasContent>
const modulePath = '${this.module}/${this.classNameLower}'
<#else>
const modulePath = '${this.classNameLower}'
</#if>
const reqMocks = [
<@removeLastComma>
    <#if this.entityFeature.save>
  // 添加【${this.title}】
  {
    url: getUrlPattern(modulePath, false),
    type: 'post',
    response: ({ body }) => {
      body.${this.id} = Mock.mock(mockNewIdRule).${this.id}
      data.list.push(body)
      return copy(body)
    }
  },
    </#if>
    <#if this.entityFeature.update>
  // 修改【${this.title}】
  {
    url: getUrlPattern(modulePath, false),
    type: 'put',
    response: ({ body }) => {
      const obj = data.list.find(item => item.${this.id} === body.${this.id})
      Object.assign(obj, body)
      return copy(obj)
    }
  },
    </#if>
    <#if this.entityFeature.list>
  // ${this.pageSign?string('分页','列表')}查询【${this.title}】
  {
    url: getUrlPattern(modulePath, false),
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
    <#if this.titleField??>
  // 查询【${this.title}】选项列表
  {
    url: getUrlPattern(modulePath, false, 'options'),
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
  // 查看【${this.title}】详情
  {
    url: getUrlPattern(modulePath, true),
    type: 'get',
    response: ({ url }) => {
      const ${this.id} = url.match(getUrlPattern(modulePath, true))[1]
      const obj = data.list.find(item => item.${this.id} === parseInt(${this.id}))
      return copy(obj)
    }
  },
    </#if>
    <#if this.entityFeature.delete>
  // 删除单个【${this.title}】
  {
    url: getUrlPattern(modulePath, true),
    type: 'delete',
    response: ({ url }) => {
      const ${this.id} = url.match(getUrlPattern(modulePath, true))[1]
      removeById(data.list, parseInt(${this.id}))
      return 1
    }
  },
    </#if>
    <#if this.entityFeature.deleteBatch>
  // 批量删除【${this.title}】
  {
    url: getUrlPattern(modulePath, false),
    type: 'delete',
    response: ({ body }) => {
      for (var ${this.id} of body) {
        removeById(data.list, ${this.id})
      }
      return body.length
    }
  },
    </#if>
    <#list this.holds! as otherEntity,mtm>
        <#assign otherCName=otherEntity.className>
        <#assign othercName=lowerFirstWord(otherEntity.className)>
        <#assign otherId=otherEntity.pkField.jfieldName>
        <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
        <#if entityFeature.addRemove || entityFeature.set>
            <#assign index=getMtmCascadeEntityIndexForShow(otherEntity.entityId)>
            <#assign justReturnOtherId=true>
            <#if entityFeature.addRemove || index &gt; -1>
                <#assign justReturnOtherId=false>
            </#if>
  // 获取【${otherEntity.title}】关联
  {
    url: getUrlPattern(modulePath, true, '${othercName}'),
    type: 'get',
    response: ({ url }) => {
      const ${this.id} = url.match(getUrlPattern(modulePath, true, '${othercName}'))[1]
      const obj = data.list.find(item => item.${this.id} === parseInt(${this.id}))
            <#if justReturnOtherId>
      return copy(obj.${othercName}List.map(item => item.${otherId}))
            <#else>
      return copy(obj.${othercName}List)
            </#if>
    }
  },
        </#if>
        <#if entityFeature.addRemove>
  // 添加【${otherEntity.title}】关联
  {
    url: getUrlPattern(modulePath, true, '${othercName}'),
    type: 'post',
    response: ({ url, body }) => {
      const ${this.id} = url.match(getUrlPattern(modulePath, true, '${othercName}'))[1]
      const obj = data.list.find(item => item.${this.id} === parseInt(${this.id}))
      ${othercName}.getMockData().list
        // 过滤出需要添加的
        .filter(i => body.findIndex(j => j === i.${otherId}) > -1)
        // 过滤掉之前已经存在的
        .filter(i => obj.${othercName}List.findIndex(j => j === i) < 0)
        .forEach(i => obj.${othercName}List.push(i))
      return body.length
    }
  },
  // 移除【${otherEntity.title}】关联
  {
    url: getUrlPattern(modulePath, true, '${othercName}'),
    type: 'delete',
    response: ({ url, body }) => {
      const ${this.id} = url.match(getUrlPattern(modulePath, true, '${othercName}'))[1]
      const obj = data.list.find(item => item.${this.id} === parseInt(${this.id}))
      body.forEach(i => {
        const index = obj.${othercName}List.findIndex(j => j.${otherId} === i)
        if (index > -1) {
          obj.${othercName}List.splice(index, 1)
        }
      })
      return body.length
    }
  },
        <#elseIf entityFeature.set>
  // 设置【${otherEntity.title}】关联
  {
    url: getUrlPattern(modulePath, true, '${othercName}'),
    type: 'put',
    response: ({ url, body }) => {
      const ${this.id} = url.match(getUrlPattern(modulePath, true, '${othercName}'))[1]
      const obj = data.list.find(item => item.${this.id} === parseInt(${this.id}))
      const ${othercName}List = ${othercName}.getMockData().list
        .filter(i => body.findIndex(j => j === i.${otherId}) > -1)
      obj.${othercName}List = ${othercName}List
      return body.length
    }
  },
        </#if>
    </#list>
</@removeLastComma>
]

export default {
  initMockDataStage1,
  initMockDataStage2,
  reqMocks,
  getMockData
}
