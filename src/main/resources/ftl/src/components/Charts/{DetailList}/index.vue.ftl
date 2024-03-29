<#include "/abstracted/commonForChart.ftl">
<#if !isChartType(ChartType.DETAIL_LIST)>
    <@call this.skipCurrent()/>
</#if>
<template>
  <div :style="{height:height,width:width}">
    <el-table v-loading="listLoading" :data="list"
              border stripe style="width: 100%;"
              size="mini">
<#list this.columnList as column>
    <#assign sourceItem=column.sourceItem>
    <#if sourceItem.custom>
        <#--字段名-->
        <#assign name=column.alias>
        <#--字段标题-->
        <#assign label=column.titleAlias>
    <#else>
        <#assign field=sourceItem.field>
        <#if column.alias?hasContent>
            <#assign name=column.alias>
        <#else>
            <#assign name=field.jfieldName>
        </#if>
        <#if column.titleAlias?hasContent>
            <#assign label=column.titleAlias>
        <#else>
            <#assign label=field.fetchComment()?replace('\"','\\"')?replace('\n','\\n')>
        </#if>
    </#if>
      <el-table-column label="${label}"
                       align="center">
        <template slot-scope="{row}">
    <#-- 枚举字段特殊处理 -->
    <#if !sourceItem.custom && field.dicType??>
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
</#list>
    </el-table>
<#if this.excelExport!false>
    <el-button size="mini" type="text"
               icon="el-icon-download"
               style="float: right;margin-right: 10px;"
               @click="handleExport">
      excel导出
    </el-button>
</#if>
    <pagination v-show="total>0" :total="total" :pageNo.sync="query.pageNo"
                :pageSize.sync="query.pageSize" @pagination="doQueryList"
                layout="prev, pager, next"
                hide-on-single-page small/>
  </div>
</template>

<script>
${importApi(this.chartName,this.module)}
import Pagination from '@/components/Pagination'
<#if !importEnums.isEmpty()>
import enums from '@/utils/enums'
</#if>

export default {
  name: '${this.chartName}',
  components: {
    Pagination
  },
  props: {
    width: {
      type: String,
      default: '200px'
    },
    height: {
      type: String,
      default: '200px'
    }
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
      list: [],
      total: 0,
      listLoading: true,
      query: {
        pageNo: 1,
        pageSize: ${this.defaultPageSize}
      }
    }
  },
  created() {
    this.doQueryList({ page: 1 })
  },
  methods: {
<@removeLastComma>
    /**
     * 执行列表查询
     */
    doQueryList({ pageNo, pageSize }) {
      if (pageNo) {
        this.query.pageNo = pageNo
      }
      if (pageSize) {
        this.query.pageSize = pageSize
      }
      this.listLoading = true
      return ${this.chartNameLower}Api.fetchList(this.query)
        .then(data => {
          this.list = data.list
          this.total = data.total
        })
        .finally(() => {
          this.listLoading = false
        })
    },
    <#if this.excelExport!false>
    /**
     * 导出excel
     */
    handleExport() {
      return this.$common.confirm('是否确认导出')
        .then(() => ${this.chartNameLower}Api.exportExcel(this.query))
    },
    </#if>
</@removeLastComma>
  }
}
</script>
