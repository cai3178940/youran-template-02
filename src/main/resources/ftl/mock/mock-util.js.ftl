export function paging(list, query) {
  const endIndex = query.page * query.limit
  const startIndex = (query.page - 1) * query.limit
  return list.slice(startIndex, endIndex)
}

export function copy(obj) {
  return JSON.parse(JSON.stringify(obj))
}
