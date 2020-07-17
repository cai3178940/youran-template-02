<#include "/abstracted/common.ftl">
<#-- 图表集合 -->
<#assign charts = CommonTemplateFunction.createHashSet()>
<#list this.layout as item>
    <#if item.chart??>
        <@justCall charts.add(item.chart)/>
    </#if>
</#list>
