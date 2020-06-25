<#include "/abstracted/commonForChart.ftl">
import request from '@/utils/request'
<#if this.module?hasContent>
const apiPath = '/${this.module}/${this.chartNameLower}'
<#else>
const apiPath = '/${this.chartNameLower}'
</#if>
const ${this.chartNameLower}Api = {
  /**
   * 分页查询【${this.title}】
   */
  fetchList(query) {
    return request.get(apiPath, { params: query })
  }
}
export default ${this.chartNameLower}Api
