<#include "/abstracted/common.ftl">
<#include "/abstracted/table.ftl">
<#if !this.entityFeature.list>
    <@call this.skipCurrent()/>
</#if>
<template>
  <div class="app-container">
    <div class="filter-container">
<#-- 把渲染搜索字段的逻辑抽象出来 -->
<#macro displayQueryField field alias>
    <#local name = alias?hasContent?string(alias,field.jfieldName)/>
    <#-- 首先考虑外键的情况 -->
    <#if field.foreignKey>
        <@justCall importforeignEntitys.add(field.foreignEntity)/>
        <#assign foreignClassName = field.foreignEntity.className?uncapFirst>
      <el-select v-model="query.${name}" class="filter-item"
                 style="width:200px;" placeholder="${field.fieldDesc}"
                 filterable clearable>
        <el-option v-for="item in options.${foreignClassName}"
                   :key="item.key"
                   :label="item.value"
                   :value="item.key">
        </el-option>
      </el-select>
    <#-- 其次考虑枚举的情况 -->
    <#elseIf field.dicType??>
        <#assign const = findConst(field.dicType)>
        <@justCall importEnums.add(const)/>
        <#assign constName = const.constName?uncapFirst>
      <el-select v-model="query.${name}" class="filter-item"
                 style="width:200px;" placeholder="${field.fieldDesc}"
                 filterable clearable>
        <el-option v-for="item in enums.${constName}"
                   :key="item.value"
                   :label="item.label"
                   :value="item.value">
        </el-option>
      </el-select>
    <#-- 非Between查询条件 -->
    <#elseIf !QueryType.isBetween(field.queryType)>
        <#if field.editType == EditType.NUMBER.getValue()>
      <el-input-number v-model="query.${name}" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"
                       style="width:200px;" class="filter-item"
                       controls-position="right"></el-input-number>
        <#elseIf field.editType == EditType.DATE.getValue()>
      <el-date-picker v-model="query.${name}" type="date"
                      style="width:200px;" class="filter-item"
                      value-format="yyyy-MM-dd HH:mm:ss"
                      placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"></el-date-picker>
        <#elseIf field.editType == EditType.DATETIME.getValue()>
      <el-date-picker v-model="query.${name}" type="datetime"
                      style="width:200px;" class="filter-item"
                      value-format="yyyy-MM-dd HH:mm:ss"
                      placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"></el-date-picker>
        <#elseIf field.jfieldType == JFieldType.BOOLEAN.javaType>
      <el-select v-model="query.${name}" class="filter-item"
                 style="width:200px;" placeholder="${field.fieldDesc}"
                 clearable>
        <el-option label="是" :value="true"></el-option>
        <el-option label="否" :value="false"></el-option>
      </el-select>
        <#else>
      <el-input v-model="query.${name}" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"
                style="width: 200px;" class="filter-item"
                @keyup.enter.native="handleQuery"/>
        </#if>
    <#-- 最后考虑Between查询条件 -->
    <#else>
        <#if field.jfieldType == JFieldType.DATE.javaType>
      <el-date-picker v-model="query.${name}Start"
            <#if field.editType == EditType.DATE.getValue()>
                      type="date"
            <#else>
                      type="datetime"
            </#if>
                      style="width:200px;" class="filter-item"
                      value-format="yyyy-MM-dd HH:mm:ss"
                      placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,true)}"></el-date-picker>
      <el-date-picker v-model="query.${name}End"
            <#if field.editType == EditType.DATE.getValue()>
                      type="date"
            <#else>
                      type="datetime"
            </#if>
                      style="width:200px;" class="filter-item"
                      value-format="yyyy-MM-dd HH:mm:ss"
                      placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"></el-date-picker>
        <#elseIf field.editType == EditType.NUMBER.getValue()>
      <el-input-number v-model="query.${name}Start" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,true)}"
                       style="width:200px;" class="filter-item"
                       controls-position="right"></el-input-number>
      <el-input-number v-model="query.${name}End" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"
                       style="width:200px;" class="filter-item"
                       controls-position="right"></el-input-number>
        <#else>
      <el-input v-model="query.${name}Start" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,true)}"
                style="width: 200px;" class="filter-item"
                @keyup.enter.native="handleQuery"/>
      <el-input v-model="query.${name}End" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"
                style="width: 200px;" class="filter-item"
                @keyup.enter.native="handleQuery"/>
        </#if>
    </#if>
</#macro>
<#assign hasQueryField = false>
<#--渲染查询输入框-->
<#list this.queryFields as id,field>
    <#assign hasQueryField = true>
    <@displayQueryField field ""/>
</#list>
<#-- 外键级联扩展字段 -->
<#list this.fkFields as id,field>
    <#list field.cascadeQueryExts! as cascadeExt>
        <#assign hasQueryField = true>
        <@displayQueryField cascadeExt.cascadeField cascadeExt.alias/>
    </#list>
</#list>
<#if hasQueryField>
      <el-button class="filter-item" icon="el-icon-search" type="primary"
                 @click="handleQuery">
        搜索
      </el-button>
</#if>
<#if this.entityFeature.save>
      <el-button class="filter-item" style="margin-left: 10px;" type="success"
                 icon="el-icon-edit" @click="handleCreate">
        新建
      </el-button>
</#if>
<#if this.entityFeature.deleteBatch>
      <el-button class="filter-item" style="margin-left: 10px;" type="danger"
                 icon="el-icon-delete" @click="handleDeleteBatch">
        删除
      </el-button>
</#if>
    </div>

    <el-table v-loading="listLoading" :data="list"
<#if tableSelect>
              @selection-change="selectionChange"
</#if>
<#if tableSort>
              @sort-change="sortChange"
</#if>
              border style="width: 100%;">
<#if tableSelect>
      <el-table-column type="selection" width="50" />
</#if>
<#-- 把渲染字段的逻辑抽象出来 -->
<#macro displayTableColumn field alias>
    <#-- 不渲染外键字段 -->
    <#if field.foreignKey><#return></#if>
    <#local name = alias?hasContent?string(alias,field.jfieldName)/>
      <el-table-column label="${field.fieldDesc}"
                       prop="${name}"
    <#if !(alias?hasContent) && field.listSort>
                       sortable="custom"
    </#if>
                       align="center"<#if field.columnWidth?? && field.columnWidth &gt; 0> width="${field.columnWidth}"</#if>>
        <template slot-scope="{row}">
    <#-- 枚举字段特殊处理 -->
    <#if field.dicType??>
        <#assign const = findConst(field.dicType)>
        <@justCall importEnums.add(const)/>
        <#assign constName = const.constName?uncapFirst>
          <span>{{ row.${name} | findEnumLabel(enums.${constName}) }}</span>
    <#-- 普通字段直接展示 -->
    <#else>
          <span>{{ row.${name} }}</span>
    </#if>
        </template>
      </el-table-column>
</#macro>
<#-- 列表字段 -->
<#list this.listFields as id,field>
      <@displayTableColumn field ""/>
</#list>
<#-- 外键级联扩展字段 -->
<#list this.fkFields as id,field>
    <#list field.cascadeListExts! as cascadeExt>
        <@displayTableColumn cascadeExt.cascadeField cascadeExt.alias/>
    </#list>
</#list>
<#if tableOperate>
      <el-table-column label="操作" align="center" width="230"
                       class-name="small-padding fixed-width">
        <template slot-scope="{row}">
    <#if this.entityFeature.show>
          <el-button size="mini" @click="handleShow(row)">
            查看
          </el-button>
    </#if>
    <#if this.entityFeature.update>
          <el-button type="primary" size="mini" @click="handleUpdate(row)">
            编辑
          </el-button>
    </#if>
    <#if this.entityFeature.delete>
          <el-button type="danger" size="mini" @click="handleDeleteSingle(row)">
            删除
          </el-button>
    </#if>
        </template>
      </el-table-column>
</#if>
    </el-table>
<#if this.pageSign>
    <pagination v-show="total>0" :total="total" :page.sync="query.page"
                :limit.sync="query.limit" @pagination="doQueryList"/>
</#if>
<#if this.entityFeature.save>
    <!-- 新建表单 -->
    <${this.className}-add ref="${this.className}Add" @created="doQueryList({<#if this.pageSign> page: 1 </#if>})"/>
</#if>
<#if this.entityFeature.update>
    <!-- 编辑表单 -->
    <${this.className}-edit ref="${this.className}Edit" @updated="doQueryList({})"/>
</#if>
<#if this.entityFeature.show>
    <!-- 查看表单 -->
    <${this.className}-show ref="${this.className}Show"/>
</#if>
  </div>
</template>

<script>
<#if this.entityFeature.save>
import ${this.className}Add from './add'
</#if>
<#if this.entityFeature.update>
import ${this.className}Edit from './edit'
</#if>
<#if this.entityFeature.show>
import ${this.className}Show from './show'
</#if>
import ${this.className}Api from '@/api/${this.className}'
<#if !importforeignEntitys.isEmpty()>
    <#list importforeignEntitys as foreignEntity>
        <#assign foreignClassName = foreignEntity.className?uncapFirst>
import ${foreignClassName}Api from '@/api/${foreignClassName}'
    </#list>
</#if>
<#if !importEnums.isEmpty()>
import enums from '@/utils/enums'
</#if>
<#if this.pageSign>
import Pagination from '@/components/Pagination'
</#if>

export default {
  name: '${this.classNameUpper}Table',
  components: {
<@removeLastComma>
    <#if this.pageSign>
    Pagination,
    </#if>
    <#if this.entityFeature.save>
    ${this.className}Add,
    </#if>
    <#if this.entityFeature.update>
    ${this.className}Edit,
    </#if>
    <#if this.entityFeature.show>
    ${this.className}Show,
    </#if>
</@removeLastComma>
  },
<#if !importEnums.isEmpty()>
  filters: {
    findEnumLabel: enums.findEnumLabel
  },
</#if>
  data() {
    return {
<#if !importEnums.isEmpty()>
      enums: {
    <@removeLastComma>
        <#list importEnums as const>
        ${const.constName?uncapFirst}: enums.get${const.constName}(),
        </#list>
    </@removeLastComma>
      },
</#if>
<#if !importforeignEntitys.isEmpty()>
      options: {
    <@removeLastComma>
        <#list importforeignEntitys as foreignEntity>
        ${foreignEntity.className?uncapFirst}: [],
        </#list>
    </@removeLastComma>
      },
</#if>
<@removeLastComma>
      list: [],
      total: 0,
      listLoading: true,
      query: {
    <@removeLastComma>
        <#if this.pageSign>
        page: 1,
        limit: 10,
        </#if>
        <#list this.queryFields as id,field>
            <#if !QueryType.isBetween(field.queryType)>
        ${field.jfieldName}: ${getFieldEmptyValue(field)},
            <#else>
        ${field.jfieldName}Start: ${getFieldEmptyValue(field)},
        ${field.jfieldName}End: ${getFieldEmptyValue(field)},
            </#if>
        </#list>
        <#list this.listSortFields as id,field>
        ${field.jfieldName}SortSign: 0,
        </#list>
    </@removeLastComma>
      },
    <#if tableSelect>
      selectItems: [],
    </#if>
</@removeLastComma>
    }
  },
  created() {
    this.doQueryList(<#if this.pageSign>{ page: 1 }</#if>)
<#if !importforeignEntitys.isEmpty()>
    <@removeLastComma>
        <#list importforeignEntitys as foreignEntity>
            <#assign foreignClassName = foreignEntity.className?uncapFirst>
    ${foreignClassName}Api.findOptions().then(data => { this.options.${foreignClassName} = data })
        </#list>
    </@removeLastComma>
</#if>
  },
  methods: {
<@removeLastComma>
    <#if tableSelect>
    /**
     * 选择框变化
     */
    selectionChange(val) {
      this.selectItems = val
    },
    </#if>
    <#if tableSort>
    /**
     * 触发后端排序
     */
    sortChange({ prop, order }) {
      const sortKeyMap = {
        <@removeLastComma>
            <#list this.listSortFields as id,field>
        '${field.jfieldName}': '${field.jfieldName}SortSign',
            </#list>
        </@removeLastComma>
      }
      for (var k in sortKeyMap) {
        const sortKey = sortKeyMap[k]
        if (k !== prop) {
          this.query[sortKey] = null
        } else {
          if (order === 'ascending') {
            this.query[sortKey] = 1
          } else {
            this.query[sortKey] = -1
          }
        }
      }
      this.doQueryList({})
    },
    </#if>
    /**
     * 触发搜索操作
     */
    handleQuery() {
      this.doQueryList(<#if this.pageSign>{ page: 1 }</#if>)
    },
    /**
     * 执行列表查询
     */
    doQueryList(<#if this.pageSign>{ page, limit }</#if>) {
    <#if this.pageSign>
      if (page) {
        this.query.page = page
      }
      if (limit) {
        this.query.limit = limit
      }
    </#if>
      this.listLoading = true
      return ${this.className}Api.fetchList(this.query)
        .then(data => {
    <#if this.pageSign>
          this.list = data.list
          this.total = data.total
    <#else>
          this.list = data
    </#if>
        })
        .finally(() => {
          this.listLoading = false
        })
    },
    <#if this.entityFeature.delete>
    /**
     * 删除单条记录
     */
    handleDeleteSingle(row) {
      return this.$common.confirm('是否确认删除')
        .then(() => ${this.className}Api.deleteById(row.${this.id}))
        .then(() => {
          this.$common.showMsg('success', '删除成功')
          return this.doQueryList(<#if this.pageSign>{ page: 1 }</#if>)
        })
    },
    </#if>
    <#if this.entityFeature.deleteBatch>
    /**
     * 批量删除记录
     */
    handleDeleteBatch() {
      if (this.selectItems.length <= 0) {
        this.$common.showMsg('warning', '请选择${this.title}')
        return
      }
      return this.$common.confirm('是否确认删除')
        .then(() => ${this.className}Api.deleteBatch(this.selectItems.map(row => row.${this.id})))
        .then(() => {
          this.$common.showMsg('success', '删除成功')
          return this.doQueryList(<#if this.pageSign>{ page: 1 }</#if>)
        })
    },
    </#if>
    <#if this.entityFeature.save>
    /**
     * 打开新建表单
     */
    handleCreate() {
      this.$refs.${this.className}Add.handleCreate()
    },
    </#if>
    <#if this.entityFeature.save>
    /**
     * 打开查看表单
     */
    handleShow(row) {
      this.$refs.${this.className}Show.handleShow(row.${this.id})
    },
    </#if>
    <#if this.entityFeature.save>
    /**
     * 打开编辑表单
     */
    handleUpdate(row) {
      this.$refs.${this.className}Edit.handleUpdate(row.${this.id})
    },
    </#if>
</@removeLastComma>
  }
}
</script>
