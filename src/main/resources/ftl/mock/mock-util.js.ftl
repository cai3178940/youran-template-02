export function paging(list, page, limit) {
  const endIndex = page * limit
  const startIndex = (page - 1) * limit
  return list.slice(startIndex, endIndex)
}

export function copy(obj) {
  return JSON.parse(JSON.stringify(obj))
}
