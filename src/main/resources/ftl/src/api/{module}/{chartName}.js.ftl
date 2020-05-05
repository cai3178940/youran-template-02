<#include "/abstracted/common.ftl">
<#include "/abstracted/commonForChart.ftl">
import request from '@/utils/request'
const apiPath = '/${this.module}/${this.chartNameLower}'
const ${this.chartNameLower}Api = {
  /**
   * 分页查询【${this.title}】
   */
  fetchList(query) {
    return request.get(apiPath, { params: query })
  }
}
export default ${this.chartNameLower}Api
