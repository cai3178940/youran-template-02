export function downloadBlob(res, fileName) {
  const blob = new Blob([res], { type: res.type })
  const downloadElement = document.createElement('a')
  const href = window.URL.createObjectURL(blob)
  downloadElement.href = href
  downloadElement.download = fileName
  document.body.appendChild(downloadElement)
  downloadElement.click()
  document.body.removeChild(downloadElement)
  window.URL.revokeObjectURL(href)
}
