<#include "/abstracted/commonForChart.ftl">
<#if !isChartType(ChartType.AGG_TABLE)>
    <@call this.skipCurrent()/>
</#if>
<template>
  <div :style="{height:height,width:width}">
    <el-table v-loading="listLoading" :data="list"
              border stripe style="width: 100%;"
              size="mini">
<#list this.dimensionList as chartItem>
    <#assign dimension=chartItem.sourceItem>
    <#assign field=dimension.field>
    <#assign name=chartItem.alias>
    <#assign label=chartItem.titleAlias>
      <el-table-column label="${label}"
                       align="center">
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
</#list>
<#list this.metricsList as chartItem>
    <#assign name=chartItem.alias>
    <#assign label=chartItem.titleAlias>
      <el-table-column label="${label}"
                       align="center">
        <template slot-scope="{row}">
          <span>{{ row.${name} }}</span>
        </template>
      </el-table-column>
</#list>
    </el-table>
    <pagination v-show="total>0 && total>query.limit" :total="total" :page.sync="query.page"
                :limit.sync="query.limit" @pagination="doQueryList"
                small/>
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
