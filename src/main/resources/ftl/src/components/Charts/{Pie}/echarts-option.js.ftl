<#include "/abstracted/commonForChart.ftl">
<#if !isChartType(ChartType.PIE)>
    <@call this.skipCurrent()/>
</#if>
const option = ${this.optionTemplate?replace(r"${source}","[]")}

export function getOption() {
  return JSON.parse(JSON.stringify(option))
}
