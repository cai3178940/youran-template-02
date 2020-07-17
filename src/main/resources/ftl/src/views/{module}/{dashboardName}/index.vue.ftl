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
  >
<#list this.layout as item>
    <#if item.chart??>
    <grid-item :x="${item.x}"
               :y="${item.y}"
               :w="${item.w}"
               :h="${item.h}"
               i="${item.chart.chartName}">
        <#if item.showCard>
      <el-card class="box-card" style="height:100%;">
            <#if item.showTitle>
        <div slot="header">
          <span style="white-space:nowrap;">${item.chart.title}</span>
        </div>
            </#if>
        <${CommonTemplateFunction.camelCaseToKebabCase(item.chart.chartName, false)} height="100%" width="100%" />
      </el-card>
        <#else>
            <#if item.showTitle>
      <div class="chartTitle">
        <span style="white-space:nowrap;">${item.chart.title}</span>
      </div>
            </#if>
      <${CommonTemplateFunction.camelCaseToKebabCase(item.chart.chartName, false)} height="100%" width="100%" />
        </#if>
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
