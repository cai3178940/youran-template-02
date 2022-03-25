const baseURL = process.env.VUE_APP_BASE_API

export function paging(list, pageNo, pageSize) {
  const endIndex = pageNo * pageSize
  const startIndex = (pageNo - 1) * pageSize
  return list.slice(startIndex, endIndex)
}

export function copy(obj) {
  return JSON.parse(JSON.stringify(obj))
}

export function getUrlPattern(module, withId, suffix) {
  let pattern = `\\${r'$'}{baseURL}\\/${r'$'}{module}`
  if (withId) {
    pattern += `\\/(\\d+)`
  }
  if (suffix) {
    pattern += `\\/${r'$'}{suffix}`
  }
  pattern += `($|\\?)`
  return new RegExp(pattern)
}
