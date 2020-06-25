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
