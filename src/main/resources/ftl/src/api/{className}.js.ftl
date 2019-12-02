<#include "/abstracted/common.ftl">
import request from '@/utils/request'

const ${this.className}Api = {
<@removeLastComma>
    <#if this.entityFeature.show>
  fetchById(${this.id}) {
    return request.get(`/api/${this.className}/${r'$'}{${this.id}}`)
  },
    </#if>
    <#if !this.entityFeature.list>
  fetchList(query) {
    return request.get(`/api/${this.className}`, { params: query })
  },
    </#if>
    <#if this.entityFeature.save>
  create(data) {
    return request.post(`/api/${this.className}`, data)
  },
    </#if>
    <#if this.entityFeature.update>
  update(data) {
    return request.put(`/api/${this.className}`, data)
  },
    </#if>
    <#if this.entityFeature.delete>
  deleteById(${this.id}) {
    return request.delete(`/api/${this.className}/${r'$'}{${this.id}}`)
  },
    </#if>
    <#if this.entityFeature.deleteBatch>
  deleteBatch(ids) {
    return request.delete(`/api/${this.className}`, { data: ids })
  },
    </#if>
</@removeLastComma>
}
export default ${this.className}Api
