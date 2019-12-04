<#include "/abstracted/common.ftl">
<#include "/abstracted/table.ftl">
<#if !this.entityFeature.list>
    <@call this.skipCurrent()/>
</#if>
<template>
  <div class="app-container">
    <div class="filter-container">
<#--渲染查询输入框-->
<#list this.queryFields>
    <#items as id,field>
        <#if !QueryType.isBetween(field.queryType)>
      <el-input v-model="listQuery.${field.jfieldName}" placeholder="${field.fieldDesc}"
                style="width: 200px;" class="filter-item"
                @keyup.enter.native="handleQuery"/>
        <#else>
        <#-- TODO 其他类型查询条件 -->
        </#if>
    </#items>
      <el-button class="filter-item" icon="el-icon-search" type="primary"
                 @click="handleQuery">
        搜索
      </el-button>
</#list>
<#if this.entityFeature.save>
      <el-button class="filter-item" style="margin-left: 10px;" type="primary"
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
<#list this.listFields as id,field>
      <el-table-column label="${field.fieldDesc}"
                       prop="${field.jfieldName}"
    <#if field.listSort>
                       sortable="custom"
    </#if>
                       align="center"<#if field.columnWidth?? && field.columnWidth &gt; 0> width="${field.columnWidth}"</#if>>
        <template slot-scope="{row}">
          <span>{{ row.${field.jfieldName} }}</span>
        </template>
      </el-table-column>
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
    <pagination v-show="total>0" :total="total" :page.sync="listQuery.page"
                :limit.sync="listQuery.limit" @pagination="doQueryList"/>
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
  data() {
    return {
<@removeLastComma>
      list: [],
      total: 0,
      listLoading: true,
      listQuery: {
    <@removeLastComma>
        <#if this.pageSign>
        page: 1,
        limit: 10,
        </#if>
        <#list this.queryFields as id,field>
        ${field.jfieldName}: null,
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
          this.listQuery[sortKey] = null
        } else {
          if (order === 'ascending') {
            this.listQuery[sortKey] = 1
          } else {
            this.listQuery[sortKey] = -1
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
        this.listQuery.page = page
      }
      if (limit) {
        this.listQuery.limit = limit
      }
    </#if>
      this.listLoading = true
      return ${this.className}Api.fetchList(this.listQuery)
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
