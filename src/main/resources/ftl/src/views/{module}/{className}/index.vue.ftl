<#include "/abstracted/common.ftl">
<#include "/abstracted/table.ftl">
<#include "/abstracted/mtmCascadeExtsForQuery.ftl">
<#include "/abstracted/mtmCascadeExtsForList.ftl">
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
        <@justCall importOtherEntitys.add(field.foreignEntity)/>
        <#assign foreignClassName = lowerFirstWord(field.foreignEntity.className)>
      <el-select v-model="query.${name}" class="filter-item"
                 style="width:200px;" placeholder="${field.fieldDesc}"
                 filterable clearable<#if QueryType.isIn(field.queryType)> multiple</#if>>
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
                 filterable clearable<#if QueryType.isIn(field.queryType)> multiple</#if>>
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
                      value-format="yyyy-MM-dd"
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
        <#if field.jfieldType == JFieldType.DATE.javaType
        || field.jfieldType == JFieldType.LOCALDATE.javaType
        || field.jfieldType == JFieldType.LOCALDATETIME.javaType>
      <el-date-picker v-model="query.${name}Start"
            <#if field.editType == EditType.DATE.getValue()>
                      type="date"
                      value-format="yyyy-MM-dd"
            <#else>
                      type="datetime"
                      value-format="yyyy-MM-dd HH:mm:ss"
            </#if>
                      style="width:200px;" class="filter-item"
                      placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,true)}"></el-date-picker>
      <el-date-picker v-model="query.${name}End"
            <#if field.editType == EditType.DATE.getValue()>
                      type="date"
                      value-format="yyyy-MM-dd"
            <#else>
                      type="datetime"
                      value-format="yyyy-MM-dd HH:mm:ss"
            </#if>
                      style="width:200px;" class="filter-item"
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
<#--开始渲染【外键级联扩展】字段 -->
<#list this.fkFields as id,field>
    <#list field.cascadeQueryExts! as cascadeExt>
        <#assign hasQueryField = true>
        <@displayQueryField cascadeExt.cascadeField cascadeExt.alias/>
    </#list>
</#list>
<#--开始渲染【多对多级联扩展】字段-->
<#list mtmCascadeExtsForQuery as mtmCascadeExt>
    <#assign hasQueryField = true>
    <@displayQueryField mtmCascadeExt.cascadeField mtmCascadeExt.alias/>
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
<#if this.entityFeature.excelExport>
      <el-button class="filter-item" icon="el-icon-download" type="warning"
                 @click="handleExport">
        导出
      </el-button>
</#if>
<#if this.entityFeature.excelImport>
      <el-button class="filter-item" icon="el-icon-upload2" type="success"
                 @click="handleImport">
        导入
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
              border stripe style="width: 100%;">
<#if tableSelect>
      <el-table-column type="selection" width="50" />
</#if>
<#-- 把渲染字段的逻辑抽象出来 -->
<#macro displayTableColumn field alias>
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
<#--多对多级联扩展列表展示-->
<#list mtmCascadeEntitiesForList as otherEntity>
    <#assign otherPkField = otherEntity.pkField>
    <#assign mtmCascadeExts = groupMtmCascadeExtsForList[otherEntity?index]>
    <#--级联扩展列表字段中，如果有标题字段，则使用标题字段展示，否则直接展示主键字段-->
    <#if hasTitleField(otherEntity,mtmCascadeExts)>
        <#assign displayField = otherEntity.titleField>
    <#else>
        <#assign displayField = otherPkField>
    </#if>
    <#assign othercName=lowerFirstWord(otherEntity.className)>
      <el-table-column label="${otherEntity.title}" align="center">
        <template slot-scope="{row}">
          <span v-for="item in row.${othercName}List"
                :key="item.${otherPkField.jfieldName}"
                class="table-inner-mtm">
            {{ item.${displayField.jfieldName} }}
          </span>
        </template>
      </el-table-column>
</#list>
<#if tableOperate>
      <el-table-column label="操作" align="center" width="230">
        <template slot-scope="{row}">
    <#if this.entityFeature.show>
          <el-button size="mini"
                     @click="handleShow(row)" class="table-inner-button">查看</el-button>
    </#if>
    <#if this.entityFeature.update>
          <el-button type="primary" size="mini"
                     @click="handleUpdate(row)" class="table-inner-button">编辑</el-button>
    </#if>
    <#if this.entityFeature.delete>
          <el-button type="danger" size="mini"
                     @click="handleDeleteSingle(row)" class="table-inner-button">删除</el-button>
    </#if>
    <#list this.holds! as otherEntity,mtm>
        <#assign otherCName=otherEntity.className>
        <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
        <#if entityFeature.addRemove>
          <el-button type="success" size="mini"
                     @click="handle${otherCName}AddRemove(row)" class="table-inner-button">配置${otherEntity.title}</el-button>
        <#elseIf entityFeature.set>
          <el-button type="success" size="mini"
                     @click="handle${otherCName}Setting(row)" class="table-inner-button">配置${otherEntity.title}</el-button>
        </#if>
    </#list>
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
    <${this.classNameLower}-add ref="${this.classNameLower}Add" @created="doQueryList({<#if this.pageSign> page: 1 </#if>})"/>
</#if>
<#if this.entityFeature.update>
    <!-- 编辑表单 -->
    <${this.classNameLower}-edit ref="${this.classNameLower}Edit" @updated="doQueryList({})"/>
</#if>
<#if this.entityFeature.show>
    <!-- 查看表单 -->
    <${this.classNameLower}-show ref="${this.classNameLower}Show"/>
</#if>
<#list this.holds! as otherEntity,mtm>
    <#assign othercName=lowerFirstWord(otherEntity.className)>
    <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
    <#if entityFeature.addRemove>
    <!-- 添加移除${otherEntity.title} -->
    <${othercName}-add-remove ref="${othercName}AddRemove" @updated="doQueryList({})"/>
    <#elseIf entityFeature.set>
    <!-- 设置${otherEntity.title} -->
    <${othercName}-setting ref="${othercName}Setting" @updated="doQueryList({})"/>
    </#if>
</#list>
<#if this.entityFeature.excelImport>
    <!-- 查看表单 -->
    <${this.classNameLower}-import ref="${this.classNameLower}Import" @imported="doQueryList({<#if this.pageSign> page: 1 </#if>})"/>
</#if>
  </div>
</template>

<script>
<#if this.entityFeature.save>
import ${this.classNameLower}Add from './add'
</#if>
<#if this.entityFeature.update>
import ${this.classNameLower}Edit from './edit'
</#if>
<#if this.entityFeature.show>
import ${this.classNameLower}Show from './show'
</#if>
<#list this.holds! as otherEntity,mtm>
    <#assign othercName=lowerFirstWord(otherEntity.className)>
    <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
    <#if entityFeature.addRemove>
import ${othercName}AddRemove from './${othercName}AddRemove'
    <#elseIf entityFeature.set>
import ${othercName}Setting from './${othercName}Setting'
    </#if>
</#list>
<#if this.entityFeature.excelImport>
import ${this.classNameLower}Import from './import'
</#if>
${importApi(this.metaEntity)}
<#if !importOtherEntitys.isEmpty()>
    <#list importOtherEntitys as foreignEntity>
        <#if foreignEntity != this.metaEntity>
${importApi(foreignEntity)}
        </#if>
    </#list>
</#if>
<#if !importEnums.isEmpty()>
import enums from '@/utils/enums'
</#if>
<#if this.pageSign>
import Pagination from '@/components/Pagination'
</#if>

export default {
  name: '${this.className}Table',
  components: {
<@removeLastComma>
    <#if this.pageSign>
    Pagination,
    </#if>
    <#if this.entityFeature.save>
    ${this.classNameLower}Add,
    </#if>
    <#if this.entityFeature.update>
    ${this.classNameLower}Edit,
    </#if>
    <#if this.entityFeature.show>
    ${this.classNameLower}Show,
    </#if>
    <#list this.holds! as otherEntity,mtm>
        <#assign othercName=lowerFirstWord(otherEntity.className)>
        <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
        <#if entityFeature.addRemove>
    ${othercName}AddRemove,
        <#elseIf entityFeature.set>
    ${othercName}Setting,
        </#if>
    </#list>
    <#if this.entityFeature.excelImport>
    ${this.classNameLower}Import,
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
<#if !importOtherEntitys.isEmpty()>
      options: {
    <@removeLastComma>
        <#list importOtherEntitys as foreignEntity>
        ${lowerFirstWord(foreignEntity.className)}: [],
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
            <#if QueryType.isIn(field.queryType)>
        ${field.jfieldName}: [],
            <#elseIf !QueryType.isBetween(field.queryType)>
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
<#if !importOtherEntitys.isEmpty()>
    <@removeLastComma>
        <#list importOtherEntitys as foreignEntity>
            <#assign foreignClassName = lowerFirstWord(foreignEntity.className)>
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
      return ${this.classNameLower}Api.fetchList(this.query)
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
        .then(() => ${this.classNameLower}Api.deleteById(row.${this.id}))
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
        .then(() => ${this.classNameLower}Api.deleteBatch(this.selectItems.map(row => row.${this.id})))
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
      this.$refs.${this.classNameLower}Add.handleCreate()
    },
    </#if>
    <#if this.entityFeature.show>
    /**
     * 打开查看表单
     */
    handleShow(row) {
      this.$refs.${this.classNameLower}Show.handleShow(row.${this.id})
    },
    </#if>
    <#if this.entityFeature.update>
    /**
     * 打开编辑表单
     */
    handleUpdate(row) {
      this.$refs.${this.classNameLower}Edit.handleUpdate(row.${this.id})
    },
    </#if>
    <#list this.holds! as otherEntity,mtm>
        <#assign otherCName=otherEntity.className>
        <#assign othercName=lowerFirstWord(otherEntity.className)>
        <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
        <#if entityFeature.addRemove>
    /**
     * 打开添加移除${otherEntity.title}表单
     */
    handle${otherCName}AddRemove(row) {
      this.$refs.${othercName}AddRemove.handleShow(row.${this.id})
    },
        <#elseIf entityFeature.set>
    /**
     * 打开设置${otherEntity.title}表单
     */
    handle${otherCName}Setting(row) {
      this.$refs.${othercName}Setting.handleShow(row.${this.id})
    },
        </#if>
    </#list>
    <#if this.entityFeature.excelExport>
    /**
     * 导出excel
     */
    handleExport() {
      return this.$common.confirm('是否确认导出')
        .then(() => ${this.classNameLower}Api.exportExcel(this.query))
    },
    </#if>
    <#if this.entityFeature.excelImport>
    /**
     * 打开导入表单
     */
    handleImport() {
      this.$refs.${this.classNameLower}Import.show()
    },
    </#if>
</@removeLastComma>
  }
}
</script>
