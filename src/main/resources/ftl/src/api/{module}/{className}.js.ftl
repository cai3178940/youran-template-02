<#include "/abstracted/common.ftl">
import request from '@/utils/request'
<#if this.entityFeature.excelExport || this.entityFeature.excelImport>
import { downloadBlob } from '@/utils/download'
</#if>
<#if this.module?hasContent>
const apiPath = '/${this.module}/${this.className}'
<#else>
const apiPath = '/${this.className}'
</#if>
const ${this.className}Api = {
<@removeLastComma>
    <#if this.entityFeature.save>
  /**
   * 新增【${this.title}】
   */
  create(data) {
    return request.post(apiPath, data)
  },
    </#if>
    <#if this.entityFeature.update>
  /**
   * 修改【${this.title}】
   */
  update(data) {
    return request.put(apiPath, data)
  },
    </#if>
    <#if this.entityFeature.list>
  /**
   * ${this.pageSign?string('分页','列表')}查询【${this.title}】
   */
  fetchList(query) {
    return request.get(apiPath, { params: query })
  },
    </#if>
    <#if this.titleField??>
  /**
   * 查询【${this.title}】选项列表
   */
  findOptions(query) {
    return request.get(`${r'$'}{apiPath}/options`, { params: query })
  },
    </#if>
    <#if this.entityFeature.show>
  /**
   * 查看【${this.title}】详情
   */
  fetchById(${this.id}) {
    return request.get(`${r'$'}{apiPath}/${r'$'}{${this.id}}`)
  },
    </#if>
    <#if this.entityFeature.delete>
  /**
   * 删除单个【${this.title}】
   */
  deleteById(${this.id}) {
    return request.delete(`${r'$'}{apiPath}/${r'$'}{${this.id}}`)
  },
    </#if>
    <#if this.entityFeature.deleteBatch>
  /**
   * 批量删除【${this.title}】
   */
  deleteBatch(ids) {
    return request.delete(apiPath, { data: ids })
  },
    </#if>
    <#list this.holds! as otherEntity,mtm>
        <#assign otherCName=otherEntity.className?capFirst>
        <#assign othercName=otherEntity.className?uncapFirst>
        <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
        <#if entityFeature.addRemove || entityFeature.set>
  /**
   * 获取【${otherEntity.title}】关联
   */
  fetch${otherCName}List(${this.id}) {
    return request.get(`${r'$'}{apiPath}/${r'$'}{${this.id}}/${othercName}`)
  },
        </#if>
        <#if entityFeature.addRemove>
  /**
   * 添加【${otherEntity.title}】关联
   */
  add${otherCName}(${this.id}, data) {
    return request.post(`${r'$'}{apiPath}/${r'$'}{${this.id}}/${othercName}`, data)
  },
  /**
   * 移除【${otherEntity.title}】关联
   */
  remove${otherCName}(${this.id}, data) {
    return request.delete(`${r'$'}{apiPath}/${r'$'}{${this.id}}/${othercName}`, { data })
  },
        <#elseIf entityFeature.set>
  /**
   * 设置【${otherEntity.title}】关联
   */
  set${otherCName}(${this.id}, data) {
    return request.put(`${r'$'}{apiPath}/${r'$'}{${this.id}}/${othercName}`, data)
  },
        </#if>
    </#list>
    <#if this.entityFeature.excelExport>
  /**
   * 导出【${this.title}】excel
   */
  exportExcel(query) {
    return request.get(`${r'$'}{apiPath}/export`, { responseType: 'blob', params: query })
      .then(res => downloadBlob(res, '${this.className}Export.xlsx'))
  },
    </#if>
    <#if this.entityFeature.excelImport>
  /**
   * 下载【${this.title}】模板
   */
  downloadTemplate() {
    request.get(`${r'$'}{apiPath}/template`, { responseType: 'blob' })
      .then(res => downloadBlob(res, '${this.className}Template.xlsx'))
  },
  /**
   * 获取【${this.title}】上传路径
   */
  getImportUrl() {
    return request.defaults.baseURL + apiPath + '/import'
  },
    </#if>
</@removeLastComma>
}
export default ${this.className}Api
