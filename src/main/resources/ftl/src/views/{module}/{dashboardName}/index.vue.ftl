<#include "/abstracted/commonForDashboard.ftl">
<template>
  <grid-layout
    :layout="[]"
    :col-num="12"
    :row-height="30"
    :margin="[10, 10]"
    :isDraggable="false"
    :isResizable="false"
    :autoSize="true"
    style="height: calc(100vh - 50px); overflow-x: hidden;"
  >
<#list this.layout as item>
    <#if item.chart??>
        <#assign isTable = item.chart.chartType == ChartType.AGG_TABLE.getValue()
                || item.chart.chartType == ChartType.DETAIL_LIST.getValue()>
    <grid-item :x="${item.x}"
               :y="${item.y}"
               :w="${item.w}"
               :h="${item.h}"
               i="${item.chart.chartName}">
      <el-card class="box-card${isTable?string(' card-table','')}${item.showCard?string('',' card-hidden')}"
               style="height:100%;"${item.showCard?string('',' shadow="never"')}>
        <#if item.showTitle>
        <div slot="header">
          <span style="white-space:nowrap;">${item.chart.title}</span>
        </div>
        </#if>
        <${CommonTemplateFunction.camelCaseToKebabCase(item.chart.chartName, false)} height="100%" width="100%" />
      </el-card>
    </grid-item>
    <#else>
    <grid-item :x="${item.x}"
               :y="${item.y}"
               :w="${item.w}"
               :h="${item.h}"
               i="${item.i}">
    </grid-item>
    </#if>
</#list>
  </grid-layout>
</template>

<script>
import VueGridLayout from 'vue-grid-layout'
<#list charts as chart>
import ${chart.chartName} from '@/components/Charts/${chart.chartName}'
</#list>

export default {
  name: '${this.name}',
  components: {
<@removeLastComma>
    GridLayout: VueGridLayout.GridLayout,
    GridItem: VueGridLayout.GridItem,
    <#list charts as chart>
    ${chart.chartName},
    </#list>
</@removeLastComma>
  }
}
</script>
