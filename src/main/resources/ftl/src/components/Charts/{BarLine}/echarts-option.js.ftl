<#include "/abstracted/commonForChart.ftl">
<#if !isChartType(ChartType.BAR_LINE)>
    <@call this.skipCurrent()/>
</#if>
<#assign series>
    <#if barLineParamMode == 2>
  [<#lt>
        <@removeLastComma>
            <#list this.axisYList as axisY>
    {
${buildBarLineSeries(axisY,'      ')}
    },
            </#list>
        </@removeLastComma>
  ]<#rt>
    <#else>
[]<#t>
    </#if>
</#assign>
const option = ${this.optionTemplate?replace(r"${source}","[]")?replace(r"${series}",series)}

export function getOption() {
  return JSON.parse(JSON.stringify(option))
}
