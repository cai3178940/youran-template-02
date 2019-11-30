<#include "/abstracted/common.ftl">
import request from '@/utils/request'

const ${this.className}Api = {
  fetchById(id) {
    return request.get(`/api/${this.className}/${r'$'}{id}`)
  },
  fetchList(query) {
    return request.get(`/api/${this.className}`, { params: query })
  },
  create(data) {
    return request.post(`/api/${this.className}`, data)
  },
  update(data) {
    return request.put(`/api/${this.className}`, data)
  },
  deleteById(id) {
    return request.delete(`/api/${this.className}/${r'$'}{id}`)
  },
  deleteBatch(ids) {
    return request.delete(`/api/${this.className}`, { data: ids })
  }
}
export default ${this.className}Api
