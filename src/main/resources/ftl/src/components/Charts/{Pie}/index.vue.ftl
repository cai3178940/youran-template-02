<#include "/abstracted/commonForChart.ftl">
<#if !isChartType(ChartType.PIE)>
    <@call this.skipCurrent()/>
</#if>
<template>
  <div class="${this.chartNameLower}" :style="{height:height,width:width}">
      <div class="pieChart"/>
  </div>
</template>

<script>
${importApi(this.chartName,this.module)}
import echarts from 'echarts'
<#if !importEnums.isEmpty()>
import enums from '@/utils/enums'
</#if>
import { getOption } from './echarts-option'
import { getChartSizeInBox } from '@/utils/chart-util'

export default {
  name: '${this.chartName}',
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
  data() {
    return {
      listLoading: true,
      option: getOption(),
      // 暂时没有查询参数
      query: {},
      chart: null
    }
  },
  methods: {
    /**
     * 执行列表数据查询
     */
    doQueryList() {
      this.listLoading = true
      return ${this.chartNameLower}Api.fetchList(this.query)
        .then(data => {
          this.option.dataset.source = data
          this.renderChart()
        })
        .finally(() => {
          this.listLoading = false
        })
    },
    /**
    * 渲染图表
    */
    renderChart() {
      const chartEl = this.$el.children[0]
      this.chart = echarts.init(chartEl)
      this.chart.setOption(this.option, true)
    },
    resize() {
      const [width, height] = getChartSizeInBox(this.$parent.$el)
      this.chart.resize({
        width,
        height
      })
    }
  },
  mounted() {
    this.doQueryList()
      .then(() => {
        setTimeout(() => {
          this.resize()
        }, 100)
      })
  }
}
</script>
<style lang="scss">
.${this.chartNameLower} {
    .pieChart {
        width: 100%;
        height: 100%;
    }
}
</style>
