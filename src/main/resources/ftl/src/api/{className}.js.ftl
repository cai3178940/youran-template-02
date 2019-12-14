<#include "/abstracted/common.ftl">
import request from '@/utils/request'

const ${this.className}Api = {
<@removeLastComma>
    <#if this.entityFeature.show>
  fetchById(${this.id}) {
    return request.get(`/${this.className}/${r'$'}{${this.id}}`)
  },
    </#if>
    <#if this.entityFeature.list>
  fetchList(query) {
    return request.get(`/${this.className}`, { params: query })
  },
    </#if>
    <#if this.titleField??>
  findOptions() {
    return request.get(`/${this.className}/options`)
  },
    </#if>
    <#if this.entityFeature.save>
  create(data) {
    return request.post(`/${this.className}`, data)
  },
    </#if>
    <#if this.entityFeature.update>
  update(data) {
    return request.put(`/${this.className}`, data)
  },
    </#if>
    <#if this.entityFeature.delete>
  deleteById(${this.id}) {
    return request.delete(`/${this.className}/${r'$'}{${this.id}}`)
  },
    </#if>
    <#if this.entityFeature.deleteBatch>
  deleteBatch(ids) {
    return request.delete(`/${this.className}`, { data: ids })
  },
    </#if>
    <#list this.holds! as otherEntity,mtm>
        <#assign otherCName=otherEntity.className?capFirst>
        <#assign othercName=otherEntity.className?uncapFirst>
        <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
        <#if entityFeature.addRemove || entityFeature.set>
  fetch${otherCName}List(${this.id}) {
    return request.get(`/${this.className}/${r'$'}{${this.id}}/${othercName}`)
  },
  set${otherCName}(${this.id}, data) {
    return request.put(`/${this.className}/${r'$'}{${this.id}}/${othercName}`, data)
  },
        </#if>
    </#list>
</@removeLastComma>
}
export default ${this.className}Api
