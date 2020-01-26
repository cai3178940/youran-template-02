<#include "/abstracted/common.ftl">
import request from '@/utils/request'

const ${this.className}Api = {
<@removeLastComma>
    <#if this.entityFeature.save>
  /**
   * 新增【${this.title}】
   */
  create(data) {
    return request.post(`/${this.className}`, data)
  },
    </#if>
    <#if this.entityFeature.update>
  /**
   * 修改【${this.title}】
   */
  update(data) {
    return request.put(`/${this.className}`, data)
  },
    </#if>
    <#if this.entityFeature.list>
  /**
   * ${this.pageSign?string('分页','列表')}查询【${this.title}】
   */
  fetchList(query) {
    return request.get(`/${this.className}`, { params: query })
  },
    </#if>
    <#if this.titleField??>
  /**
   * 查询【${this.title}】选项列表
   */
  findOptions(query) {
    return request.get(`/${this.className}/options`, { params: query })
  },
    </#if>
    <#if this.entityFeature.show>
  /**
   * 查看【${this.title}】详情
   */
  fetchById(${this.id}) {
    return request.get(`/${this.className}/${r'$'}{${this.id}}`)
  },
    </#if>
    <#if this.entityFeature.delete>
  /**
   * 删除单个【${this.title}】
   */
  deleteById(${this.id}) {
    return request.delete(`/${this.className}/${r'$'}{${this.id}}`)
  },
    </#if>
    <#if this.entityFeature.deleteBatch>
  /**
   * 批量删除【${this.title}】
   */
  deleteBatch(ids) {
    return request.delete(`/${this.className}`, { data: ids })
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
    return request.get(`/${this.className}/${r'$'}{${this.id}}/${othercName}`)
  },
        </#if>
        <#if entityFeature.addRemove>
  /**
   * 添加【${otherEntity.title}】关联
   */
  add${otherCName}(${this.id}, data) {
    return request.post(`/${this.className}/${r'$'}{${this.id}}/${othercName}`, data)
  },
  /**
   * 移除【${otherEntity.title}】关联
   */
  remove${otherCName}(${this.id}, data) {
    return request.delete(`/${this.className}/${r'$'}{${this.id}}/${othercName}`, { data })
  },
        <#elseIf entityFeature.set>
  /**
   * 设置【${otherEntity.title}】关联
   */
  set${otherCName}(${this.id}, data) {
    return request.put(`/${this.className}/${r'$'}{${this.id}}/${othercName}`, data)
  },
        </#if>
    </#list>
    <#if this.entityFeature.excelImport>
  /**
   * 导出【${this.title}】excel
   */
  exportExcel(query) {
    return request.get(`/${this.className}/export`, {
      responseType: 'blob',
      params: query
    })
  },
    </#if>
</@removeLastComma>
}
export default ${this.className}Api
