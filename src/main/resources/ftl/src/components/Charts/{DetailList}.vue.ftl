<#include "/abstracted/common.ftl">
<#include "/abstracted/commonForChart.ftl">
<#if !isChartType(ChartType.DETAIL_LIST)>
    <@call this.skipCurrent()/>
</#if>
<template>
  <div :class="className" :style="{height:height,width:width}">
    <el-table v-loading="listLoading" :data="list"
              border stripe style="width: 100%;">
<#list this.columnList as column>
        <#assign sourceItem=column.sourceItem>
        <#if sourceItem.custom>
            <#--字段名-->
            <#assign name=sourceItem.alias>
            <#--字段标题-->
            <#assign label=column.titleAlias>
        <#else>
            <#assign field=sourceItem.field>
            <#if sourceItem.alias?hasContent>
                <#assign name=sourceItem.alias>
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
    <pagination v-show="total>0" :total="total" :page.sync="query.page"
                :limit.sync="query.limit" @pagination="doQueryList"/>
  </div>
</template>

<script>
${importApi(this.chartName,this.module)}
import Pagination from '@/components/Pagination'
<#if !importEnums.isEmpty()>
import enums from '@/utils/enums'
</#if>
import resize from './mixins/resize'

export default {
  name: '${this.chartName}',
  mixins: [resize],
  components: {
    Pagination
  },
  props: {
    className: {
      type: String,
      default: '${this.chartNameLower}'
    },
    width: {
      type: String,
      default: '200px'
    },
    height: {
      type: String,
      default: '200px'
    }
  },
  filters: {
    findEnumLabel: enums.findEnumLabel
  },
  data() {
    return {
      enums: {
    <@removeLastComma>
        <#list importEnums as const>
        ${const.constName?uncapFirst}: enums.get${const.constName}(),
        </#list>
    </@removeLastComma>
      },
      list: [],
      total: 0,
      listLoading: true,
      query: {
        page: 1,
        limit: 10
      }
    }
  },
  created() {
    this.doQueryList({ page: 1 })
  },
  methods: {
    /**
     * 执行列表查询
     */
    doQueryList({ page, limit }) {
      if (page) {
        this.query.page = page
      }
      if (limit) {
        this.query.limit = limit
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
    }
  }
}
</script>
