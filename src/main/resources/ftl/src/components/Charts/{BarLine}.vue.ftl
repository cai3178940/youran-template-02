<#include "/abstracted/common.ftl">
<#include "/abstracted/commonForChart.ftl">
<#if !isChartType(ChartType.BAR_LINE)>
    <@call this.skipCurrent()/>
</#if>
<template>
  <div :class="className" :style="{height:height,width:width}">
    <el-table v-loading="listLoading" :data="list"
              border stripe style="width: 100%;">
    </el-table>
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
  data() {
    return {
      list: [],
      listLoading: true,
      // 暂时没有查询参数
      query: {}
    }
  },
  created() {
    this.doQueryList()
  },
  methods: {
    /**
     * 执行列表数据查询
     */
    doQueryList() {
      this.listLoading = true
      return ${this.chartNameLower}Api.fetchList(this.query)
        .then(data => {
          this.list = data
        })
        .finally(() => {
          this.listLoading = false
        })
    }
  }
}
</script>
