<#include "/abstracted/commonForChart.ftl">
import request from '@/utils/request'
<#if this.excelExport!false>
import { downloadBlob } from '@/utils/download'
</#if>
<#if this.module?hasContent>
const apiPath = '/${this.module}/${this.chartNameLower}'
<#else>
const apiPath = '/${this.chartNameLower}'
</#if>
const ${this.chartNameLower}Api = {
<@removeLastComma>
  /**
   * 分页查询【${this.title}】
   */
  fetchList(query) {
    return request.get(apiPath, { params: query })
  },
    <#if this.excelExport!false>
  /**
   * 导出【${this.title}】
   */
  exportExcel(query) {
    return request.get(`${r'$'}{apiPath}/export`, { responseType: 'blob', params: query })
      .then(res => downloadBlob(res, '${this.chartNameLower}.xlsx'))
  },
    </#if>
</@removeLastComma>
}
export default ${this.chartNameLower}Api
