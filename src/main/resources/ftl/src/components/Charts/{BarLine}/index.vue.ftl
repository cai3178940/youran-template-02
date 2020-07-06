<#include "/abstracted/commonForChart.ftl">
<#if !isChartType(ChartType.BAR_LINE)>
    <@call this.skipCurrent()/>
</#if>
<template>
  <div class="${this.chartNameLower}" :style="{height:height,width:width}">
      <div class="barLineChart"/>
  </div>
</template>

<script>
${importApi(this.chartName,this.module)}
import echarts from 'echarts'
<#if !importEnums.isEmpty()>
import enums from '@/utils/enums'
</#if>
import resize from '../mixins/resize'
import getOption from './echarts-option'

export default {
  name: '${this.chartName}',
  mixins: [resize],
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
          this.option.dataset.source = data
<#if barLineParamMode == 1>
          const series = []
          const header = data[0]
          for (let i = 0; i < header.length - 1; i++) {
            series.push({ type: '${this.axisYList[0].seriesType}' })
          }
          this.option.series = series
</#if>
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
    }
  }
}
</script>
<style lang="scss">
.${this.chartNameLower} {
    .barLineChart {
        width: 100%;
        height: 400px;
    }
}
</style>
