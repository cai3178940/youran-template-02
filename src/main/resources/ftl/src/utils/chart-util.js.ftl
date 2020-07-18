export function getChartSizeInBox(box) {
  const parentWidth = box.clientWidth
  const parentHeight = box.clientHeight
  let height = parentHeight
  // 如果存在两个元素，第一个是标题，需要排除
  if (box.childElementCount === 2) {
    height = parentHeight - box.firstElementChild.clientHeight
  }
  return [parentWidth, height]
}
