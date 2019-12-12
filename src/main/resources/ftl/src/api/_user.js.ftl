import request from '@/utils/request'

export function login(data) {
  return request({
    url: '/_user/login',
    method: 'post',
    data
  })
}

export function getInfo(token) {
  return request({
    url: '/_user/info',
    method: 'get',
    params: { token }
  })
}

export function logout() {
  return request({
    url: '/_user/logout',
    method: 'post'
  })
}
