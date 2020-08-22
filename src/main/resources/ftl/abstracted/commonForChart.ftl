<#include "/abstracted/common.ftl">
<#-- 判断当前图表的类型 -->
<#function isChartType chartTypeEnum>
    <#return this.chartType == chartTypeEnum.getValue()>
</#function>
<#-- 柱线图的参数模式 -->
<#assign barLineParamMode=0>
<#if isChartType(ChartType.BAR_LINE)>
    <#if this.axisX2??>
        <#assign barLineParamMode=1>
    <#else>
        <#assign barLineParamMode=2>
    </#if>
</#if>
<#function buildBarLineSeries chartItem indent=''>
    <#local seriesType = chartItem.seriesType>
    <#local series = ''>
    <#if !seriesType?? || seriesType == 'bar'>
        <#local series = series + indent + 'type: \'bar\''>
    <#elseIf seriesType == 'line'>
        <#local series = series + indent + 'type: \'line\''>
    <#elseIf seriesType == 'area-stack'>
        <#local series = series + indent + 'type: \'line\',\n'>
        <#local series = series + indent + 'areaStyle: {},\n'>
        <#local series = series + indent + 'stack: \'总量\''>
    <#elseIf seriesType == 'bar-stack'>
        <#local series = series + indent + 'type: \'bar\',\n'>
        <#local series = series + indent + 'areaStyle: {},\n'>
        <#local series = series + indent + 'stack: \'总量\''>
    <#elseIf seriesType == 'line-smooth'>
        <#local series = series + indent + 'type: \'line\',\n'>
        <#local series = series + indent + 'smooth: true'>
    </#if>
    <#return series>
</#function>
